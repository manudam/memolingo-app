class MemoWord {
  MemoWord({
    required this.id,
    required this.categoryName,
    required this.categoryImageName,
    required this.level,
    required this.imageFileName,
    required this.english,
    required this.translations,
  });

  final String id;
  final String categoryName;
  final String categoryImageName;
  final int level;
  final String imageFileName;
  final String english;
  final Map<String, String> translations;

  String translationFor(String languageCode) {
    return translations[languageCode] ?? english;
  }
}
