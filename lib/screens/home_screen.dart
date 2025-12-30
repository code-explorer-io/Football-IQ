import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/haptic_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/form_guide.dart'; // Still needed for FootballIQBadge on results screen
import 'club_selection_screen.dart';
import 'survival_mode_screen.dart';
import 'higher_or_lower_screen.dart';
import 'timed_blitz_screen.dart';
import 'cup_mode_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentStreak = 0;
  int _currentLevel = 1;
  double _levelProgress = 0.0;
  bool _streakAtRisk = false;

  @override
  void initState() {
    super.initState();
    _loadGamificationData();
    AnalyticsService.logScreenView('home');
    AnalyticsService.logAppOpen();
  }

  Future<void> _loadGamificationData() async {
    final streak = await StreakService.getCurrentStreak();
    final level = await XPService.getCurrentLevel();
    final progress = await XPService.getLevelProgress();
    final atRisk = await StreakService.isStreakAtRisk();

    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _currentLevel = level;
        _levelProgress = progress;
        _streakAtRisk = atRisk;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Football IQ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: const Color(0xFF2A2A4E),
            onSelected: (value) {
              if (value == 'privacy') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              } else if (value == 'terms') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'privacy',
                child: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'terms',
                child: Text('Terms of Service', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gamification stats row
            _GamificationHeader(
              streak: _currentStreak,
              level: _currentLevel,
              levelProgress: _levelProgress,
              streakAtRisk: _streakAtRisk,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                ).then((_) => _loadGamificationData());
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your football knowledge',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: gameModes.length,
                itemBuilder: (context, index) {
                  final mode = gameModes[index];
                  return _GameModeCard(mode: mode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final GameMode mode;

  const _GameModeCard({required this.mode});

  void _onTap(BuildContext context) async {
    if (mode.isLocked) {
      // Show paywall for locked modes
      final purchased = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const PaywallScreen()),
      );
      // If purchased, the mode will now be unlocked (isLocked getter checks PurchaseService)
      if (purchased != true) return;
    }

    // Check context is still valid after async gap
    if (!context.mounted) return;

    // Track mode selection
    AnalyticsService.logModeSelected(mode.name);

    if (mode.requiresClubSelection) {
      // Go to club selection (Quiz Your Club)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClubSelectionScreen(),
        ),
      );
    } else if (mode.id == 'survival_mode') {
      // Survival Mode has its own intro screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurvivalIntroScreen(mode: mode),
        ),
      );
    } else if (mode.id == 'higher_or_lower') {
      // Higher or Lower has its own screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HigherOrLowerIntroScreen(mode: mode),
        ),
      );
    } else if (mode.id == 'timed_blitz') {
      // Timed Blitz has its own screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimedBlitzIntroScreen(mode: mode),
        ),
      );
    } else if (mode.id == 'international_cup') {
      // International Cup has its own screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CupModeIntroScreen(mode: mode),
        ),
      );
    } else {
      // Standard quiz modes (PL Legends)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenericQuizIntroScreen(mode: mode),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mode.color, mode.color.withValues(alpha: 0.7)],
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      mode.icon,
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
                          mode.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    mode.isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            if (mode.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
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

// Generic quiz intro for modes that don't need club selection
class GenericQuizIntroScreen extends StatelessWidget {
  final GameMode mode;

  const GenericQuizIntroScreen({super.key, required this.mode});

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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mode.color, mode.color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  mode.icon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                mode.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '10 Questions\nMixed Difficulty',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericQuestionScreen(mode: mode),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Generic question screen for non-club modes
class GenericQuestionScreen extends StatefulWidget {
  final GameMode mode;

  const GenericQuestionScreen({super.key, required this.mode});

  @override
  State<GenericQuestionScreen> createState() => _GenericQuestionScreenState();
}

class _GenericQuestionScreenState extends State<GenericQuestionScreen> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString(widget.mode.dataFile!);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      jsonList.shuffle();
      _questions = jsonList.take(10).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _questions = _getPlaceholderQuestions();
      });
    }
  }

  List<Map<String, dynamic>> _getPlaceholderQuestions() {
    return List.generate(10, (index) => {
      'id': 'placeholder_$index',
      'question': 'Sample question ${index + 1}?',
      'options': ['Option A', 'Option B', 'Option C'],
      'answerIndex': 0,
      'difficulty': 'easy',
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (selectedIndex == _questions[_currentIndex]['answerIndex']) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenericResultsScreen(
              mode: widget.mode,
              score: _score,
              totalQuestions: _questions.length,
            ),
          ),
        );
      }
    });
  }

  Color _getButtonColor(int index) {
    if (!_answered) {
      return Colors.white.withValues(alpha: 0.1);
    }
    if (index == _questions[_currentIndex]['answerIndex']) {
      return Colors.green;
    }
    if (_selectedAnswer == index) {
      return Colors.red;
    }
    return Colors.white.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Text(
          'Question ${_currentIndex + 1}/${_questions.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(widget.mode.color),
            ),
            const SizedBox(height: 32),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Show moment description if available (for Iconic Moments)
                    if (question['moment'] != null) ...[
                      Text(
                        '"${question['moment']}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: (question['options'] as List).length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _answered ? null : () => _handleAnswer(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getButtonColor(index),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question['options'][index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_answered && index == question['answerIndex'])
                            const Icon(Icons.check_circle, color: Colors.white),
                          if (_answered && _selectedAnswer == index && index != question['answerIndex'])
                            const Icon(Icons.cancel, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic results screen for non-club modes
class GenericResultsScreen extends StatefulWidget {
  final GameMode mode;
  final int score;
  final int totalQuestions;

  const GenericResultsScreen({
    super.key,
    required this.mode,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<GenericResultsScreen> createState() => _GenericResultsScreenState();
}

class _GenericResultsScreenState extends State<GenericResultsScreen> {
  int _bestScore = 0;
  bool _isNewBest = false;
  int _footballIQ = 50;
  int _iqChange = 0;
  List<Achievement> _newAchievements = [];
  XPAward? _xpAward;
  int _currentStreak = 0;

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
    // Save best score
    final isNewBest = await ScoreService.saveBestScore(widget.mode.id, widget.score);
    final bestScore = await ScoreService.getBestScore(widget.mode.id);

    // Update stats and get new IQ
    final statsResult = await StatsService.recordQuizResult(
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: widget.mode.id,
    );

    // Record streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP
    final isPerfect = widget.score == widget.totalQuestions;
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: widget.mode.id,
      streakDays: streakResult.streak,
      isPerfect: isPerfect,
    );

    // Check for achievements
    final stats = await StatsService.getTotalStats();
    final form = await StatsService.getFormGuide();
    final achievements = await AchievementService.checkAndUnlockAchievements(
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: widget.mode.id,
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
    });

    // Celebrate perfect score or new best with confetti
    if (isPerfect || isNewBest || xpAward.leveledUp) {
      HapticService.celebrate();
      _confettiController.play();
    }
  }

  String _getVerdict() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) return 'Expert';
    if (percentage >= 50) return 'Solid Knowledge';
    return 'Keep Learning';
  }

  String _getVerdictEmoji() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) return '🏆';
    if (percentage >= 50) return '⚽';
    return '📚';
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
                  Text(
                    _getVerdictEmoji(),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${widget.score}/${widget.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.mode.color,
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
                    widget.mode.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  // XP earned
                  if (_xpAward != null) ...[
                    const SizedBox(height: 20),
                    _GenericXPRow(xpAward: _xpAward!, streak: _currentStreak),
                  ],
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
                  PrimaryButton(
                    text: 'Play Again',
                    backgroundColor: widget.mode.color,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenericQuestionScreen(mode: widget.mode),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: 'Back to Menu',
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

/// Gamification header showing streak and level
class _GamificationHeader extends StatelessWidget {
  final int streak;
  final int level;
  final double levelProgress;
  final bool streakAtRisk;
  final VoidCallback onTap;

  const _GamificationHeader({
    required this.streak,
    required this.level,
    required this.levelProgress,
    required this.streakAtRisk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: streakAtRisk
              ? Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Streak indicator
            _StatPill(
              icon: Icons.local_fire_department,
              iconColor: streak > 0 ? const Color(0xFFFF6B35) : AppTheme.textMuted,
              value: '$streak',
              label: 'day${streak != 1 ? 's' : ''}',
              isHighlighted: streakAtRisk,
            ),
            const SizedBox(width: 16),
            // Level indicator with progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        XPService.getLevelTitle(level),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      backgroundColor: AppTheme.elevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.highlight),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Arrow to indicate tappable
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat pill for the gamification header
class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isHighlighted;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppTheme.gold : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Stats screen showing detailed progress
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalXP = 0;
  int _weeklyXP = 0;
  int _todayXP = 0;
  int _level = 1;
  double _levelProgress = 0.0;
  int _xpToNextLevel = 0;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    final currentStreak = await StreakService.getCurrentStreak();
    final longestStreak = await StreakService.getLongestStreak();
    final totalXP = await XPService.getTotalXP();
    final weeklyXP = await XPService.getWeeklyXP();
    final todayXP = await XPService.getTodayXP();
    final level = await XPService.getCurrentLevel();
    final levelProgress = await XPService.getLevelProgress();
    final xpToNext = await XPService.getXPToNextLevel();
    final stats = await StatsService.getTotalStats();

    if (mounted) {
      setState(() {
        _currentStreak = currentStreak;
        _longestStreak = longestStreak;
        _totalXP = totalXP;
        _weeklyXP = weeklyXP;
        _todayXP = todayXP;
        _level = level;
        _levelProgress = levelProgress;
        _xpToNextLevel = xpToNext;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Stats',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.highlight))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level card
                  _LevelCard(
                    level: _level,
                    levelProgress: _levelProgress,
                    totalXP: _totalXP,
                    xpToNextLevel: _xpToNextLevel,
                  ),
                  const SizedBox(height: 20),
                  // Streak section
                  _SectionTitle(title: 'Streak'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFFF6B35),
                          title: 'Current',
                          value: '$_currentStreak',
                          subtitle: 'day${_currentStreak != 1 ? 's' : ''}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events,
                          iconColor: AppTheme.gold,
                          title: 'Longest',
                          value: '$_longestStreak',
                          subtitle: 'day${_longestStreak != 1 ? 's' : ''}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // XP section
                  _SectionTitle(title: 'Experience'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.today,
                          iconColor: AppTheme.highlight,
                          title: 'Today',
                          value: '$_todayXP',
                          subtitle: 'XP',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.date_range,
                          iconColor: AppTheme.correct,
                          title: 'This Week',
                          value: '$_weeklyXP',
                          subtitle: 'XP',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quiz stats section
                  _SectionTitle(title: 'Performance'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          iconColor: AppTheme.quizYourClub,
                          title: 'Quizzes',
                          value: '${_stats['quizzesPlayed'] ?? 0}',
                          subtitle: 'played',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          iconColor: AppTheme.correct,
                          title: 'Correct',
                          value: '${_stats['totalCorrect'] ?? 0}',
                          subtitle: 'answers',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star,
                          iconColor: AppTheme.gold,
                          title: 'Perfect',
                          value: '${_stats['perfectScores'] ?? 0}',
                          subtitle: 'scores',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.percent,
                          iconColor: AppTheme.silver,
                          title: 'Accuracy',
                          value: _getAccuracy(),
                          subtitle: '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getAccuracy() {
    final total = _stats['totalQuestions'] ?? 0;
    final correct = _stats['totalCorrect'] ?? 0;
    if (total == 0) return '--%';
    return '${((correct / total) * 100).round()}%';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final double levelProgress;
  final int totalXP;
  final int xpToNextLevel;

  const _LevelCard({
    required this.level,
    required this.levelProgress,
    required this.totalXP,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.elevated, AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.highlight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.highlight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      XPService.getLevelTitle(level),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalXP XP total',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '$xpToNextLevel XP to go',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.highlight),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// XP earned display for generic results screen
class _GenericXPRow extends StatelessWidget {
  final XPAward xpAward;
  final int streak;

  const _GenericXPRow({
    required this.xpAward,
    required this.streak,
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
