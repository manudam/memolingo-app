import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase project configuration for MemoLingo, sourced from the
/// `memolingo-197dc` Firebase project's Android/iOS app registrations.
///
/// Only Android and iOS are registered with Firebase today, so
/// [currentPlatform] throws for any other target. Call sites must check
/// platform support before reading this (see AnalyticsService).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMfY-6OJvcX514HF9bjCG4vsQydCqESYg',
    appId: '1:969062143426:android:36ac5962eb74e4bc',
    messagingSenderId: '969062143426',
    projectId: 'memolingo-197dc',
    storageBucket: 'memolingo-197dc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCA24k884uKQG4x_bF0K_omSAixHKfcPO0',
    appId: '1:969062143426:ios:ccacdf4136118423',
    messagingSenderId: '969062143426',
    projectId: 'memolingo-197dc',
    storageBucket: 'memolingo-197dc.appspot.com',
    iosBundleId: 'com.trianglecarrot.memolingoapp',
  );
}
