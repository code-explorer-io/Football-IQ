import 'package:flutter/material.dart';
import '../services/xp_service.dart';
import '../theme/app_theme.dart';

/// Shared widget for displaying XP earned after completing a game mode
/// Used in: Survival Mode, Higher or Lower, Timed Blitz results screens
class XPAwardDisplay extends StatelessWidget {
  final XPAward xpAward;
  final int streak;

  const XPAwardDisplay({
    super.key,
    required this.xpAward,
    this.streak = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: AppTheme.highlight, size: 20),
              const SizedBox(width: 8),
              Text(
                '+${xpAward.totalXPEarned} XP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.highlight,
                ),
              ),
              if (streak > 1) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFFF6B35), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (xpAward.bonusReasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: xpAward.bonusReasons.map((reason) => Text(
                reason,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              )).toList(),
            ),
          ],
          if (xpAward.leveledUp) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward, color: AppTheme.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Level ${xpAward.newLevel} - ${XPService.getLevelTitle(xpAward.newLevel)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
