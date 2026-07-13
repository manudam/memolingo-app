import 'package:flutter/material.dart';

import '../screens/library/library_screen.dart';
import '../screens/practice/practice_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/stats/stats_screen.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({required this.selectedIndex, super.key});

  final int selectedIndex;
  static const _selectedColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _buildItem(context, 0, Icons.school_rounded, 'Practice'),
              _buildItem(context, 1, Icons.bar_chart_rounded, 'Stats'),
              _buildItem(context, 2, Icons.auto_stories_rounded, 'Library'),
              _buildItem(context, 3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, int index, IconData icon, String label) {
    final selected = index == selectedIndex;
    final color = selected ? _selectedColor : Colors.grey.shade700;

    return Expanded(
      child: InkWell(
        onTap: () => _navigate(context, index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected
                  ? _selectedColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: selected
                  ? Border.all(
                      color: _selectedColor.withValues(alpha: 0.22),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: selected ? 24 : 23, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    Widget destination;
    switch (index) {
      case 0:
        destination = const PracticeScreen();
        break;
      case 1:
        destination = const StatsScreen();
        break;
      case 2:
        destination = const LibraryScreen();
        break;
      case 3:
        destination = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
