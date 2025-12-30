import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated answer button with shake (wrong) and pulse (correct) feedback
class AnimatedAnswerButton extends StatefulWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;
  final Color accentColor;

  const AnimatedAnswerButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<AnimatedAnswerButton> createState() => _AnimatedAnswerButtonState();
}

class _AnimatedAnswerButtonState extends State<AnimatedAnswerButton>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _pressController;

  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pressAnimation;

  bool _isPressed = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    // Shake animation for wrong answers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Pulse animation for correct answers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedAnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animations when result is shown
    if (widget.showResult && !_hasAnimated) {
      _hasAnimated = true;
      if (widget.isSelected && !widget.isCorrect) {
        // Wrong answer - shake
        _shakeController.forward();
      } else if (widget.isCorrect) {
        // Correct answer - pulse
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
      }
    }

    // Reset when moving to next question
    if (!widget.showResult && oldWidget.showResult) {
      _hasAnimated = false;
      _shakeController.reset();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.showResult) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.showResult) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  Color _getBackgroundColor() {
    if (!widget.showResult) {
      return Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.1);
    }
    if (widget.isCorrect) {
      return AppTheme.correct;
    }
    if (widget.isSelected && !widget.isCorrect) {
      return AppTheme.incorrect;
    }
    return Colors.white.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.showResult ? null : _onTapDown,
      onTapUp: widget.showResult ? null : _onTapUp,
      onTapCancel: widget.showResult ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_shakeAnimation, _pulseAnimation, _pressAnimation]),
        builder: (context, child) {
          // Calculate shake offset
          double shakeOffset = 0;
          if (_shakeController.isAnimating) {
            shakeOffset = sin(_shakeAnimation.value * 4 * pi) * 8 * (1 - _shakeAnimation.value);
          }

          // Calculate scale (pulse or press)
          double scale = _pressAnimation.value;
          if (_pulseController.isAnimating || _pulseController.value > 0) {
            scale = _pulseAnimation.value;
          }

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected && !widget.showResult
                  ? widget.accentColor
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: widget.showResult && widget.isCorrect
                ? [
                    BoxShadow(
                      color: AppTheme.correct.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : widget.showResult && widget.isSelected && !widget.isCorrect
                    ? [
                        BoxShadow(
                          color: AppTheme.incorrect.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + widget.index), // A, B, C, D
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.showResult && widget.isCorrect)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Icon(Icons.check_circle, color: Colors.white),
                ),
              if (widget.showResult && widget.isSelected && !widget.isCorrect)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Icon(Icons.cancel, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
