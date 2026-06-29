class AppUser {
  AppUser({
    Set<String>? unlockedCategoryIds,
    Map<String, int>? wordMastery,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    Map<String, int>? bestProgressByLanguage,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
    this.audioEnabled = true,
    this.showLabels = true,
    this.targetLanguage = 'es',
    this.nativeLanguage = 'en',
    this.labelLanguage = 'en',
    this.currentXP = 0,
    this.currentStreak = 0,
    this.lastPlayedDate,
    this.onboardingComplete = false,
    Map<String, DateTime>? wordNextReview,
  })  : unlockedCategoryIds = unlockedCategoryIds ?? <String>{},
        wordMastery = wordMastery ?? <String, int>{},
        wordNextReview = wordNextReview ?? <String, DateTime>{},
        bestProgressByLanguage = bestProgressByLanguage ?? <String, int>{};

  final Set<String> unlockedCategoryIds;
  final Map<String, int> wordMastery;
  final Map<String, DateTime> wordNextReview;
  final Map<String, int> bestProgressByLanguage;
  int gamesPlayed;
  int gamesWon;
  int totalCorrect;
  int totalIncorrect;
  bool audioEnabled;
  bool showLabels;
  String targetLanguage;
  String nativeLanguage;
  String labelLanguage;
  int currentXP;
  int currentStreak;
  DateTime? lastPlayedDate;
  bool onboardingComplete;

  int get totalPlayed => totalCorrect + totalIncorrect;

  int get accuracyPercent {
    if (totalPlayed == 0) {
      return 0;
    }
    return ((totalCorrect / totalPlayed) * 100).round();
  }

  int get masteredWordsCount {
    return wordMastery.values.where((value) => value >= 3).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'unlockedCategoryIds': unlockedCategoryIds.toList(),
      'wordMastery': wordMastery,
      'wordNextReview': wordNextReview.map((k, v) => MapEntry(k, v.toIso8601String())),
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'bestProgressByLanguage': bestProgressByLanguage,
      'totalCorrect': totalCorrect,
      'totalIncorrect': totalIncorrect,
      'audioEnabled': audioEnabled,
      'showLabels': showLabels,
      'targetLanguage': targetLanguage,
      'nativeLanguage': nativeLanguage,
      'labelLanguage': labelLanguage,
      'currentXP': currentXP,
      'currentStreak': currentStreak,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'onboardingComplete': onboardingComplete,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final unlocked = (map['unlockedCategoryIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();

    final rawMastery = map['wordMastery'] as Map<dynamic, dynamic>? ?? const {};
    final mastery = <String, int>{};
    for (final entry in rawMastery.entries) {
      mastery[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
    }

    final rawReviews = map['wordNextReview'] as Map<dynamic, dynamic>? ?? const {};
    final nextReviews = <String, DateTime>{};
    for (final entry in rawReviews.entries) {
      final date = DateTime.tryParse(entry.value.toString());
      if (date != null) {
        nextReviews[entry.key.toString()] = date;
      }
    }

    final rawBestProgress = map['bestProgressByLanguage'] as Map<dynamic, dynamic>? ?? const {};
    final bestProgress = <String, int>{};
    for (final entry in rawBestProgress.entries) {
      bestProgress[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
    }

    // Migration from old single 'bestProgress'
    final legacyBestProgress = (map['bestProgress'] as num?)?.toInt();
    if (legacyBestProgress != null && legacyBestProgress > 0 && bestProgress.isEmpty) {
       final targetLang = map['targetLanguage'] as String? ?? 'es';
       bestProgress[targetLang] = legacyBestProgress;
    }

    return AppUser(
      unlockedCategoryIds: unlocked,
      wordMastery: mastery,
      wordNextReview: nextReviews,
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
      gamesWon: (map['gamesWon'] as num?)?.toInt() ?? 0,
      bestProgressByLanguage: bestProgress,
      totalCorrect: (map['totalCorrect'] as num?)?.toInt() ?? 0,
      totalIncorrect: (map['totalIncorrect'] as num?)?.toInt() ?? 0,
      audioEnabled: map['audioEnabled'] as bool? ?? true,
      showLabels: map['showLabels'] as bool? ?? true,
      targetLanguage: map['targetLanguage'] as String? ?? 'es',
      nativeLanguage: map['nativeLanguage'] as String? ?? 'en',
      labelLanguage: map['labelLanguage'] as String? ?? 'en',
      currentXP: (map['currentXP'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      lastPlayedDate: map['lastPlayedDate'] != null
          ? DateTime.tryParse(map['lastPlayedDate'].toString())
          : null,
      onboardingComplete: map['onboardingComplete'] as bool? ??
          (map['gamesPlayed'] as num?)?.toInt() != null &&
              (map['gamesPlayed'] as num).toInt() > 0,
    );
  }
}
