import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Answer button with smooth animations and haptic feedback
/// Features:
/// - Scale animation on press
/// - Smooth color transition on answer reveal
/// - Haptic feedback (light for correct, medium for incorrect)
class AnswerButton extends StatefulWidget {
  final int index;
  final String text;
  final bool answered;
  final bool isCorrectAnswer;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.index,
    required this.text,
    required this.answered,
    required this.isCorrectAnswer,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _hasTriggeredHaptic = false;

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger haptic when answer is revealed
    if (widget.answered && !oldWidget.answered && widget.isSelected) {
      if (!_hasTriggeredHaptic) {
        _hasTriggeredHaptic = true;
        if (widget.isCorrectAnswer) {
          HapticService.correct();
        } else {
          HapticService.incorrect();
        }
      }
    }

    // Reset haptic flag for next question
    if (!widget.answered && oldWidget.answered) {
      _hasTriggeredHaptic = false;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.answered) {
      setState(() => _scale = AppTheme.buttonPressedScale);
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    if (!widget.answered) {
      HapticService.tap();
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  Color _getBackgroundColor() {
    if (!widget.answered) {
      return Colors.white.withOpacity(0.1);
    }
    if (widget.isCorrectAnswer) {
      return AppTheme.correct;
    }
    if (widget.isSelected) {
      return AppTheme.incorrect;
    }
    return Colors.white.withOpacity(0.1);
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
          duration: AppTheme.animNormal,
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
          child: Row(
            children: [
              // Letter indicator (A, B, C, D)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + widget.index),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Answer text
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              // Result icon
              if (widget.answered && widget.isCorrectAnswer)
                const _AnimatedIcon(
                  icon: Icons.check_circle,
                  color: Colors.white,
                ),
              if (widget.answered && widget.isSelected && !widget.isCorrectAnswer)
                const _AnimatedIcon(
                  icon: Icons.cancel,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated icon that fades and scales in
class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _AnimatedIcon({
    required this.icon,
    required this.color,
  });

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Icon(widget.icon, color: widget.color),
    );
  }
}
