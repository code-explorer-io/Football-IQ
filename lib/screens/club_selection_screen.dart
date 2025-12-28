import 'package:flutter/material.dart';
import '../models/club.dart';
import 'quiz_intro_screen.dart';

class ClubSelectionScreen extends StatelessWidget {
  const ClubSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
              'Pick your club',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How well do you know your team?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
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
      onTap: () {
        if (!club.isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizIntroScreen(club: club),
            ),
          );
        } else {
          // Show locked message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unlock all clubs with premium'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [club.primaryColor, club.primaryColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Club icon placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 32,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club.isLocked ? 'Locked' : 'Tap to play',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    club.isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            if (club.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
