class AppUser {
  AppUser({
    Set<String>? unlockedCategoryIds,
    Map<String, Map<String, int>>? wordMasteryByLanguage,
    Map<String, int>? gamesPlayedByLanguage,
    Map<String, int>? gamesWonByLanguage,
    Map<String, int>? bestProgressByLanguage,
    Map<String, int>? totalCorrectByLanguage,
    Map<String, int>? totalIncorrectByLanguage,
    this.audioEnabled = true,
    this.showLabels = false,
    this.targetLanguage = 'es',
    this.nativeLanguage = 'en',
    this.labelLanguage = 'en',
    Map<String, int>? currentXPByLanguage,
    Map<String, int>? currentStreakByLanguage,
    Map<String, DateTime>? lastPlayedDateByLanguage,
    this.onboardingComplete = false,
    Map<String, Map<String, DateTime>>? wordNextReviewByLanguage,
    this.speechRate = 0.42,
    Map<String, Map<String, String>>? voiceOverrides,
  })  : unlockedCategoryIds = unlockedCategoryIds ?? <String>{},
        wordMasteryByLanguage =
            wordMasteryByLanguage ?? <String, Map<String, int>>{},
        wordNextReviewByLanguage =
            wordNextReviewByLanguage ?? <String, Map<String, DateTime>>{},
        bestProgressByLanguage = bestProgressByLanguage ?? <String, int>{},
        gamesPlayedByLanguage = gamesPlayedByLanguage ?? <String, int>{},
        gamesWonByLanguage = gamesWonByLanguage ?? <String, int>{},
        totalCorrectByLanguage = totalCorrectByLanguage ?? <String, int>{},
        totalIncorrectByLanguage = totalIncorrectByLanguage ?? <String, int>{},
        currentXPByLanguage = currentXPByLanguage ?? <String, int>{},
        currentStreakByLanguage = currentStreakByLanguage ?? <String, int>{},
        lastPlayedDateByLanguage =
            lastPlayedDateByLanguage ?? <String, DateTime>{},
        voiceOverrides = voiceOverrides ?? <String, Map<String, String>>{};

  final Set<String> unlockedCategoryIds;

  // Progress and stats are tracked per target language so that switching the
  // language you're learning shows a distinct set of stats and word mastery.
  final Map<String, Map<String, int>> wordMasteryByLanguage;
  final Map<String, Map<String, DateTime>> wordNextReviewByLanguage;
  final Map<String, int> bestProgressByLanguage;
  final Map<String, int> gamesPlayedByLanguage;
  final Map<String, int> gamesWonByLanguage;
  final Map<String, int> totalCorrectByLanguage;
  final Map<String, int> totalIncorrectByLanguage;
  final Map<String, int> currentXPByLanguage;
  final Map<String, int> currentStreakByLanguage;
  final Map<String, DateTime> lastPlayedDateByLanguage;

  bool audioEnabled;
  bool showLabels;
  String targetLanguage;
  String nativeLanguage;
  String labelLanguage;
  bool onboardingComplete;
  double speechRate;
  final Map<String, Map<String, String>> voiceOverrides;

  // --- Views scoped to the language currently being learned. -------------
  // These resolve against [targetLanguage] so the rest of the app can read a
  // single value and always get the stats for the active language.

  Map<String, int> get wordMastery =>
      wordMasteryByLanguage[targetLanguage] ?? const <String, int>{};

  Map<String, DateTime> get wordNextReview =>
      wordNextReviewByLanguage[targetLanguage] ?? const <String, DateTime>{};

  int get gamesPlayed => gamesPlayedByLanguage[targetLanguage] ?? 0;
  int get gamesWon => gamesWonByLanguage[targetLanguage] ?? 0;
  int get bestProgress => bestProgressByLanguage[targetLanguage] ?? 0;
  int get totalCorrect => totalCorrectByLanguage[targetLanguage] ?? 0;
  int get totalIncorrect => totalIncorrectByLanguage[targetLanguage] ?? 0;
  int get currentXP => currentXPByLanguage[targetLanguage] ?? 0;
  int get currentStreak => currentStreakByLanguage[targetLanguage] ?? 0;
  DateTime? get lastPlayedDate => lastPlayedDateByLanguage[targetLanguage];

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
      'wordMasteryByLanguage': wordMasteryByLanguage,
      'wordNextReviewByLanguage': wordNextReviewByLanguage.map(
        (lang, reviews) => MapEntry(
          lang,
          reviews.map((k, v) => MapEntry(k, v.toIso8601String())),
        ),
      ),
      'gamesPlayedByLanguage': gamesPlayedByLanguage,
      'gamesWonByLanguage': gamesWonByLanguage,
      'bestProgressByLanguage': bestProgressByLanguage,
      'totalCorrectByLanguage': totalCorrectByLanguage,
      'totalIncorrectByLanguage': totalIncorrectByLanguage,
      'audioEnabled': audioEnabled,
      'showLabels': showLabels,
      'targetLanguage': targetLanguage,
      'nativeLanguage': nativeLanguage,
      'labelLanguage': labelLanguage,
      'currentXPByLanguage': currentXPByLanguage,
      'currentStreakByLanguage': currentStreakByLanguage,
      'lastPlayedDateByLanguage':
          lastPlayedDateByLanguage.map((k, v) => MapEntry(k, v.toIso8601String())),
      'onboardingComplete': onboardingComplete,
      'speechRate': speechRate,
      'voiceOverrides': voiceOverrides,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final targetLang = map['targetLanguage'] as String? ?? 'es';

    final unlocked = (map['unlockedCategoryIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();

    Map<String, int> parseIntMap(dynamic raw) {
      final result = <String, int>{};
      final src = raw as Map<dynamic, dynamic>? ?? const {};
      for (final entry in src.entries) {
        result[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
      }
      return result;
    }

    Map<String, DateTime> parseDateMap(dynamic raw) {
      final result = <String, DateTime>{};
      final src = raw as Map<dynamic, dynamic>? ?? const {};
      for (final entry in src.entries) {
        final date = DateTime.tryParse(entry.value.toString());
        if (date != null) {
          result[entry.key.toString()] = date;
        }
      }
      return result;
    }

    Map<String, Map<String, int>> parseNestedIntMap(dynamic raw) {
      final result = <String, Map<String, int>>{};
      final src = raw as Map<dynamic, dynamic>? ?? const {};
      for (final entry in src.entries) {
        result[entry.key.toString()] = parseIntMap(entry.value);
      }
      return result;
    }

    Map<String, Map<String, DateTime>> parseNestedDateMap(dynamic raw) {
      final result = <String, Map<String, DateTime>>{};
      final src = raw as Map<dynamic, dynamic>? ?? const {};
      for (final entry in src.entries) {
        result[entry.key.toString()] = parseDateMap(entry.value);
      }
      return result;
    }

    // Migrates a legacy scalar stat into the current language bucket when the
    // new per-language map is absent (users created before this change).
    Map<String, int> migratedIntMap(String newKey, String legacyKey) {
      final result = parseIntMap(map[newKey]);
      if (result.isEmpty) {
        final legacy = (map[legacyKey] as num?)?.toInt() ?? 0;
        if (legacy > 0) {
          result[targetLang] = legacy;
        }
      }
      return result;
    }

    final wordMasteryByLanguage =
        parseNestedIntMap(map['wordMasteryByLanguage']);
    if (wordMasteryByLanguage.isEmpty) {
      final legacy = parseIntMap(map['wordMastery']);
      if (legacy.isNotEmpty) {
        wordMasteryByLanguage[targetLang] = legacy;
      }
    }

    final wordNextReviewByLanguage =
        parseNestedDateMap(map['wordNextReviewByLanguage']);
    if (wordNextReviewByLanguage.isEmpty) {
      final legacy = parseDateMap(map['wordNextReview']);
      if (legacy.isNotEmpty) {
        wordNextReviewByLanguage[targetLang] = legacy;
      }
    }

    final bestProgress = parseIntMap(map['bestProgressByLanguage']);
    // Migration from old single 'bestProgress'
    final legacyBestProgress = (map['bestProgress'] as num?)?.toInt();
    if (legacyBestProgress != null &&
        legacyBestProgress > 0 &&
        bestProgress.isEmpty) {
      bestProgress[targetLang] = legacyBestProgress;
    }

    final lastPlayedDateByLanguage =
        parseDateMap(map['lastPlayedDateByLanguage']);
    if (lastPlayedDateByLanguage.isEmpty && map['lastPlayedDate'] != null) {
      final legacy = DateTime.tryParse(map['lastPlayedDate'].toString());
      if (legacy != null) {
        lastPlayedDateByLanguage[targetLang] = legacy;
      }
    }

    final gamesPlayedByLanguage =
        migratedIntMap('gamesPlayedByLanguage', 'gamesPlayed');

    final rawVoiceOverrides =
        map['voiceOverrides'] as Map<dynamic, dynamic>? ?? const {};
    final voiceOverrides = <String, Map<String, String>>{};
    for (final entry in rawVoiceOverrides.entries) {
      final rawVoice = entry.value as Map<dynamic, dynamic>? ?? const {};
      voiceOverrides[entry.key.toString()] =
          rawVoice.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    final anyGamesPlayed =
        gamesPlayedByLanguage.values.fold<int>(0, (sum, v) => sum + v);

    return AppUser(
      unlockedCategoryIds: unlocked,
      wordMasteryByLanguage: wordMasteryByLanguage,
      wordNextReviewByLanguage: wordNextReviewByLanguage,
      gamesPlayedByLanguage: gamesPlayedByLanguage,
      gamesWonByLanguage: migratedIntMap('gamesWonByLanguage', 'gamesWon'),
      bestProgressByLanguage: bestProgress,
      totalCorrectByLanguage:
          migratedIntMap('totalCorrectByLanguage', 'totalCorrect'),
      totalIncorrectByLanguage:
          migratedIntMap('totalIncorrectByLanguage', 'totalIncorrect'),
      audioEnabled: map['audioEnabled'] as bool? ?? true,
      showLabels: map['showLabels'] as bool? ?? false,
      targetLanguage: targetLang,
      nativeLanguage: map['nativeLanguage'] as String? ?? 'en',
      labelLanguage: map['labelLanguage'] as String? ?? 'en',
      currentXPByLanguage: migratedIntMap('currentXPByLanguage', 'currentXP'),
      currentStreakByLanguage:
          migratedIntMap('currentStreakByLanguage', 'currentStreak'),
      lastPlayedDateByLanguage: lastPlayedDateByLanguage,
      onboardingComplete:
          map['onboardingComplete'] as bool? ?? anyGamesPlayed > 0,
      speechRate: (map['speechRate'] as num?)?.toDouble() ?? 0.42,
      voiceOverrides: voiceOverrides,
    );
  }
}
