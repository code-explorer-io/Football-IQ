import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared widget for displaying error states when content fails to load
/// Used in: Survival Mode, Cup Mode, Higher or Lower, Timed Blitz screens
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onRetry;
  final Color buttonColor;

  const ErrorStateWidget({
    super.key,
    this.title = 'Unable to load questions',
    this.subtitle = 'Please check your connection and try again',
    required this.onRetry,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
