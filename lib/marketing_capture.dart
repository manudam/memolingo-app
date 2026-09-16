import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'helpers/string_helpers.dart';
import 'models/app_user.dart';
import 'models/game_state.dart';
import 'providers/game_provider.dart';
import 'providers/library_provider.dart';
import 'providers/user_provider.dart';
import 'screens/library/category_words_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/practice/game_result_screen.dart';
import 'screens/practice/game_screen.dart';
import 'screens/practice/practice_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'services/iap_service.dart';
import 'services/local_storage_service.dart';

const _screen = String.fromEnvironment(
  'MARKETING_SCREEN',
  defaultValue: 'listing-practice',
);
const _outputPath = String.fromEnvironment('MARKETING_OUTPUT_PATH');
final _posterCanvasSize = Size(
  double.parse(
    const String.fromEnvironment('MARKETING_CANVAS_WIDTH', defaultValue: '414'),
  ),
  double.parse(
    const String.fromEnvironment('MARKETING_CANVAS_HEIGHT', defaultValue: '896'),
  ),
);
final _devicePreviewSize = Size(
  double.parse(
    const String.fromEnvironment('MARKETING_DEVICE_WIDTH', defaultValue: '430'),
  ),
  double.parse(
    const String.fromEnvironment('MARKETING_DEVICE_HEIGHT', defaultValue: '932'),
  ),
);
final _capturePixelRatio = double.parse(
  const String.fromEnvironment('MARKETING_CAPTURE_PIXEL_RATIO', defaultValue: '3'),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _MarketingCaptureApp());
}

class _MarketingCaptureApp extends StatelessWidget {
  const _MarketingCaptureApp();

  @override
  Widget build(BuildContext context) {
    final spec = _listingSpecFor(_screen);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _memoLingoTheme(),
      home: spec == null
          ? Scaffold(
              body: Center(child: Text('Unknown MARKETING_SCREEN: $_screen')),
            )
          : _ListingPosterCaptureScreen(spec: spec),
    );
  }
}

/// Mirrors the real app's ThemeData (lib/main.dart) so captured screens keep
/// MemoLingo's actual card/button/app-bar styling.
ThemeData _memoLingoTheme() {
  return ThemeData(
    fontFamily: 'CaviarDreams',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5D6DBD),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF5D6DBD),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF5D6DBD),
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontFamily: 'DeliusUnicase',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Color(0xFFEFEBE9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(fontFamily: 'CaviarDreams', fontSize: 20),
      ),
    ),
  );
}

// --- Listing poster specs ---------------------------------------------------

typedef _ScreenFactory = Future<Widget> Function();

class _ListingPosterSpec {
  const _ListingPosterSpec({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.buildScreen,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color backgroundStart;
  final Color backgroundEnd;
  final _ScreenFactory buildScreen;
}

_ListingPosterSpec? _listingSpecFor(String screen) {
  return switch (screen) {
    'listing-practice' => _ListingPosterSpec(
      title: 'Turn vocab into a game',
      subtitle:
          'Follow a playful path of streaks, XP, and unlocked packs as you learn.',
      accent: const Color(0xFFFFC163),
      backgroundStart: const Color(0xFFEDEBFF),
      backgroundEnd: const Color(0xFFDCE4FF),
      buildScreen: _buildPracticeScreen,
    ),
    'listing-game' => _ListingPosterSpec(
      title: 'Learn by playing, not memorizing',
      subtitle:
          'Match the picture, hear it out loud, and keep your combo alive.',
      accent: const Color(0xFFFFA26B),
      backgroundStart: const Color(0xFFFFE9D6),
      backgroundEnd: const Color(0xFFFFD9C7),
      buildScreen: _buildGameScreen,
    ),
    'listing-result' => _ListingPosterSpec(
      title: 'Celebrate every win',
      subtitle:
          'Earn XP, build your streak, and see exactly what to review next.',
      accent: const Color(0xFF8FD6A0),
      backgroundStart: const Color(0xFFE1F6E5),
      backgroundEnd: const Color(0xFFDCEBFB),
      buildScreen: _buildGameResultScreen,
    ),
    'listing-library' => _ListingPosterSpec(
      title: 'Pick your vocabulary packs',
      subtitle:
          'Start free, then unlock more categories as your confidence grows.',
      accent: const Color(0xFFB69CFF),
      backgroundStart: const Color(0xFFF1ECFF),
      backgroundEnd: const Color(0xFFE3EBFB),
      buildScreen: _buildLibraryScreen,
    ),
    'listing-category-words' => _ListingPosterSpec(
      title: 'Hear every word out loud',
      subtitle:
          'Real translations with native pronunciation and mastery tracking.',
      accent: const Color(0xFF8AC6D1),
      backgroundStart: const Color(0xFFE3F4F6),
      backgroundEnd: const Color(0xFFE7ECFB),
      buildScreen: _buildCategoryWordsScreen,
    ),
    'listing-stats' => _ListingPosterSpec(
      title: 'Watch your streak grow',
      subtitle:
          'Accuracy, mastered words, and daily streaks — all in one place.',
      accent: const Color(0xFFFF9EAE),
      backgroundStart: const Color(0xFFFFE7EC),
      backgroundEnd: const Color(0xFFE9E7FB),
      buildScreen: _buildStatsScreen,
    ),
    _ => null,
  };
}

// --- Fixture environment -----------------------------------------------------

class _Env {
  _Env({
    required this.userProvider,
    required this.libraryProvider,
    required this.gameProvider,
  });

  final UserProvider userProvider;
  final LibraryProvider libraryProvider;
  final GameProvider gameProvider;
}

Future<_Env> _bootstrapEnvironment({
  required AppUser user,
  Set<String> purchasedProductIds = const {},
}) async {
  final userProvider = UserProvider(_FixtureLocalStorageService(user));
  await userProvider.initialize();

  final libraryProvider = LibraryProvider(
    _FixtureIapService(purchasedProductIds: purchasedProductIds),
    userProvider,
  );
  await libraryProvider.initialize();

  final gameProvider = GameProvider(userProvider);

  return _Env(
    userProvider: userProvider,
    libraryProvider: libraryProvider,
    gameProvider: gameProvider,
  );
}

Widget _withProviders(_Env env, Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: env.userProvider),
      ChangeNotifierProvider<LibraryProvider>.value(value: env.libraryProvider),
      ChangeNotifierProvider<GameProvider>.value(value: env.gameProvider),
    ],
    child: child,
  );
}

Future<void> _advanceGame(GameProvider game, {required int correctAnswers}) async {
  for (var i = 0; i < correctAnswers; i++) {
    if (game.state != GameState.playing || game.currentCorrectWord == null) {
      break;
    }
    await game.answer(game.currentCorrectWord!);
  }
}

Future<void> _playToVictory(GameProvider game) async {
  while (game.state == GameState.playing && game.currentCorrectWord != null) {
    await game.answer(game.currentCorrectWord!);
  }
}

/// Reads the bundled word list and returns the real word ids grouped by
/// category, so fixture mastery data lines up with what the app actually
/// loads (same id scheme as [LibraryProvider._loadWordsAndCategories]).
Future<Map<String, List<String>>> _wordIdsByCategory() async {
  final csvRaw = await rootBundle.loadString(LibraryProvider.csvAssetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvRaw);

  final result = <String, List<String>>{};
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length < 14) continue;
    final categoryName = row[0].toString().trim();
    final imageFile = row[3].toString().trim();
    final id = '${slugify(categoryName)}-${imageFile.toLowerCase()}';
    result.putIfAbsent(categoryName, () => <String>[]).add(id);
  }
  return result;
}

Future<AppUser> _richProgressUser({
  String targetLanguage = 'es',
  bool showLabels = true,
}) async {
  final wordIds = await _wordIdsByCategory();
  final mastery = <String, int>{};

  void seed(String category, List<int> pattern) {
    final ids = wordIds[category] ?? const <String>[];
    for (var i = 0; i < ids.length && i < pattern.length; i++) {
      mastery[ids[i]] = pattern[i];
    }
  }

  seed('animals', const [3, 3, 3, 3, 2, 2, 2, 1, 1, 0, 0, 0]);
  seed('food', const [3, 3, 2, 2, 2, 1, 1, 0]);
  seed('everyday objects', const [3, 3, 3, 2, 1]);
  seed('sports', const [2, 2, 1, 1, 0]);
  seed('transport', const [3, 2, 1]);
  seed('places', const [2, 1, 1]);

  return AppUser(
    wordMasteryByLanguage: {targetLanguage: mastery},
    gamesPlayedByLanguage: {targetLanguage: 42},
    gamesWonByLanguage: {targetLanguage: 35},
    bestProgressByLanguage: {targetLanguage: 50},
    totalCorrectByLanguage: {targetLanguage: 268},
    totalIncorrectByLanguage: {targetLanguage: 47},
    currentXPByLanguage: {targetLanguage: 1240},
    currentStreakByLanguage: {targetLanguage: 9},
    lastPlayedDateByLanguage: {targetLanguage: DateTime.now()},
    audioEnabled: false,
    showLabels: showLabels,
    targetLanguage: targetLanguage,
    nativeLanguage: 'en',
    labelLanguage: 'en',
    onboardingComplete: true,
    speechRate: 0.42,
  );
}

AppUser _libraryShowcaseUser({String targetLanguage = 'es'}) {
  return AppUser(
    audioEnabled: false,
    targetLanguage: targetLanguage,
    nativeLanguage: 'en',
    labelLanguage: 'en',
    onboardingComplete: true,
  );
}

// --- Per-screen builders ------------------------------------------------

Future<Widget> _buildPracticeScreen() async {
  final env = await _bootstrapEnvironment(
    user: await _richProgressUser(),
    purchasedProductIds: {LibraryProvider.bundleProductId},
  );
  return _withProviders(env, const PracticeScreen());
}

Future<Widget> _buildLibraryScreen() async {
  final env = await _bootstrapEnvironment(
    user: _libraryShowcaseUser(),
    purchasedProductIds: const {
      'memolingo_category_food',
      'memolingo_category_sports',
    },
  );
  return _withProviders(env, const LibraryScreen());
}

Future<Widget> _buildCategoryWordsScreen() async {
  final env = await _bootstrapEnvironment(user: await _richProgressUser());
  final category = env.libraryProvider.categoryById('animals');
  return _withProviders(
    env,
    CategoryWordsScreen(categoryId: category?.id ?? 'animals'),
  );
}

Future<Widget> _buildGameScreen() async {
  final env = await _bootstrapEnvironment(
    user: await _richProgressUser(showLabels: false),
  );
  final category = env.libraryProvider.categoryById('animals');
  if (category != null) {
    await env.gameProvider.startGame(category: category);
    await _advanceGame(env.gameProvider, correctAnswers: 8);
  }
  return _withProviders(env, const GameScreen());
}

Future<Widget> _buildGameResultScreen() async {
  final env = await _bootstrapEnvironment(user: await _richProgressUser());
  final category = env.libraryProvider.categoryById('animals');
  if (category != null) {
    await env.gameProvider.startGame(category: category);
    await _playToVictory(env.gameProvider);
  }
  return _withProviders(env, const GameResultScreen());
}

Future<Widget> _buildStatsScreen() async {
  final env = await _bootstrapEnvironment(
    user: await _richProgressUser(),
    purchasedProductIds: {LibraryProvider.bundleProductId},
  );
  return _withProviders(env, const StatsScreen());
}

// --- Fixture services -----------------------------------------------------

class _FixtureLocalStorageService extends LocalStorageService {
  _FixtureLocalStorageService(this._user);

  final AppUser _user;

  @override
  Future<AppUser> loadUser() async => _user;

  @override
  Future<void> saveUser(AppUser user) async {}
}

class _FixtureIapService extends IapService {
  _FixtureIapService({Set<String> purchasedProductIds = const {}})
      : _purchased = Set<String>.of(purchasedProductIds);

  final Set<String> _purchased;

  @override
  Future<void> initialize(Set<String> productIds) async {}

  @override
  bool isPurchased(String productId) => _purchased.contains(productId);
}

// --- Capture + poster chrome -------------------------------------------------

class _ListingPosterCaptureScreen extends StatefulWidget {
  const _ListingPosterCaptureScreen({required this.spec});

  final _ListingPosterSpec spec;

  @override
  State<_ListingPosterCaptureScreen> createState() =>
      _ListingPosterCaptureScreenState();
}

class _ListingPosterCaptureScreenState
    extends State<_ListingPosterCaptureScreen> {
  final GlobalKey _captureKey = GlobalKey();
  Widget? _screen;
  bool _didCapture = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final screen = await widget.spec.buildScreen();
    if (!mounted) return;
    setState(() => _screen = screen);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCapture());
  }

  Future<void> _scheduleCapture() async {
    if (_didCapture || _outputPath.isEmpty) return;
    _didCapture = true;

    // Let images decode and layout settle before snapshotting.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final boundaryContext = _captureKey.currentContext;
    if (boundaryContext == null) return;
    final renderObject = boundaryContext.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return;

    final image = await renderObject.toImage(pixelRatio: _capturePixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    await File(_outputPath).writeAsBytes(byteData.buffer.asUint8List());
    // ignore: avoid_print
    print('Saved marketing capture to $_outputPath');
    if (Platform.isMacOS) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = _screen;
    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _captureKey,
          child: SizedBox(
            width: _posterCanvasSize.width,
            height: _posterCanvasSize.height,
            child: screen == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.spec.backgroundStart,
                          widget.spec.backgroundEnd,
                        ],
                      ),
                    ),
                  )
                : _ListingPoster(spec: widget.spec, screen: screen),
          ),
        ),
      ),
    );
  }
}

class _ListingPoster extends StatelessWidget {
  const _ListingPoster({required this.spec, required this.screen});

  final _ListingPosterSpec spec;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math
            .max(
              1.0,
              math.min(
                2.1,
                math.min(
                  constraints.maxWidth / 414,
                  constraints.maxHeight / 896,
                ),
              ),
            )
            .toDouble();
        final horizontalPadding = 24.0 * scale;
        final topPadding = 24.0 * scale;
        final bottomPadding = 18.0 * scale;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        final badge = Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 6 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF1E2141).withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            'MemoLingo',
            style: TextStyle(
              fontFamily: 'DeliusUnicase',
              fontWeight: FontWeight.bold,
              fontSize: 14 * scale,
              color: const Color(0xFF1E2141),
            ),
          ),
        );
        final title = Text(
          spec.title,
          maxLines: 2,
          style: TextStyle(
            fontFamily: 'DeliusUnicase',
            fontWeight: FontWeight.bold,
            fontSize: 32 * scale,
            height: 1.05,
            color: const Color(0xFF1E2141),
          ),
        );
        final subtitle = Text(
          spec.subtitle,
          maxLines: 3,
          style: TextStyle(
            fontFamily: 'CaviarDreams',
            fontSize: 15 * scale,
            height: 1.25,
            color: const Color(0xFF4B5372),
          ),
        );
        Widget previewCard({required EdgeInsets padding}) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(36 * scale),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x220F1721),
                  blurRadius: 36 * scale,
                  offset: Offset(0, 18 * scale),
                ),
              ],
            ),
            padding: padding,
            child: _PreviewPanel(screen: screen, scale: scale),
          );
        }

        // In landscape, the device itself is wide, so the panel keeps the
        // device's own aspect ratio (a real landscape iPad frame) instead of
        // stretching to whatever box shape the row/column happens to leave.
        final panel = isLandscape
            ? Center(
                child: AspectRatio(
                  aspectRatio: _devicePreviewSize.width / _devicePreviewSize.height,
                  child: previewCard(padding: EdgeInsets.all(10 * scale)),
                ),
              )
            : previewCard(
                padding: EdgeInsets.fromLTRB(
                  10 * scale,
                  10 * scale,
                  10 * scale,
                  0,
                ),
              );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            badge,
            SizedBox(height: 14 * scale),
            title,
            SizedBox(height: 8 * scale),
            subtitle,
            SizedBox(height: 18 * scale),
            Expanded(child: panel),
          ],
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [spec.backgroundStart, spec.backgroundEnd],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -88 * scale,
                right: -72 * scale,
                child: _PosterOrb(
                  size: 196 * scale,
                  color: spec.accent.withValues(alpha: 0.30),
                ),
              ),
              Positioned(
                left: -54 * scale,
                top: 200 * scale,
                child: _PosterOrb(
                  size: 126 * scale,
                  color: const Color(0xFF5D6DBD).withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 30 * scale,
                bottom: 160 * scale,
                child: _PosterOrb(
                  size: 94 * scale,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: content,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PosterOrb extends StatelessWidget {
  const _PosterOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
        child: SizedBox.square(dimension: size),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.screen,
    required this.scale,
  });

  final Widget screen;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = 30.0 * scale;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: const Color(0x11000000),
                blurRadius: 16 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: _devicePreviewSize,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _devicePreviewSize.width,
                    height: _devicePreviewSize.height,
                    child: screen,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
