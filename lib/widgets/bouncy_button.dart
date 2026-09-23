import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that gives child widgets tactile press feedback like a
/// physical button (scale down on press, bounce back on release, and haptic feedback).
///
/// Can be used in two ways:
/// 1. Standalone button: provide [onTap] directly to [BouncyButton].
/// 2. Wrapper around existing buttons (e.g. ElevatedButton, OutlinedButton, IconButton):
///    leave [onTap] null and the child button's own onPressed will handle the action,
///    while [BouncyButton] manages the tactile spring press physics and haptics.
class BouncyButton extends StatefulWidget {
  const BouncyButton({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.shrinkScale = 0.93,
    this.translateY = 2.0,
    this.haptic = true,
    this.enabled = true,
    this.pressDuration = const Duration(milliseconds: 80),
    this.releaseDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// The scale of the child when pressed down (1.0 = normal, 0.93 = 7% shrink).
  final double shrinkScale;

  /// The vertical pixel offset when pressed down to simulate physical button depression.
  final double translateY;

  /// Whether to trigger light haptic feedback when pressed down.
  final bool haptic;

  /// Whether button interactions are active.
  final bool enabled;

  final Duration pressDuration;
  final Duration releaseDuration;

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressDuration,
      reverseDuration: widget.releaseDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.shrinkScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: widget.translateY,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BouncyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shrinkScale != widget.shrinkScale ||
        oldWidget.translateY != widget.translateY) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.shrinkScale,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeOutBack,
        ),
      );

      _translateAnimation = Tween<double>(
        begin: 0.0,
        end: widget.translateY,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeOutBack,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() {
    if (!widget.enabled) return;
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _releaseUp() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );

    // If an onTap or onLongPress handler is explicitly provided, use GestureDetector
    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _pressDown() : null,
        onTapUp: widget.enabled ? (_) => _releaseUp() : null,
        onTapCancel: widget.enabled ? () => _releaseUp() : null,
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: content,
      );
    }

    // Otherwise, use Listener so underlying button widgets (ElevatedButton, IconButton, etc.)
    // keep their own gesture recognition and callbacks while getting tactile bounce feedback.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.enabled ? (_) => _pressDown() : null,
      onPointerUp: widget.enabled ? (_) => _releaseUp() : null,
      onPointerCancel: widget.enabled ? (_) => _releaseUp() : null,
      child: content,
    );
  }
}

/// Convenience extension allowing any widget to easily become bouncy and tactile.
extension BouncyWidgetExtension on Widget {
  Widget bouncy({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double shrinkScale = 0.93,
    double translateY = 2.0,
    bool haptic = true,
    bool enabled = true,
    Duration pressDuration = const Duration(milliseconds: 80),
    Duration releaseDuration = const Duration(milliseconds: 150),
  }) {
    return BouncyButton(
      onTap: onTap,
      onLongPress: onLongPress,
      shrinkScale: shrinkScale,
      translateY: translateY,
      haptic: haptic,
      enabled: enabled,
      pressDuration: pressDuration,
      releaseDuration: releaseDuration,
      child: this,
    );
  }
}
