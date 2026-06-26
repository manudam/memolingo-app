import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  int? selectedLevel;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final category = library.categoryById(widget.categoryId);

    if (category == null) {
      return const Scaffold(
        body: Center(child: Text('Category not found.')),
      );
    }

    selectedLevel ??= category.levels.first;
    final wordsInSelectedLevel =
        library.wordsInCategoryAndLevel(category, selectedLevel!);

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
                'Select Level',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: category.levels.map((level) {
                  final selected = selectedLevel == level;
                  return ChoiceChip(
                    label: Text('Level $level'),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedLevel = level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Level $selectedLevel contains ${wordsInSelectedLevel.length} words. '
                    'You need at least 4 words to build image choices.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: wordsInSelectedLevel.length < 4
                      ? null
                      : () async {
                          await context.read<GameProvider>().startGame(
                                category: category,
                                level: selectedLevel!,
                              );
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
