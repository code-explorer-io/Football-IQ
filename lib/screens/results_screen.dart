import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/club.dart';
import '../services/score_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/form_guide.dart';
import 'home_screen.dart';
import 'question_screen.dart';

class ResultsScreen extends StatefulWidget {
  final Club club;
  final int score;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.club,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _bestScore = 0;
  bool _isNewBest = false;
  int _footballIQ = 50;
  int _iqChange = 0;
  List<Achievement> _newAchievements = [];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadAndSaveScore();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadAndSaveScore() async {
    // Use club-specific score storage
    final isNewBest = await ScoreService.saveBestScore(
      'quiz_your_club',
      widget.score,
      clubId: widget.club.id,
    );
    final bestScore = await ScoreService.getBestScore(
      'quiz_your_club',
      clubId: widget.club.id,
    );

    // Update stats and get new IQ
    final statsResult = await StatsService.recordQuizResult(
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: 'quiz_your_club',
    );

    // Check for achievements
    final stats = await StatsService.getTotalStats();
    final form = await StatsService.getFormGuide();
    final achievements = await AchievementService.checkAndUnlockAchievements(
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: 'quiz_your_club',
      totalCorrectAnswers: stats['totalCorrect'],
      perfectScoreCount: stats['perfectScores'],
      footballIQ: statsResult.newIQ,
      formGuide: form,
    );

    setState(() {
      _bestScore = bestScore;
      _isNewBest = isNewBest;
      _footballIQ = statsResult.newIQ;
      _iqChange = statsResult.change;
      _newAchievements = achievements;
    });

    // Celebrate perfect score or new best with confetti
    final isPerfect = widget.score == widget.totalQuestions;
    if (isPerfect || isNewBest) {
      HapticService.celebrate();
      _confettiController.play();
    }
  }

  String _getVerdict() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) {
      return 'True Fan';
    } else if (percentage >= 50) {
      return 'Matchday Regular';
    } else {
      return 'Tourist';
    }
  }

  String _getVerdictEmoji() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) {
      return '🏆';
    } else if (percentage >= 50) {
      return '⚽';
    } else {
      return '🎫';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // NEW BEST badge
                  if (_isNewBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW BEST!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  // Verdict emoji
                  Text(
                    _getVerdictEmoji(),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  // Score
                  Text(
                    '${widget.score}/${widget.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Best score
                  Text(
                    'Best: $_bestScore/${widget.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // IQ change indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FootballIQBadge(iq: _footballIQ, size: 60),
                      if (_iqChange != 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          _iqChange > 0 ? '+$_iqChange' : '$_iqChange',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _iqChange > 0 ? AppTheme.correct : AppTheme.incorrect,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Verdict
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.club.primaryColor,
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
                  const SizedBox(height: 8),
                  Text(
                    widget.club.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  // New achievements
                  if (_newAchievements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: _newAchievements.map((a) => Chip(
                        backgroundColor: Color(AchievementService.getTierColor(
                          AchievementService.getTier(a),
                        )),
                        label: Text(
                          a.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  const Spacer(),
                  // Play Again button
                  PrimaryButton(
                    text: 'Play Again',
                    backgroundColor: widget.club.primaryColor,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionScreen(club: widget.club),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Change Club button
                  SecondaryButton(
                    text: 'Change Club',
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppTheme.gold,
                AppTheme.correct,
                AppTheme.highlight,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
