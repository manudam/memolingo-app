import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import 'game_screen.dart';
import 'practice_screen.dart';

class GameResultScreen extends StatefulWidget {
  const GameResultScreen({super.key});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late ConfettiController _confettiController;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      if (game.state == GameState.won) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final won = game.state == GameState.won;
    final reviewWords = game.topWordsToReview();

    return Scaffold(
      appBar: AppBar(
        title: Text(won ? 'Level Complete' : 'Game Over'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          won
                              ? 'assets/memolingo/nostalgia/congrats_cat.png'
                              : 'assets/memolingo/nostalgia/game_over_cat.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        won ? 'Nice one!' : 'Try again!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (won) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${(game.correctAnswers * 10) + 50} XP',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        won
                            ? 'You completed ${game.totalQuestions} words in this level.'
                            : 'Best run: ${game.maxProgress}/${game.totalQuestions} words.',
                        style: TextStyle(color: Colors.grey.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(title: 'Correct', value: game.correctAnswers),
                      _Stat(title: 'Wrong', value: game.incorrectAnswers),
                      _Stat(title: 'Lives Left', value: game.lives),
                    ],
                  ),
                ),
              ),
              if (reviewWords.isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Words To Review',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...reviewWords.map((word) {
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/memolingo/images/${word.imageFileName}',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(word.translationFor(context.read<UserProvider>().user.targetLanguage)),
                            subtitle: Text('Level ${word.level}'),
                            trailing: Icon(Icons.volume_up_rounded, color: Colors.grey.shade600, size: 20),
                            onTap: () async {
                              final userProvider = context.read<UserProvider>();
                              if (userProvider.user.audioEnabled) {
                                final lang = userProvider.user.targetLanguage;
                                await _flutterTts.setLanguage(lang);
                                await _flutterTts.speak(word.translationFor(lang));
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<GameProvider>().restartCurrentGame();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const PracticeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back To Practice'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
        ),
      ),
    ],
  ),
);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
