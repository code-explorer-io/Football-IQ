import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Form guide widget displaying last 5 results as W/D/L boxes
/// Design: Like Premier League form guide - clean, informative
class FormGuide extends StatelessWidget {
  final List<String> results; // List of 'W', 'D', 'L'
  final double size;

  const FormGuide({
    super.key,
    required this.results,
    this.size = 28,
  });

  Color _getColor(String result) {
    switch (result) {
      case 'W':
        return AppTheme.correct;
      case 'D':
        return AppTheme.textMuted;
      case 'L':
        return AppTheme.incorrect;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pad to 5 slots if less than 5 results
    final displayResults = List.generate(5, (index) {
      if (index < results.length) {
        return results[index];
      }
      return '-';
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayResults.map((result) {
        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: result == '-'
                ? Colors.white.withValues(alpha: 0.1)
                : _getColor(result),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              result,
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
                color: result == '-'
                    ? AppTheme.textMuted
                    : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Football IQ display widget
class FootballIQBadge extends StatelessWidget {
  final int iq;
  final double size;

  const FootballIQBadge({
    super.key,
    required this.iq,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Import would be needed for StatsService.getIQTierColor
    // For now, inline the color logic
    int tierColor;
    if (iq >= 90) {
      tierColor = 0xFFD4AF37; // Gold
    } else if (iq >= 80) {
      tierColor = 0xFFC0C0C0; // Silver
    } else if (iq >= 70) {
      tierColor = 0xFFCD7F32; // Bronze
    } else if (iq >= 60) {
      tierColor = 0xFF3498DB; // Blue
    } else if (iq >= 50) {
      tierColor = 0xFF2ECC71; // Green
    } else {
      tierColor = 0xFF95A5A6; // Grey
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(tierColor),
            Color(tierColor).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(tierColor).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$iq',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'IQ',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stats row for home screen
class StatsRow extends StatelessWidget {
  final int footballIQ;
  final List<String> formGuide;

  const StatsRow({
    super.key,
    required this.footballIQ,
    required this.formGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Football IQ
          Row(
            children: [
              FootballIQBadge(iq: footballIQ, size: 48),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Football IQ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    _getTierName(footballIQ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Form guide
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Form',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              FormGuide(results: formGuide, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  String _getTierName(int iq) {
    if (iq >= 90) return 'World Class';
    if (iq >= 80) return 'Elite';
    if (iq >= 70) return 'Professional';
    if (iq >= 60) return 'Semi-Pro';
    if (iq >= 50) return 'Amateur';
    if (iq >= 40) return 'Beginner';
    return 'Rookie';
  }
}
