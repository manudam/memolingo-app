import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.categoryName,
    this.size = 50,
  });

  final String categoryName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getCategoryColor(categoryName).withValues(alpha: 0.15),
      ),
      child: Icon(
        _getCategoryIcon(categoryName),
        color: _getCategoryColor(categoryName),
        size: size * 0.56,
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'animals':
        return Icons.pets_rounded;
      case 'everyday objects':
        return Icons.lightbulb_outline_rounded;
      case 'in the home':
        return Icons.home_rounded;
      case 'places':
        return Icons.place_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'describing things':
        return Icons.description_rounded;
      case 'verbs':
        return Icons.directions_run_rounded;
      case 'clothing & accessories':
        return Icons.checkroom_rounded;
      case 'health & medicine':
        return Icons.medical_services_rounded;
      case 'musical instruments':
        return Icons.music_note_rounded;
      case 'nature & environment':
        return Icons.eco_rounded;
      case 'professions':
        return Icons.work_rounded;
      case 'technology & electronics':
        return Icons.devices_rounded;
      case 'personal belongings':
        return Icons.wallet_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  Color _getCategoryColor(String name) {
    switch (name.toLowerCase()) {
      case 'animals':
        return Colors.brown;
      case 'everyday objects':
        return Colors.orange;
      case 'in the home':
        return Colors.teal;
      case 'places':
        return Colors.indigo;
      case 'people':
        return Colors.blue;
      case 'sports':
        return Colors.red;
      case 'transport':
        return Colors.grey.shade700;
      case 'describing things':
        return Colors.purple;
      case 'verbs':
        return Colors.deepOrange;
      case 'clothing & accessories':
        return Colors.pink;
      case 'health & medicine':
        return Colors.redAccent;
      case 'musical instruments':
        return Colors.deepPurple;
      case 'nature & environment':
        return Colors.green;
      case 'professions':
        return Colors.blueGrey;
      case 'technology & electronics':
        return Colors.cyan;
      case 'personal belongings':
        return Colors.amber.shade800;
      case 'food':
        return Colors.orangeAccent;
      default:
        return Colors.blue;
    }
  }
}
