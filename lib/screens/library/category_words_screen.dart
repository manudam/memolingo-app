import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';
import '../../providers/user_provider.dart';

class CategoryWordsScreen extends StatelessWidget {
  const CategoryWordsScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final user = context.watch<UserProvider>().user;
    final category = library.categoryById(categoryId);

    if (category == null) {
      return const Scaffold(
        body: Center(child: Text('Category not found.')),
      );
    }

    final words = [...category.words]
      ..sort((a, b) => a.translationFor(context.read<UserProvider>().user.targetLanguage).compareTo(b.translationFor(context.read<UserProvider>().user.targetLanguage)));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          final mastery = (user.wordMastery[word.id] ?? 0).clamp(0, 3);
          return Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/memolingo/images/${word.imageFileName}',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(word.translationFor(context.read<UserProvider>().user.targetLanguage)),
              subtitle: Text('Level ${word.level} · ${_masteryLabel(mastery)}'),
              trailing: _MasteryDots(level: mastery),
            ),
          );
        },
      ),
    );
  }

  String _masteryLabel(int level) {
    switch (level) {
      case 3:
        return 'Gold';
      case 2:
        return 'Silver';
      case 1:
        return 'Bronze';
      default:
        return 'New';
    }
  }
}

class _MasteryDots extends StatelessWidget {
  const _MasteryDots({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final enabled = index < level;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF2563EB) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
