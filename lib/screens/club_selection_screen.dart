import 'package:flutter/material.dart';
import '../models/club.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import 'question_screen.dart';
import 'paywall_screen.dart';

class ClubSelectionScreen extends StatelessWidget {
  const ClubSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Your Club',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your Club',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prove you know your team',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return _ClubCard(club: club);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Club club;

  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticService.tap();
        if (club.isLocked) {
          // Show paywall for locked clubs
          final purchased = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const PaywallScreen()),
          );
          if (purchased != true) return;
        }
        // Navigate to quiz (either club was free or user just purchased)
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionScreen(club: club),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [club.primaryColor, club.primaryColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: club.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Club icon placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: AppTheme.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club.isLocked ? 'Premium' : '10 Questions • Mixed Difficulty',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      club.isLocked ? Icons.lock_outline : Icons.arrow_forward_rounded,
                      color: AppTheme.textPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            if (club.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
