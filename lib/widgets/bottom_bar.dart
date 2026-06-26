import 'package:flutter/material.dart';

import '../screens/library/library_screen.dart';
import '../screens/practice/practice_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/stats/stats_screen.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
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
    final color = selected ? const Color(0xFF2563EB) : Colors.grey.shade500;

    return Expanded(
      child: InkWell(
        onTap: () => _navigate(context, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
