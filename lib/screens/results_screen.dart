import 'package:flutter/material.dart';
import '../models/club.dart';
import 'home_screen.dart';
import 'question_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Club club;
  final int score;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.club,
    required this.score,
    required this.totalQuestions,
  });

  String _getVerdict() {
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) {
      return 'True Fan';
    } else if (percentage >= 50) {
      return 'Matchday Regular';
    } else {
      return 'Tourist';
    }
  }

  String _getVerdictEmoji() {
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) {
      return '🏆';
    } else if (percentage >= 50) {
      return '⚽';
    } else {
      return '🎫';
    }
  }

  Color _getVerdictColor() {
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) {
      return Colors.amber;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Verdict emoji
              Text(
                _getVerdictEmoji(),
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              // Score
              Text(
                '$score/$totalQuestions',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Verdict
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _getVerdictColor(),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _getVerdict(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                club.name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              // Play Again button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(club: club),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: club.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Change Club button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Change Club',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
