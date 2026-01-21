import 'package:flutter/material.dart';
import '../models/club.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import 'quiz_intro_screen.dart';
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Your Club',
          style: TextStyle(
            color: Colors.white,
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prove you know your team',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppTheme.spaceM,
                  mainAxisSpacing: AppTheme.spaceM,
                  childAspectRatio: 0.85,
                ),
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
              builder: (context) => QuizIntroScreen(club: club),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [club.primaryColor, club.primaryColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Club icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceM),
                  // Club name
                  Text(
                    club.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  // Status
                  Text(
                    club.isLocked ? 'Premium' : 'Ready to play',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  if (club.isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spaceXS),
                      child: Icon(
                        Icons.lock,
                        color: Colors.white.withValues(alpha: 0.8),
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
