class MemoWord {
  MemoWord({
    required this.id,
    required this.categoryName,
    required this.categoryImageName,
    required this.tier,
    required this.imageFileName,
    required this.english,
    required this.translations,
  });

  final String id;
  final String categoryName;
  final String categoryImageName;
  final int tier;
  final String imageFileName;
  final String english;
  final Map<String, String> translations;

  static const tierLabels = <int, String>{
    1: 'Essentials',
    2: 'Everyday',
    3: 'Expanding',
  };

  String get tierLabel => tierLabels[tier] ?? 'Tier $tier';

  String translationFor(String languageCode) {
    return translations[languageCode] ?? english;
  }
}
