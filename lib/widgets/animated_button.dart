import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Animated button with scale effect and haptic feedback
/// Design principle: Subtle, satisfying press feedback
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool enableHaptic;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.enableHaptic = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = AppTheme.buttonPressedScale);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    if (widget.enableHaptic) {
      HapticService.tap();
    }
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Primary action button with animation
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    required this.backgroundColor,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      backgroundColor: backgroundColor,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Secondary/outlined button with animation
class SecondaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.textMuted),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
