import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared widget for displaying a "NEW RECORD" badge on results screens
/// Used in: Results, Survival, Higher or Lower, Timed Blitz, Home screens
class NewRecordBadge extends StatelessWidget {
  final bool animate;

  const NewRecordBadge({
    super.key,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'NEW RECORD',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1,
        ),
      ),
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: badge,
      );
    }

    return badge;
  }
}
