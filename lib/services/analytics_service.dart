import 'package:flutter/widgets.dart';

/// Analytics is currently disabled.
///
/// This used to wrap Firebase Analytics. The Firebase dependency has been
/// removed, but the instrumentation points are kept so analytics can be
/// restored later by re-implementing the methods below — call sites and
/// event/parameter names stay as they were.
///
/// Note for whoever restores this: Firebase Analytics only accepts `String`
/// or `num` parameter values. Passing a `bool` compiles fine (the SDK types
/// parameters as `Map<String, Object>`) but throws at runtime.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool get isAvailable => false;

  /// A navigator observer for automatic `screen_view` logging, or null while
  /// analytics is disabled.
  NavigatorObserver? get observer => null;

  Future<void> initialize() async {}

  Future<void> logScreenView(String screenName) async {}

  Future<void> logOnboardingComplete() async {}

  Future<void> logGameStart({
    required String categoryId,
    required String targetLanguage,
    required bool isReview,
  }) async {}

  Future<void> logGameComplete({
    required String categoryId,
    required bool won,
    required int correct,
    required int incorrect,
    required int maxCombo,
  }) async {}

  Future<void> logCategoryPurchase({required String productId}) async {}
}
