import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/local_storage_service.dart';

class UserProvider with ChangeNotifier {
  UserProvider(this._storageService);

  final LocalStorageService _storageService;

  AppUser _user = AppUser();
  bool _initialized = false;

  AppUser get user => _user;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _user = await _storageService.loadUser();
    _initialized = true;
    notifyListeners();
  }

  Future<void> unlockCategory(String categoryId) async {
    _user.unlockedCategoryIds.add(categoryId);
    await _persist();
  }

  Future<void> unlockCategories(Iterable<String> categoryIds) async {
    _user.unlockedCategoryIds.addAll(categoryIds);
    await _persist();
  }

  Future<void> completeOnboarding() async {
    _user.onboardingComplete = true;
    await _persist();
  }

  Future<void> setAudioEnabled(bool enabled) async {
    _user.audioEnabled = enabled;
    await _persist();
  }

  Future<void> setShowLabels(bool show) async {
    _user.showLabels = show;
    await _persist();
  }

  Future<void> setTargetLanguage(String languageCode) async {
    _user.targetLanguage = languageCode;
    await _persist();
  }

  Future<void> setNativeLanguage(String languageCode) async {
    _user.nativeLanguage = languageCode;
    await _persist();
  }

  Future<void> setLabelLanguage(String languageCode) async {
    _user.labelLanguage = languageCode;
    await _persist();
  }

  Future<void> setSpeechRate(double rate) async {
    _user.speechRate = rate;
    await _persist();
  }

  Future<void> setVoiceOverride(
      String languageCode, Map<String, String>? voice) async {
    if (voice == null) {
      _user.voiceOverrides.remove(languageCode);
    } else {
      _user.voiceOverrides[languageCode] = voice;
    }
    await _persist();
  }

  Future<void> applyWordMasteryDelta(String wordId, int delta) async {
    final lang = _user.targetLanguage;
    final masteryMap =
        _user.wordMasteryByLanguage.putIfAbsent(lang, () => <String, int>{});
    final reviewMap = _user.wordNextReviewByLanguage
        .putIfAbsent(lang, () => <String, DateTime>{});

    final current = masteryMap[wordId] ?? 0;
    final next = (current + delta).clamp(0, 99);
    masteryMap[wordId] = next;

    // Spaced Repetition System (SRS) Update
    if (delta > 0) {
      // Calculate next review based on the new mastery level
      // E.g., Level 1 -> 1 day, Level 2 -> 3 days, Level 3 -> 7 days, etc.
      int daysToAdd = 1;
      if (next >= 5) {
        daysToAdd = 30;
      } else if (next >= 4) {
        daysToAdd = 14;
      } else if (next >= 3) {
        daysToAdd = 7;
      } else if (next >= 2) {
        daysToAdd = 3;
      }

      reviewMap[wordId] = DateTime.now().add(Duration(days: daysToAdd));
    } else {
      // If answered incorrectly, reset review to today so they review it soon.
      reviewMap[wordId] = DateTime.now();
    }

    await _persist();
  }

  Future<void> recordGameFinished({
    required bool won,
    required int maxProgress,
    required int totalQuestions,
    required int correct,
    required int incorrect,
    required int maxCombo,
  }) async {
    final lang = _user.targetLanguage;

    _user.gamesPlayedByLanguage[lang] =
        (_user.gamesPlayedByLanguage[lang] ?? 0) + 1;
    if (won) {
      _user.gamesWonByLanguage[lang] =
          (_user.gamesWonByLanguage[lang] ?? 0) + 1;
    }

    final currentBest = _user.bestProgressByLanguage[lang] ?? 0;
    _user.bestProgressByLanguage[lang] =
        maxProgress > currentBest ? maxProgress : currentBest;
    _user.totalCorrectByLanguage[lang] =
        (_user.totalCorrectByLanguage[lang] ?? 0) + correct;
    _user.totalIncorrectByLanguage[lang] =
        (_user.totalIncorrectByLanguage[lang] ?? 0) + incorrect;

    // Reward full completion with a best-progress bump to total questions.
    if (won && totalQuestions > (_user.bestProgressByLanguage[lang] ?? 0)) {
      _user.bestProgressByLanguage[lang] = totalQuestions;
    }

    // Gamification: XP with Combo Multiplier
    final baseXP = (correct * 10) + (won ? 50 : 0);
    final comboMultiplier = 1.0 + (maxCombo * 0.1); // e.g., 5 combo = 1.5x XP
    final xpEarned = (baseXP * comboMultiplier).round();
    _user.currentXPByLanguage[lang] =
        (_user.currentXPByLanguage[lang] ?? 0) + xpEarned;

    // Gamification: Streaks
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastPlayed = _user.lastPlayedDateByLanguage[lang];
    if (lastPlayed != null) {
      final lastPlayedDay =
          DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);

      final difference = today.difference(lastPlayedDay).inDays;
      if (difference == 1) {
        _user.currentStreakByLanguage[lang] =
            (_user.currentStreakByLanguage[lang] ?? 0) + 1;
      } else if (difference > 1) {
        _user.currentStreakByLanguage[lang] = 1; // reset streak
      }
      // If difference == 0, it means they already played today, so streak stays the same.
    } else {
      _user.currentStreakByLanguage[lang] = 1;
    }
    _user.lastPlayedDateByLanguage[lang] = now;

    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveUser(_user);
    notifyListeners();
  }
}
