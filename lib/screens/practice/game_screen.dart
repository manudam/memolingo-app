import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../helpers/tts_helper.dart';
import '../../models/game_state.dart';
import '../../models/memo_word.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/shake_widget.dart';
import '../../widgets/unique_progress_bar.dart';
import 'game_result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _processingAnswer = false;
  bool _resultPushed = false;
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentWord();
    });
  }

  Future<void> _configureTts(String languageCode) async {
    final user = context.read<UserProvider>().user;
    await configureTts(
      _tts,
      languageCode,
      speechRate: user.speechRate,
      voice: user.voiceOverrides[languageCode],
    );
  }

  Future<void> _speakCurrentWord() async {
    if (!mounted) return;

    final user = context.read<UserProvider>().user;
    if (!user.audioEnabled) return;

    final game = context.read<GameProvider>();
    final currentWord = game.currentCorrectWord;
    if (currentWord == null) return;

    final wordText = currentWord.translationFor(user.targetLanguage);
    if (wordText.isEmpty) return;

    await _configureTts(user.targetLanguage);
    await _tts.stop();
    await _tts.speak(wordText);
  }

  Future<void> _onAnswer() async {
    if (!mounted) return;

    final game = context.read<GameProvider>();

    if (game.state == GameState.won || game.state == GameState.lost) {
      if (_resultPushed) return;
      _resultPushed = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameResultScreen()),
      );
      return;
    }

    await _speakCurrentWord();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Widget _buildOptionsList(BuildContext context, GameProvider game,
      String labelLanguage, bool showLabels) {
    Widget buildOptionWidget(MemoWord option) {
      final isCorrect = option.id == game.currentCorrectWord?.id;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _processingAnswer
              ? null
              : () async {
                  setState(() => _processingAnswer = true);

                  if (isCorrect) {
                    HapticFeedback.lightImpact();
                  } else {
                    HapticFeedback.vibrate();
                    _shakeKey.currentState?.shake();
                  }

                  final wasCombo = game.currentCombo;
                  await game.answer(option);
                  final newCombo = game.currentCombo;
                  if (newCombo > wasCombo &&
                      (newCombo == 3 || newCombo == 5 || newCombo == 10)) {
                    HapticFeedback.heavyImpact();
                  }
                  setState(() => _processingAnswer = false);
                  await _onAnswer();
                },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      'assets/memolingo/images/${option.imageFileName}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey.shade100,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 38,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (showLabels)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(217), // 0.85 * 255
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option.translationFor(labelLanguage),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final options = game.options;
    if (options.isEmpty) return const SizedBox();

    if (options.length <= 2) {
      return Row(
        children: [
          buildOptionWidget(options[0]),
          if (options.length == 2) ...[
            const SizedBox(width: 10),
            buildOptionWidget(options[1]),
          ],
        ],
      );
    }

    final firstRow = options.sublist(0, 2);
    final secondRow = options.sublist(2);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              buildOptionWidget(firstRow[0]),
              const SizedBox(width: 10),
              buildOptionWidget(firstRow[1]),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              buildOptionWidget(secondRow[0]),
              if (secondRow.length > 1) ...[
                const SizedBox(width: 10),
                buildOptionWidget(secondRow[1]),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          game.lives >= 3
              ? 'assets/legacy_icons/ThreeLives.png'
              : game.lives == 2
                  ? 'assets/legacy_icons/TwoLives.png'
                  : 'assets/legacy_icons/OneLife.png',
          height: 24,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (game.currentCombo > 1) ...[
              const Icon(Icons.local_fire_department,
                  color: Colors.orange, size: 20),
              Text(
                '${game.currentCombo}  ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
            Text(
              '${game.currentIndex}/${game.totalQuestions}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.asset(
            'assets/legacy_icons/GameClose.png',
            height: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(GameProvider game) {
    return UniqueProgressBar(
      progress: game.progress,
      secondaryProgress: game.totalQuestions > 0
          ? game.maxProgress / game.totalQuestions
          : 0.0,
    );
  }

  Widget _buildRepeatButton() {
    return GestureDetector(
      onTap: _speakCurrentWord,
      child: Image.asset(
        'assets/legacy_icons/repeat.png',
        height: 80,
        width: 80,
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    GameProvider game,
    String labelLanguage,
    bool showLabels,
  ) {
    final qType = game.currentQuestionType;
    final showRepeatButton = qType == GameQuestionType.standard ||
        qType == GameQuestionType.audioOnly;

    return Column(
      children: [
        _buildHeader(context, game),
        const SizedBox(height: 12),
        _buildProgressBar(game),
        const SizedBox(height: 16),
        Expanded(
          child: _buildOptionsList(context, game, labelLanguage, showLabels),
        ),
        if (showRepeatButton) ...[
          const SizedBox(height: 16),
          _buildRepeatButton(),
        ],
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    GameProvider game,
    String labelLanguage,
    bool showLabels,
  ) {
    final qType = game.currentQuestionType;
    final showRepeatButton = qType == GameQuestionType.standard ||
        qType == GameQuestionType.audioOnly;

    return Column(
      children: [
        _buildHeader(context, game),
        const SizedBox(height: 12),
        _buildProgressBar(game),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 260,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showRepeatButton) _buildRepeatButton(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    _buildOptionsList(context, game, labelLanguage, showLabels),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final user = context.watch<UserProvider>().user;
    final labelLanguage = user.labelLanguage;
    final showLabels = user.showLabels;

    if (game.state == GameState.won || game.state == GameState.lost) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onAnswer());
    }

    if (game.currentCorrectWord == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game')),
        body: const Center(child: Text('Unable to start this game.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFE0AA),
      body: SafeArea(
        child: ShakeWidget(
          key: _shakeKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (width < 600) {
                  return _buildPortraitLayout(
                      context, game, labelLanguage, showLabels);
                } else if (width < 900) {
                  return _buildLandscapeLayout(
                      context, game, labelLanguage, showLabels);
                } else {
                  return Center(
                    child: SizedBox(
                      width: 900,
                      child: _buildLandscapeLayout(
                          context, game, labelLanguage, showLabels),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
