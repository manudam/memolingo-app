import 'memo_word.dart';

class CategoryPack {
  CategoryPack({
    required this.id,
    required this.name,
    required this.iconFileName,
    required this.words,
    required this.productId,
    required this.isFree,
    this.owned = false,
  });

  final String id;
  final String name;
  final String iconFileName;
  final List<MemoWord> words;
  final String productId;
  final bool isFree;
  bool owned;

  List<int> get tiers {
    final values = words.map((w) => w.tier).toSet().toList()..sort();
    return values;
  }

  int masteryPercent(Map<String, int> masteryByWordId) {
    if (words.isEmpty) {
      return 0;
    }

    final total = words
        .map((w) => (masteryByWordId[w.id] ?? 0).clamp(0, 3))
        .reduce((a, b) => a + b);
    final max = words.length * 3;
    return ((total / max) * 100).round();
  }
}
