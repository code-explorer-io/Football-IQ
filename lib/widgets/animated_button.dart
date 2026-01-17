import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Animated button with scale effect, shadow, and haptic feedback
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final bool enableShadow;
  final Border? border;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius,
    this.enableHaptic = true,
    this.enableShadow = true,
    this.border,
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
    final shadowColor = widget.backgroundColor ?? AppTheme.primaryGreen;

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
            color: widget.gradient == null ? widget.backgroundColor : null,
            gradient: widget.gradient,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusPill),
            border: widget.border,
            boxShadow: widget.enableShadow && (widget.backgroundColor != null || widget.gradient != null)
                ? [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: _isPressed ? 0.2 : 0.4),
                      blurRadius: _isPressed ? 4 : 16,
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

/// Primary action button with gradient and pill shape
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool useGradient;
  final double? width;
  final double height;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.useGradient = true,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      gradient: useGradient ? AppTheme.primaryGradient : null,
      backgroundColor: useGradient ? null : (backgroundColor ?? AppTheme.primaryGreen),
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.textOnGreen, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTheme.buttonText,
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary/outlined button with pill shape
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 56,
    this.icon,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      enableShadow: false,
      border: Border.all(
        color: borderColor ?? AppTheme.glassBorder,
        width: 1.5,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.textPrimary, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTheme.buttonTextLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-style button (semi-transparent)
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      backgroundColor: AppTheme.glassWhite,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      enableShadow: false,
      border: Border.all(color: AppTheme.glassBorder),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.textPrimary, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTheme.buttonTextLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon button with gradient
class GradientIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const GradientIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      gradient: AppTheme.primaryGradient,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      child: Center(
        child: Icon(icon, color: AppTheme.textOnGreen, size: size * 0.5),
      ),
    );
  }
}
