import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'bouncy_button.dart';

/// An interactive, tactile hearing/audio button designed to feel like a real
/// physical push button. It provides spring-back press feedback, haptics,
/// and animated radiating sound waves when audio is playing.
class HearingButton extends StatefulWidget {
  const HearingButton({
    required this.onTap,
    this.isSpeaking = false,
    this.size = 80.0,
    this.imagePath = 'assets/legacy_icons/repeat.png',
    super.key,
  });

  final VoidCallback onTap;
  final bool isSpeaking;
  final double size;
  final String imagePath;

  @override
  State<HearingButton> createState() => _HearingButtonState();
}

class _HearingButtonState extends State<HearingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isSpeaking) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HearingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        _pulseController.repeat();
      } else {
        _pulseController.animateTo(0.0,
            duration: const Duration(milliseconds: 250));
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildRipple(double delayFraction) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        if (!widget.isSpeaking && _pulseController.value == 0.0) {
          return const SizedBox.shrink();
        }

        // Calculate staggered progress
        final progress =
            (_pulseController.value + delayFraction) % 1.0;
        final scale = 1.0 + (progress * 0.45);
        final opacity = math.sin(progress * math.pi) * 0.4;

        return Positioned.fill(
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE67E22).withValues(alpha: opacity),
                  width: 3.0,
                ),
                color: const Color(0xFFF39C12)
                    .withValues(alpha: (opacity * 0.35).clamp(0.0, 1.0)),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Expanding sound wave ripples when speaking
          _buildRipple(0.0),
          _buildRipple(0.5),

          // Tactile pushable button
          BouncyButton(
            onTap: widget.onTap,
            shrinkScale: 0.90,
            translateY: 3.5,
            haptic: true,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
