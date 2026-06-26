import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/category_pack.dart';
import '../models/game_state.dart';
import '../models/memo_word.dart';
import 'user_provider.dart';

enum GameQuestionType { standard, audioOnly, reverse, spelling }

class GameProvider with ChangeNotifier {
  GameProvider(this._userProvider);

  final UserProvider _userProvider;
  final Random _random = Random();

  CategoryPack? _category;
  int _level = 1;
  GameState _state = GameState.idle;

  List<MemoWord> _questionOrder = <MemoWord>[];
  List<MemoWord> _currentOptions = <MemoWord>[];
  MemoWord? _currentCorrectWord;
  GameQuestionType _currentQuestionType = GameQuestionType.standard;

  int _currentIndex = 0;
  int _lives = 3;
  int _maxProgress = 0;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  int _currentCombo = 0;
  int _maxCombo = 0;

  final Map<String, int> _incorrectByWordId = <String, int>{};

  CategoryPack? get category => _category;
  int get level => _level;
  GameState get state => _state;
  List<MemoWord> get options => List.unmodifiable(_currentOptions);
  MemoWord? get currentCorrectWord => _currentCorrectWord;
  GameQuestionType get currentQuestionType => _currentQuestionType;
  int get currentIndex => _currentIndex;
  int get lives => _lives;
  int get totalQuestions => _questionOrder.length;
  int get maxProgress => _maxProgress;
  int get correctAnswers => _correctAnswers;
  int get incorrectAnswers => _incorrectAnswers;
  int get currentCombo => _currentCombo;

  double get progress {
    if (_questionOrder.isEmpty) {
      return 0;
    }
    return _currentIndex / _questionOrder.length;
  }

  Future<void> startGame({
    required CategoryPack category,
    required int level,
  }) async {
    _category = category;
    _level = level;
    _state = GameState.idle;

    final levelWords = category.words.where((w) => w.level == level).toList();
    if (levelWords.isEmpty) {
      _questionOrder = <MemoWord>[];
      _currentOptions = <MemoWord>[];
      _currentCorrectWord = null;
      notifyListeners();
      return;
    }

    _questionOrder = List<MemoWord>.from(levelWords)..shuffle(_random);
    _currentIndex = 0;
    _lives = 3;
    _maxProgress = 0;
    _correctAnswers = 0;
    _incorrectAnswers = 0;
    _currentCombo = 0;
    _maxCombo = 0;
    _incorrectByWordId.clear();
    _state = GameState.playing;

    _prepareRound();
    notifyListeners();
  }

  Future<void> startReviewGame(List<MemoWord> reviewWords, CategoryPack category) async {
    _category = category;
    _level = 1;
    _state = GameState.idle;

    if (reviewWords.isEmpty) {
      _questionOrder = <MemoWord>[];
      _currentOptions = <MemoWord>[];
      _currentCorrectWord = null;
      notifyListeners();
      return;
    }

    _questionOrder = List<MemoWord>.from(reviewWords)..shuffle(_random);
    _currentIndex = 0;
    _lives = 3; // Keep lives at 3 for review
    _maxProgress = 0;
    _correctAnswers = 0;
    _incorrectAnswers = 0;
    _currentCombo = 0;
    _maxCombo = 0;
    _incorrectByWordId.clear();
    _state = GameState.playing;

    _prepareRound();
    notifyListeners();
  }

  Future<void> restartCurrentGame() async {
    final existingCategory = _category;
    if (existingCategory == null) {
      return;
    }
    await startGame(category: existingCategory, level: _level);
  }

  Future<void> answer(MemoWord selectedWord) async {
    if (_state != GameState.playing || _currentCorrectWord == null) {
      return;
    }

    final correctWord = _currentCorrectWord!;

    if (selectedWord.id == correctWord.id) {
      await _userProvider.applyWordMasteryDelta(correctWord.id, 1);
      _correctAnswers += 1;
      _currentIndex += 1;
      _currentCombo += 1;
      if (_currentCombo > _maxCombo) {
        _maxCombo = _currentCombo;
      }
      
      if (_currentIndex > _maxProgress) {
        _maxProgress = _currentIndex;
      }

      if (_currentIndex >= _questionOrder.length) {
        _state = GameState.won;
        await _userProvider.recordGameFinished(
          won: true,
          maxProgress: _maxProgress,
          totalQuestions: _questionOrder.length,
          correct: _correctAnswers,
          incorrect: _incorrectAnswers,
          maxCombo: _maxCombo,
        );
      } else {
        _prepareRound();
      }

      notifyListeners();
      return;
    }

    await _userProvider.applyWordMasteryDelta(correctWord.id, -3);
    _incorrectAnswers += 1;
    _currentCombo = 0;
    _incorrectByWordId.update(correctWord.id, (v) => v + 1, ifAbsent: () => 1);

    if (_lives <= 1) {
      _lives = 0;
      _state = GameState.lost;
      await _userProvider.recordGameFinished(
        won: false,
        maxProgress: _maxProgress,
        totalQuestions: _questionOrder.length,
        correct: _correctAnswers,
        incorrect: _incorrectAnswers,
        maxCombo: _maxCombo,
      );
      notifyListeners();
      return;
    }

    _lives -= 1;
    // Add the missed word to the end of the queue so they have to try again later
    _questionOrder.add(correctWord);
    _currentIndex += 1;
    _prepareRound();
    notifyListeners();
  }

  Future<void> answerSpelling(String typedWord, String targetLanguage) async {
    if (_state != GameState.playing || _currentCorrectWord == null) {
      return;
    }

    final correctWord = _currentCorrectWord!;
    final expected = correctWord.translationFor(targetLanguage).trim().toLowerCase();
    final actual = typedWord.trim().toLowerCase();

    if (expected == actual) {
      await answer(correctWord); // This is correct, triggers win logic
    } else {
      // Find a dummy wrong word to pass to answer() to trigger loss logic
      final wrongWord = _category!.words.firstWhere((w) => w.id != correctWord.id);
      await answer(wrongWord);
    }
  }

  List<MemoWord> topWordsToReview() {
    final categoryWords = _category?.words ?? <MemoWord>[];

    final sorted = _incorrectByWordId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <MemoWord>[];
    for (final entry in sorted.take(5)) {
      for (final word in categoryWords) {
        if (word.id == entry.key) {
          result.add(word);
          break;
        }
      }
    }

    return result;
  }

  void _prepareRound() {
    if (_questionOrder.isEmpty || _currentIndex >= _questionOrder.length) {
      _currentCorrectWord = null;
      _currentOptions = <MemoWord>[];
      return;
    }

    _currentCorrectWord = _questionOrder[_currentIndex];
    final correct = _currentCorrectWord!;
    
    // Mix question types dynamically to keep the brain engaged
    final randType = _random.nextDouble();
    if (randType < 0.15) {
      _currentQuestionType = GameQuestionType.reverse;
    } else if (randType < 0.30) {
      _currentQuestionType = GameQuestionType.audioOnly;
    } else if (randType < 0.35) {
      _currentQuestionType = GameQuestionType.spelling;
    } else {
      _currentQuestionType = GameQuestionType.standard;
    }

    final sameLevelPool = _category!.words
        .where((w) => w.level == _level && w.id != correct.id)
        .toList();

    final fallbackPool =
        _category!.words.where((w) => w.id != correct.id).toList();

    final distractors = <MemoWord>[];
    _appendRandomUnique(distractors, sameLevelPool, 3);
    if (distractors.length < 3) {
      _appendRandomUnique(distractors, fallbackPool, 3 - distractors.length);
    }

    // Guard for small categories.
    while (distractors.length < 3 && fallbackPool.isNotEmpty) {
      distractors.add(fallbackPool[distractors.length % fallbackPool.length]);
    }

    _currentOptions = <MemoWord>[correct, ...distractors.take(3)]
      ..shuffle(_random);
  }

  void _appendRandomUnique(
      List<MemoWord> target, List<MemoWord> pool, int count) {
    final mutablePool = List<MemoWord>.from(pool);
    while (target.length < count && mutablePool.isNotEmpty) {
      final idx = _random.nextInt(mutablePool.length);
      final candidate = mutablePool.removeAt(idx);
      if (target.any((e) => e.id == candidate.id)) {
        continue;
      }
      target.add(candidate);
    }
  }
}
