import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';

import 'analytics_service.dart';

/// Outcome of an explicit, user-initiated "Restore Purchases" request.
class RestoreResult {
  const RestoreResult({
    required this.success,
    required this.restoredCount,
    this.message,
  });

  final bool success;
  final int restoredCount;
  final String? message;

  bool get restoredAnything => restoredCount > 0;
}

class IapService {
  static bool get _supported =>
      Platform.isIOS || Platform.isAndroid || Platform.isMacOS;

  /// The store delivers restored transactions asynchronously and never signals
  /// that it is done, so a restore is considered settled once this long has
  /// passed without any further transaction arriving.
  static const Duration _restoreQuietPeriod = Duration(milliseconds: 1500);

  /// Hard upper bound so the UI can never hang on a silent store.
  static const Duration _restoreTimeout = Duration(seconds: 15);

  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  final List<ProductDetails> _products = [];
  final Set<String> _purchasedIds = <String>{};
  final Map<String, Completer<bool>> _pendingPurchases =
      <String, Completer<bool>>{};
  final StreamController<Set<String>> _purchaseUpdatesController =
      StreamController<Set<String>>.broadcast();

  final Set<String> _restoredThisRun = <String>{};
  Completer<void>? _restoreSettled;
  Timer? _restoreQuietTimer;
  String? _restoreError;
  bool _restoreInProgress = false;

  bool _isInitialized = false;
  bool storeAvailable = false;
  String? error;

  List<ProductDetails> get products => List.unmodifiable(_products);
  Set<String> get purchasedIds => Set.unmodifiable(_purchasedIds);
  Stream<Set<String>> get purchaseUpdates => _purchaseUpdatesController.stream;
  bool get isRestoring => _restoreInProgress;

  Future<void> initialize(Set<String> productIds) async {
    if (!_supported) {
      storeAvailable = false;
      return;
    }

    if (productIds.isEmpty) {
      return;
    }

    if (!_isInitialized) {
      _inAppPurchase = InAppPurchase.instance;
      _purchaseSub = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object e) {
          error = e.toString();
          if (_restoreInProgress) {
            _restoreError = e.toString();
            _scheduleRestoreSettlement();
          }
        },
      );
      _isInitialized = true;
    }

    await _loadProducts(productIds);
    await _requestRestoreFromStore();
  }

  ProductDetails? productById(String productId) {
    for (final product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  bool isPurchased(String productId) {
    return _purchasedIds.contains(productId);
  }

  Future<bool> buyProduct(String productId) async {
    if (!_supported) return false;

    final product = productById(productId);
    if (product == null) {
      error = 'Product not found: $productId';
      return false;
    }

    // A `true` result here only means that the store sheet opened. Wait for the
    // purchase stream before reporting success or unlocking any content.
    if (_pendingPurchases.containsKey(productId)) {
      error = 'A purchase for this product is already in progress.';
      return false;
    }

    final completion = Completer<bool>();
    _pendingPurchases[productId] = completion;

    try {
      final started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        _pendingPurchases.remove(productId);
        return false;
      }
      return completion.future;
    } catch (e) {
      _pendingPurchases.remove(productId);
      error = e.toString();
      return false;
    }
  }

  /// Restores previously bought products in response to an explicit tap on a
  /// "Restore Purchases" control. Unlike [_requestRestoreFromStore] this waits
  /// for the restored transactions to come back so the caller can tell the user
  /// what actually happened.
  Future<RestoreResult> restorePurchases() async {
    if (!_supported || !_isInitialized) {
      return const RestoreResult(
        success: false,
        restoredCount: 0,
        message: 'In-app purchases are not available on this device.',
      );
    }

    if (_restoreInProgress) {
      return const RestoreResult(
        success: false,
        restoredCount: 0,
        message: 'A restore is already in progress.',
      );
    }

    if (!storeAvailable) {
      storeAvailable = await _inAppPurchase.isAvailable();
      if (!storeAvailable) {
        return const RestoreResult(
          success: false,
          restoredCount: 0,
          message: 'The App Store is unavailable right now. '
              'Please check your connection and try again.',
        );
      }
    }

    _restoreInProgress = true;
    _restoredThisRun.clear();
    _restoreError = null;
    final settled = Completer<void>();
    _restoreSettled = settled;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      error = e.toString();
      _finishRestore();
      return RestoreResult(
        success: false,
        restoredCount: 0,
        message: 'Restore failed: $e',
      );
    }

    _scheduleRestoreSettlement();

    try {
      await settled.future.timeout(_restoreTimeout);
    } on TimeoutException {
      // Report whatever arrived before the timeout rather than hanging.
    }

    final restoredCount = _restoredThisRun.length;
    final restoreError = _restoreError;
    _finishRestore();

    if (restoredCount == 0 && restoreError != null) {
      return RestoreResult(
        success: false,
        restoredCount: 0,
        message: restoreError,
      );
    }

    return RestoreResult(success: true, restoredCount: restoredCount);
  }

  /// Fire-and-forget restore used while starting up, to keep ownership in sync
  /// without blocking the splash screen.
  Future<void> _requestRestoreFromStore() async {
    if (!_supported || !_isInitialized) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      error = e.toString();
    }
  }

  void _scheduleRestoreSettlement() {
    if (!_restoreInProgress) return;

    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = Timer(_restoreQuietPeriod, () {
      final settled = _restoreSettled;
      if (settled != null && !settled.isCompleted) {
        settled.complete();
      }
    });
  }

  void _finishRestore() {
    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = null;
    final settled = _restoreSettled;
    if (settled != null && !settled.isCompleted) {
      settled.complete();
    }
    _restoreSettled = null;
    _restoreInProgress = false;
  }

  Future<void> _loadProducts(Set<String> productIds) async {
    if (!_supported) return;

    storeAvailable = await _inAppPurchase.isAvailable();
    if (!storeAvailable) {
      error = 'In-app purchases are unavailable on this device.';
      _products.clear();
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(productIds);
    _products
      ..clear()
      ..addAll(response.productDetails);

    if (response.error != null) {
      error = response.error!.message;
    } else if (response.notFoundIDs.isNotEmpty) {
      error = 'Products are not configured in the store: '
          '${response.notFoundIDs.join(', ')}';
    } else {
      error = null;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> detailsList) async {
    for (final details in detailsList) {
      if (details.status == PurchaseStatus.purchased ||
          details.status == PurchaseStatus.restored) {
        if (details.status == PurchaseStatus.purchased) {
          unawaited(AnalyticsService.instance
              .logCategoryPurchase(productId: details.productID));
        }
        _purchasedIds.add(details.productID);
        if (_restoreInProgress) {
          _restoredThisRun.add(details.productID);
          _scheduleRestoreSettlement();
        }
        _purchaseUpdatesController.add(Set.unmodifiable(_purchasedIds));
        _completePendingPurchase(details.productID, true);
      } else if (details.status == PurchaseStatus.error) {
        error = details.error?.message ?? 'Purchase failed.';
        if (_restoreInProgress) {
          _restoreError = error;
          _scheduleRestoreSettlement();
        }
        _completePendingPurchase(details.productID, false);
      } else if (details.status == PurchaseStatus.canceled) {
        if (_restoreInProgress) {
          _scheduleRestoreSettlement();
        }
        _completePendingPurchase(details.productID, false);
      }

      if (details.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(details);
      }
    }
  }

  void _completePendingPurchase(String productId, bool succeeded) {
    final completion = _pendingPurchases.remove(productId);
    if (completion != null && !completion.isCompleted) {
      completion.complete(succeeded);
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _finishRestore();
    for (final completion in _pendingPurchases.values) {
      if (!completion.isCompleted) {
        completion.complete(false);
      }
    }
    _pendingPurchases.clear();
    _purchaseUpdatesController.close();
  }
}
