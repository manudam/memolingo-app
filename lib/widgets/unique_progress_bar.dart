import 'package:flutter/material.dart';

class UniqueProgressBar extends StatelessWidget {
  const UniqueProgressBar({
    super.key,
    required this.progress,
    required this.secondaryProgress,
  });

  final double progress;
  final double secondaryProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Secondary Progress (max progress)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: secondaryProgress.clamp(0.0, 1.0),
            heightFactor: 1.0,
            child: Container(
              color: const Color(0xFFFF8500),
            ),
          ),
          // Primary Progress (current progress)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            heightFactor: 1.0,
            child: Container(
              color: const Color(0xFF5D6DBD),
            ),
          ),
        ],
      ),
    );
  }
}
