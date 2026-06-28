import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../helpers/string_helpers.dart';
import '../models/category_pack.dart';
import '../models/memo_word.dart';
import '../services/iap_service.dart';
import 'user_provider.dart';

class LibraryProvider with ChangeNotifier {
  LibraryProvider(this._iapService, this._userProvider);

  static const String csvAssetPath =
      'assets/memolingo/data/words_list_full.csv';
  static const String bundleProductId = 'memolingo_all_categories';

  final IapService _iapService;
  final UserProvider _userProvider;

  final List<CategoryPack> _categories = [];
  final List<MemoWord> _allWords = [];

  bool _loading = false;
  bool _initialized = false;
  StreamSubscription<Set<String>>? _purchaseSub;

  List<CategoryPack> get categories => List.unmodifiable(_categories);
  List<MemoWord> get allWords => List.unmodifiable(_allWords);
  bool get isLoading => _loading;
  bool get isInitialized => _initialized;

  bool get hasBundlePurchased => _iapService.isPurchased(bundleProductId);

  Future<void> initialize() async {
    if (_initialized || _loading) {
      return;
    }

    _loading = true;
    notifyListeners();

    await _loadWordsAndCategories();

    final productIds = <String>{bundleProductId};
    for (final category in _categories.where((c) => !c.isFree)) {
      productIds.add(category.productId);
    }

    await _iapService.initialize(productIds);

    _purchaseSub ??= _iapService.purchaseUpdates.listen((_) async {
      await refreshOwnershipFromStore();
    });

    await refreshOwnershipFromStore();

    _initialized = true;
    _loading = false;
    notifyListeners();
  }

  CategoryPack? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  List<CategoryPack> ownedCategories() {
    return _categories.where((c) => c.owned).toList();
  }

  List<MemoWord> wordsInCategory(CategoryPack category) {
    return _allWords.where((w) => w.categoryName == category.name).toList();
  }

  List<MemoWord> wordsInCategoryAndTier(CategoryPack category, int tier) {
    return category.words.where((w) => w.tier == tier).toList();
  }

  String priceFor(CategoryPack category) {
    return _iapService.productById(category.productId)?.price ?? r'$1.99';
  }

  String bundlePrice() {
    return _iapService.productById(bundleProductId)?.price ?? r'$9.99';
  }

  Future<bool> purchaseCategory(CategoryPack category) async {
    if (category.owned) {
      return true;
    }

    if (!_iapService.storeAvailable ||
        _iapService.productById(category.productId) == null) {
      // Local fallback for development environments without store metadata.
      await _userProvider.unlockCategory(category.id);
      await refreshOwnershipFromStore();
      return true;
    }

    final started = await _iapService.buyProduct(category.productId);
    if (!started) {
      return false;
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    await refreshOwnershipFromStore();
    return category.owned;
  }

  Future<bool> purchaseAllCategories() async {
    if (hasBundlePurchased) {
      return true;
    }

    if (!_iapService.storeAvailable ||
        _iapService.productById(bundleProductId) == null) {
      await _userProvider.unlockCategories(
          _categories.where((c) => !c.isFree).map((c) => c.id));
      await refreshOwnershipFromStore();
      return true;
    }

    final started = await _iapService.buyProduct(bundleProductId);
    if (!started) {
      return false;
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    await refreshOwnershipFromStore();
    return hasBundlePurchased;
  }

  Future<void> restorePurchases() async {
    await _iapService.restorePurchases();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await refreshOwnershipFromStore();
  }

  Future<void> refreshOwnershipFromStore() async {
    final unlocked = <String>{..._userProvider.user.unlockedCategoryIds};

    if (hasBundlePurchased) {
      unlocked.addAll(_categories.where((c) => !c.isFree).map((c) => c.id));
    }

    for (final category in _categories.where((c) => !c.isFree)) {
      if (_iapService.isPurchased(category.productId)) {
        unlocked.add(category.id);
      }
    }

    if (unlocked.length != _userProvider.user.unlockedCategoryIds.length) {
      await _userProvider.unlockCategories(unlocked);
    }

    for (final category in _categories) {
      category.owned = category.isFree || unlocked.contains(category.id);
    }

    notifyListeners();
  }

  Future<void> _loadWordsAndCategories() async {
    _categories.clear();
    _allWords.clear();

    final csvRaw = await rootBundle.loadString(csvAssetPath);
    final rows = const CsvToListConverter(eol: '\n').convert(csvRaw);

    if (rows.length <= 1) {
      return;
    }

    final byCategory = <String, List<MemoWord>>{};
    final categoryIcons = <String, String>{};
    final categoryWordCounts = <String, int>{};
    final categorySizes = <String, int>{};

    // First pass: count words per category for tier assignment.
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 14) continue;
      final name = row[0].toString().trim();
      categorySizes[name] = (categorySizes[name] ?? 0) + 1;
    }

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 14) {
        continue;
      }

      final categoryName = row[0].toString().trim();
      final categoryImage = row[1].toString().trim();
      final imageFile = row[3].toString().trim();
      final english = row[4].toString().trim();

      // Frequency-based tiers: split each category into 3 tiers.
      final currentCount = categoryWordCounts[categoryName] ?? 0;
      final total = categorySizes[categoryName] ?? 1;
      final tierSize = (total / 3).ceil();
      final tier = (currentCount ~/ tierSize) + 1;
      categoryWordCounts[categoryName] = currentCount + 1;

      final word = MemoWord(
        id: '${slugify(categoryName)}-${imageFile.toLowerCase()}',
        categoryName: categoryName,
        categoryImageName: categoryImage,
        tier: tier.clamp(1, 3),
        imageFileName: imageFile,
        english: english,
        translations: {
          'fr': row[5].toString(),
          'nl': row[6].toString(),
          'de': row[7].toString(),
          'it': row[8].toString(),
          'es': row[9].toString(),
          'ru': row[10].toString(),
          'ko': row[11].toString(),
          'zh-CN': row[12].toString(),
          'ja': row[13].toString(),
        },
      );

      _allWords.add(word);
      byCategory.putIfAbsent(categoryName, () => <MemoWord>[]).add(word);
      categoryIcons[categoryName] = categoryImage;
    }

    final defaultFreeId = slugify('everyday objects');
    final categoryIds = byCategory.keys.map(slugify).toList();
    final freeCategoryId =
        categoryIds.contains(defaultFreeId) ? defaultFreeId : categoryIds.first;

    for (final entry in byCategory.entries) {
      final id = slugify(entry.key);
      _categories.add(
        CategoryPack(
          id: id,
          name: entry.key,
          iconFileName: categoryIcons[entry.key] ?? '',
          words: entry.value,
          productId: 'memolingo_category_${id.replaceAll('-', '_')}',
          isFree: id == freeCategoryId,
          owned: id == freeCategoryId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
