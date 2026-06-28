import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';

class IapService {
  static bool get _supported =>
      Platform.isIOS || Platform.isAndroid || Platform.isMacOS;

  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  final List<ProductDetails> _products = [];
  final Set<String> _purchasedIds = <String>{};
  final StreamController<Set<String>> _purchaseUpdatesController =
      StreamController<Set<String>>.broadcast();

  bool _isInitialized = false;
  bool storeAvailable = false;
  String? error;

  List<ProductDetails> get products => List.unmodifiable(_products);
  Set<String> get purchasedIds => Set.unmodifiable(_purchasedIds);
  Stream<Set<String>> get purchaseUpdates => _purchaseUpdatesController.stream;

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
        },
      );
      _isInitialized = true;
    }

    await _loadProducts(productIds);
    await restorePurchases();
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

    final parameter = PurchaseParam(productDetails: product);
    return _inAppPurchase.buyNonConsumable(purchaseParam: parameter);
  }

  Future<void> restorePurchases() async {
    if (!_supported) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      error = e.toString();
    }
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
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> detailsList) async {
    for (final details in detailsList) {
      if (details.status == PurchaseStatus.purchased ||
          details.status == PurchaseStatus.restored) {
        _purchasedIds.add(details.productID);
        _purchaseUpdatesController.add(Set.unmodifiable(_purchasedIds));
      }

      if (details.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(details);
      }
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _purchaseUpdatesController.close();
  }
}
