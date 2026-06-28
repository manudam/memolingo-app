import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'providers/library_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'services/iap_service.dart';
import 'services/local_storage_service.dart';

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

final locator = GetIt.I;

void setupLocator() {
  if (!locator.isRegistered<LocalStorageService>()) {
    locator.registerLazySingleton<LocalStorageService>(LocalStorageService.new);
  }
  if (!locator.isRegistered<IapService>()) {
    locator.registerLazySingleton<IapService>(IapService.new);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MemoLingoApp());
}

class MemoLingoApp extends StatelessWidget {
  const MemoLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(locator<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => LibraryProvider(
              locator<IapService>(), context.read<UserProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) => GameProvider(context.read<UserProvider>()),
        ),
      ],
      child: MaterialApp(
        title: 'MemoLingo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              textStyle: const TextStyle(
                fontFamily: 'CaviarDreams',
                fontSize: 20,
              ),
            ),
          ),
        ),
        builder: _isDesktop
            ? (context, child) {
                return Container(
                  color: const Color(0xFF3D4D9D),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: child,
                    ),
                  ),
                );
              }
            : null,
        home: const SplashScreen(),
      ),
    );
  }
}
