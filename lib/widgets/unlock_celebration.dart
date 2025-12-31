import 'package:flutter/material.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';

/// Shared widget for displaying mode unlock celebration
/// Used in: Survival Mode, Higher or Lower, Timed Blitz, Cup Mode results screens
class UnlockCelebration extends StatelessWidget {
  final UnlockResult unlockResult;

  const UnlockCelebration({
    super.key,
    required this.unlockResult,
  });

  @override
  Widget build(BuildContext context) {
    if (!unlockResult.didUnlock) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.gold,
              AppTheme.gold.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              '${unlockResult.unlockedModeName} Unlocked!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
