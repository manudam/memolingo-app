import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/memo_word.dart';
import '../../providers/game_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/category_icon.dart';
import 'game_screen.dart';

class GameStartScreen extends StatefulWidget {
  const GameStartScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<GameStartScreen> createState() => _GameStartScreenState();
}

class _GameStartScreenState extends State<GameStartScreen> {
  bool _starting = false;

  Future<void> _playTier(int tier) async {
    if (_starting) return;
    final library = context.read<LibraryProvider>();
    final category = library.categoryById(widget.categoryId);
    if (category == null) return;
    final words = library.wordsInCategoryAndTier(category, tier);
    if (words.length < 4) return;

    setState(() => _starting = true);
    await context.read<GameProvider>().startGame(
          category: category,
          tier: tier,
        );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(),
        fullscreenDialog: true,
      ),
    );
    setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final category = library.categoryById(widget.categoryId);

    if (category == null) {
      return const Scaffold(
        body: Center(child: Text('Category not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Game'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CategoryIcon(
                          categoryName: category.name,
                          size: 56,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${category.words.length} total words',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Difficulty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...category.tiers.map((tier) {
                final label = MemoWord.tierLabels[tier] ?? 'Tier $tier';
                final count = category.words.where((w) => w.tier == tier).length;
                final hasEnoughWords = count >= 4;
                final descriptions = <int, String>{
                  1: 'The most common words to get you started',
                  2: 'Useful words for daily conversations',
                  3: 'Less common words to expand your vocabulary',
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: hasEnoughWords && !_starting ? () => _playTier(tier) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              tier == 1 ? Icons.star_rounded : tier == 2 ? Icons.trending_up_rounded : Icons.rocket_launch_rounded,
                              color: hasEnoughWords ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: hasEnoughWords ? null : Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    descriptions[tier] ?? '',
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$count words',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                ),
                                if (hasEnoughWords)
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  )
                                else
                                  Text(
                                    'Not enough words',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
