import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/club.dart';
import '../services/score_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/haptic_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/form_guide.dart';
import '../widgets/pitch_background.dart';
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

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  int _bestScore = 0;
  bool _isNewBest = false;
  int _footballIQ = 50;
  int _iqChange = 0;
  List<Achievement> _newAchievements = [];
  XPAward? _xpAward;
  int _currentStreak = 0;
  bool _dataLoaded = false;

  late ConfettiController _confettiController;
  late AnimationController _scoreAnimController;
  late AnimationController _fadeInController;
  late Animation<int> _scoreAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Score count-up animation
    _scoreAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOutCubic),
    );

    // Fade in animation for elements
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.elasticOut),
    );

    _loadAndSaveScore();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimController.dispose();
    _fadeInController.dispose();
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

    // Record streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP
    final isPerfect = widget.score == widget.totalQuestions;
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: 'quiz_your_club',
      streakDays: streakResult.streak,
      isPerfect: isPerfect,
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
      _xpAward = xpAward;
      _currentStreak = streakResult.streak;
      _dataLoaded = true;
    });

    // Start animations
    _fadeInController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scoreAnimController.forward();

    // Celebrate perfect score or new best with confetti
    if (isPerfect || isNewBest || xpAward.leveledUp) {
      HapticService.celebrate();
      _confettiController.play();
    }

    // Track analytics
    AnalyticsService.logGameCompleted(
      modeName: 'Quiz Your Club',
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      xpEarned: xpAward.totalXPEarned,
      clubName: widget.club.name,
    );
    if (isPerfect) {
      AnalyticsService.logPerfectScore('Quiz Your Club');
    }
    if (xpAward.leveledUp) {
      final levelTitle = XPService.getLevelTitle(xpAward.newLevel);
      AnalyticsService.logLevelUp(xpAward.newLevel, levelTitle);
    }
  }

  String _getVerdict() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) {
      return 'Club Legend';
    } else if (percentage >= 80) {
      return 'Season Ticket Holder';
    } else if (percentage >= 50) {
      return 'Matchday Regular';
    } else {
      return 'Casual Fan';
    }
  }

  String _getVerdictEmoji() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) {
      return '🏆';
    } else if (percentage >= 80) {
      return '⭐';
    } else if (percentage >= 50) {
      return '⚽';
    } else {
      return '📺';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          PitchBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 1),
                    // NEW BEST badge with animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isNewBest
                          ? TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) {
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.gold.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'NEW CLUB RECORD',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 40),
                    ),
                    // Verdict emoji with scale animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Text(
                        _getVerdictEmoji(),
                        style: const TextStyle(fontSize: 72),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Animated score count-up
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return Text(
                          '${_scoreAnimation.value}/${widget.totalQuestions}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    // Best score
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Best: $_bestScore/${widget.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Verdict badge
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.club.primaryColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: widget.club.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _getVerdict(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.club.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // IQ and XP row
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Football IQ
                          FootballIQBadge(iq: _footballIQ, size: 50),
                          if (_iqChange != 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              _iqChange > 0 ? '+$_iqChange' : '$_iqChange',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _iqChange > 0 ? AppTheme.correct : AppTheme.incorrect,
                              ),
                            ),
                          ],
                          if (_xpAward != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.highlight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: AppTheme.highlight, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${_xpAward!.totalXPEarned} XP',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.highlight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_currentStreak > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, color: Color(0xFFFF6B35), size: 18),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$_currentStreak',
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
                    ),
                    // Level up indicator
                    if (_xpAward != null && _xpAward!.leveledUp) ...[
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward, color: AppTheme.gold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Level ${_xpAward!.newLevel} - ${XPService.getLevelTitle(_xpAward!.newLevel)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // New achievements
                    if (_newAchievements.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: _newAchievements.map((a) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(AchievementService.getTierColor(
                                AchievementService.getTier(a),
                              )),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                    const Spacer(flex: 2),
                    // Action buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Play Again button
                          PrimaryButton(
                            text: 'Play Again',
                            backgroundColor: widget.club.primaryColor,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      QuestionScreen(club: widget.club),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // Home button
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const HomeScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
