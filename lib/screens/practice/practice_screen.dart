import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_pack.dart';
import '../../providers/library_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/memo_word.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/category_icon.dart';
import 'game_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final user = context.watch<UserProvider>().user;

    if (!library.isInitialized || library.isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final ownedCategories = library.ownedCategories();

    // SRS: Calculate due words
    final dueWords = <MemoWord>[];
    final now = DateTime.now();
    for (final category in ownedCategories) {
      for (final word in category.words) {
        final nextReview = user.wordNextReview[word.id];
        if (nextReview != null && nextReview.isBefore(now)) {
          dueWords.add(word);
        }
      }
    }

    // Number of items in the list:
    // Categories + 1 (for the header at the top)
    final itemCount = ownedCategories.length + 1;

    return Scaffold(
      body: SafeArea(
        child: ownedCategories.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _HeaderCard(
                        ownedCount: 0,
                        streak: user.currentStreak,
                        xp: user.currentXP),
                    const Spacer(),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No categories unlocked yet. Go to Library to unlock packs.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              )
            : ListView.builder(
                reverse: true, // Scroll starts from bottom and goes up
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // Index 0 is the BOTTOM.
                  // Since we want the header at the TOP, it's at index = itemCount - 1.
                  if (index == itemCount - 1) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _HeaderCard(
                            ownedCount: ownedCategories.length,
                            streak: user.currentStreak,
                            xp: user.currentXP,
                          ),
                          if (dueWords.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Card(
                              color: Colors.amber.shade50,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                leading: const Icon(Icons.psychology,
                                    size: 40, color: Colors.orange),
                                title: const Text('Daily Review',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                subtitle: Text(
                                    '${dueWords.length} words due for review'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  onPressed: () async {
                                    final game = context.read<GameProvider>();
                                    await game.startReviewGame(
                                        List.from(dueWords),
                                        ownedCategories.first);
                                    if (context.mounted) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => const GameScreen()),
                                      );
                                    }
                                  },
                                  child: const Text('Review',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }

                  // A category node.
                  final category = ownedCategories[index];
                  final isLast =
                      index == ownedCategories.length - 1; // Top-most node
                  final mastery = category.masteryPercent(user.wordMastery);

                  return _JourneyNode(
                    category: category,
                    index: index,
                    isLastNode: isLast,
                    mastery: mastery,
                  );
                },
              ),
      ),
      bottomNavigationBar: const BottomBar(selectedIndex: 0),
    );
  }
}

class _JourneyNode extends StatelessWidget {
  const _JourneyNode({
    required this.category,
    required this.index,
    required this.isLastNode,
    required this.mastery,
  });

  final CategoryPack category;
  final int index;
  final bool isLastNode;
  final int mastery;

  @override
  Widget build(BuildContext context) {
    const double nodeHeight = 160.0;
    const double buttonSize = 80.0;

    return SizedBox(
      height: nodeHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final maxSwing = (availableWidth / 2) - (buttonSize / 2) - 20;
          final swing = maxSwing.clamp(0.0, 80.0);
          final currentOffset = sin(index * 1.5) * swing;
          final nextOffset = sin((index + 1) * 1.5) * swing;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (!isLastNode)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      currentXOffset: currentOffset,
                      nextXOffset: nextOffset,
                    ),
                  ),
                ),
              Positioned(
                left: (availableWidth / 2) + currentOffset - (buttonSize / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (category.words.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Not enough words to start a game.'),
                            ),
                          );
                          return;
                        }

                        final game = context.read<GameProvider>();
                        await game.startGame(category: category);

                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: mastery == 100
                                    ? Colors.amber
                                    : Colors.blue.shade300,
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CategoryIcon(
                                categoryName: category.name,
                                size: 80,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (mastery > 0)
                Positioned(
                  left: (availableWidth / 2) + currentOffset + (buttonSize / 4),
                  top: nodeHeight / 2 - (buttonSize / 2) - 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          mastery == 100 ? Colors.amber : Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      mastery == 100 ? '⭐' : '$mastery%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final double currentXOffset;
  final double nextXOffset;

  _PathPainter({required this.currentXOffset, required this.nextXOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width / 2 + currentXOffset;
    final startY = size.height / 2;

    final endX = size.width / 2 + nextXOffset;
    final endY =
        -size.height / 2; // the center of the next node (which is drawn above)

    path.moveTo(startX, startY);

    // Draw a smooth bezier curve between the two nodes
    path.cubicTo(
        startX,
        startY - size.height / 2, // Control point 1 (pulls curve up from start)
        endX,
        endY + size.height / 2, // Control point 2 (pulls curve down from end)
        endX,
        endY // End point
        );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.currentXOffset != currentXOffset ||
        oldDelegate.nextXOffset != nextXOffset;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.ownedCount,
    required this.streak,
    required this.xp,
  });

  final int ownedCount;
  final int streak;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/memolingo/nostalgia/loading_cat.png',
                width: 54,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MemoLingo Journey',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ownedCount categories unlocked',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥'),
                            const SizedBox(width: 4),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐'),
                            const SizedBox(width: 4),
                            Text(
                              '$xp XP',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
