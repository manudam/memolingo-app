import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Thin wrapper around Firebase Analytics.
///
/// Firebase is only registered for Android and iOS in the
/// `memolingo-197dc` project (see [DefaultFirebaseOptions]), so this
/// no-ops everywhere else (macOS/desktop/web) rather than throwing.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  bool get isAvailable => _analytics != null;

  /// A navigator observer that automatically logs `screen_view` events
  /// based on each route's [RouteSettings.name]. Safe to add even when
  /// analytics isn't available (it just won't log anything).
  FirebaseAnalyticsObserver? get observer =>
      _analytics == null ? null : FirebaseAnalyticsObserver(analytics: _analytics!);

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (!_isSupportedPlatform) {
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _analytics = FirebaseAnalytics.instance;
    } catch (e, stack) {
      debugPrint('AnalyticsService: Firebase initialization failed: $e\n$stack');
    }
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  Future<void> logOnboardingComplete() async {
    await _analytics?.logEvent(name: 'onboarding_complete');
  }

  Future<void> logGameStart({
    required String categoryId,
    required String targetLanguage,
    required bool isReview,
  }) async {
    await _analytics?.logEvent(
      name: 'game_start',
      parameters: {
        'category_id': categoryId,
        'target_language': targetLanguage,
        'is_review': isReview,
      },
    );
  }

  Future<void> logGameComplete({
    required String categoryId,
    required bool won,
    required int correct,
    required int incorrect,
    required int maxCombo,
  }) async {
    await _analytics?.logEvent(
      name: 'game_complete',
      parameters: {
        'category_id': categoryId,
        'result': won ? 'won' : 'lost',
        'correct': correct,
        'incorrect': incorrect,
        'max_combo': maxCombo,
      },
    );
  }

  Future<void> logCategoryPurchase({required String productId}) async {
    await _analytics?.logEvent(
      name: 'category_purchase',
      parameters: {'product_id': productId},
    );
  }
}
