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

  Future<void> applyWordMasteryDelta(String wordId, int delta) async {
    final current = _user.wordMastery[wordId] ?? 0;
    final next = (current + delta).clamp(0, 99);
    _user.wordMastery[wordId] = next;

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
      
      _user.wordNextReview[wordId] = DateTime.now().add(Duration(days: daysToAdd));
    } else {
      // If answered incorrectly, reset review to today so they review it soon.
      _user.wordNextReview[wordId] = DateTime.now();
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
    _user.gamesPlayed += 1;
    if (won) {
      _user.gamesWon += 1;
    }

    final currentBest = _user.bestProgressByLanguage[_user.targetLanguage] ?? 0;
    _user.bestProgressByLanguage[_user.targetLanguage] =
        maxProgress > currentBest ? maxProgress : currentBest;
    _user.totalCorrect += correct;
    _user.totalIncorrect += incorrect;

    // Reward full completion with a best-progress bump to total questions.
    if (won && totalQuestions > (_user.bestProgressByLanguage[_user.targetLanguage] ?? 0)) {
      _user.bestProgressByLanguage[_user.targetLanguage] = totalQuestions;
    }

    // Gamification: XP with Combo Multiplier
    final baseXP = (correct * 10) + (won ? 50 : 0);
    final comboMultiplier = 1.0 + (maxCombo * 0.1); // e.g., 5 combo = 1.5x XP
    final xpEarned = (baseXP * comboMultiplier).round();
    _user.currentXP += xpEarned;

    // Gamification: Streaks
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_user.lastPlayedDate != null) {
      final lastPlayed = _user.lastPlayedDate!;
      final lastPlayedDay = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
      
      final difference = today.difference(lastPlayedDay).inDays;
      if (difference == 1) {
        _user.currentStreak += 1;
      } else if (difference > 1) {
        _user.currentStreak = 1; // reset streak
      }
      // If difference == 0, it means they already played today, so streak stays the same.
    } else {
      _user.currentStreak = 1;
    }
    _user.lastPlayedDate = now;

    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveUser(_user);
    notifyListeners();
  }
}
