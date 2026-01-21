import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Animated button with scale effect, shadow, and haptic feedback
/// Design principle: Subtle, satisfying press feedback with depth
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final bool enableShadow;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.enableHaptic = true,
    this.enableShadow = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = AppTheme.buttonPressedScale;
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });
    if (widget.enableHaptic) {
      HapticService.tap();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedScale(
        scale: _scale,
        duration: AppTheme.animFast,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLG),
            boxShadow: widget.enableShadow && widget.backgroundColor != null
                ? [
                    BoxShadow(
                      color: widget.backgroundColor!.withValues(alpha: _isPressed ? 0.2 : 0.4),
                      blurRadius: _isPressed ? 4 : 12,
                      offset: Offset(0, _isPressed ? 2 : 6),
                      spreadRadius: _isPressed ? 0 : 1,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Primary action button with animation and gradient (Dribbble-inspired)
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor; // Optional - uses gradient if null
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height = 56,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = AppTheme.buttonPressedScale);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    HapticService.tap();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedScale(
        scale: _scale,
        duration: AppTheme.animFast,
        curve: Curves.easeOut,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.backgroundColor == null
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [widget.backgroundColor!, widget.backgroundColor!],
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? AppTheme.accent).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary/outlined button with animation (Dribbble-inspired)
class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 56,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = AppTheme.buttonPressedScale);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    HapticService.tap();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedScale(
        scale: _scale,
        duration: AppTheme.animFast,
        curve: Curves.easeOut,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.accent, width: 2),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
