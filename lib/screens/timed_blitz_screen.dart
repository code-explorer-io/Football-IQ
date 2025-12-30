import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/haptic_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class TimedBlitzIntroScreen extends StatelessWidget {
  final GameMode mode;

  const TimedBlitzIntroScreen({super.key, required this.mode});

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
                    colors: [mode.color, mode.color.withOpacity(0.7)],
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
              const Text(
                '60 seconds.\nThe clock is ticking.\nHow many can you get?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Quick rules
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRule(Icons.timer, 'Race against the clock'),
                    const SizedBox(height: 8),
                    _buildRule(Icons.flash_on, 'Mistakes don\'t stop you'),
                    const SizedBox(height: 8),
                    _buildRule(Icons.speed, 'Quick fire questions'),
                  ],
                ),
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
                        builder: (context) => TimedBlitzQuestionScreen(mode: mode),
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
                    'Begin',
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

  Widget _buildRule(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class TimedBlitzQuestionScreen extends StatefulWidget {
  final GameMode mode;

  const TimedBlitzQuestionScreen({super.key, required this.mode});

  @override
  State<TimedBlitzQuestionScreen> createState() => _TimedBlitzQuestionScreenState();
}

class _TimedBlitzQuestionScreenState extends State<TimedBlitzQuestionScreen>
    with TickerProviderStateMixin {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _totalAnswered = 0;
  bool _isLoading = true;
  int? _selectedAnswer;
  bool _answered = false;

  // Timer
  static const int _totalSeconds = 60;
  int _secondsRemaining = _totalSeconds;
  Timer? _timer;
  late AnimationController _timerAnimationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString(widget.mode.dataFile!);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      jsonList.shuffle();
      _questions = jsonList;

      setState(() {
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timerAnimationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      // Haptic feedback in last 10 seconds
      if (_secondsRemaining <= 10 && _secondsRemaining > 0) {
        HapticFeedback.lightImpact();
      }

      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        _showResults();
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    final isCorrect = selectedIndex == _questions[_currentIndex]['answerIndex'];

    // Haptic feedback based on answer
    if (isCorrect) {
      HapticService.correct();
    } else {
      HapticService.incorrect();
    }

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      _totalAnswered++;
      if (isCorrect) {
        _score++;
      }
    });

    // Quick flash feedback then immediately advance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_secondsRemaining > 0) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // Ran out of questions
      _timer?.cancel();
      _showResults();
    }
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TimedBlitzResultsScreen(
          mode: widget.mode,
          score: _score,
          totalAnswered: _totalAnswered,
          timeRemaining: _secondsRemaining,
        ),
      ),
    );
  }

  Color _getButtonColor(int index) {
    if (!_answered) {
      return Colors.white.withOpacity(0.1);
    }
    if (index == _questions[_currentIndex]['answerIndex']) {
      return Colors.green;
    }
    if (_selectedAnswer == index) {
      return Colors.red;
    }
    return Colors.white.withOpacity(0.1);
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

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: Text('No questions available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final isUrgent = _secondsRemaining <= 10;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Timer bar at top
            AnimatedBuilder(
              animation: _timerAnimationController,
              builder: (context, child) {
                final progress = _secondsRemaining / _totalSeconds;
                return Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.1),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red : widget.mode.color,
                        boxShadow: isUrgent
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Header with timer and score
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                  // Timer display
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = isUrgent ? 1.0 + (_pulseController.value * 0.1) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isUrgent ? Colors.red : widget.mode.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_secondsRemaining',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Answer buttons - optimized for speed
                    ...List.generate(
                      (question['options'] as List).length,
                      (index) => GestureDetector(
                        onTap: _answered ? null : () => _handleAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: _getButtonColor(index),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _answered ? Colors.transparent : Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimedBlitzResultsScreen extends StatefulWidget {
  final GameMode mode;
  final int score;
  final int totalAnswered;
  final int timeRemaining;

  const TimedBlitzResultsScreen({
    super.key,
    required this.mode,
    required this.score,
    required this.totalAnswered,
    this.timeRemaining = 0,
  });

  @override
  State<TimedBlitzResultsScreen> createState() => _TimedBlitzResultsScreenState();
}

class _TimedBlitzResultsScreenState extends State<TimedBlitzResultsScreen> {
  int _bestScore = 0;
  bool _isNewBest = false;
  XPAward? _xpAward;
  int _dailyStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadAndSaveScore();
  }

  Future<void> _loadAndSaveScore() async {
    final isNewBest = await ScoreService.saveBlitzBestScore(widget.score);
    final bestScore = await ScoreService.getBlitzBestScore();

    // Record daily streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP with time bonus
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.score,
      totalQuestions: widget.totalAnswered,
      modeId: 'timed_blitz',
      streakDays: streakResult.streak,
      isPerfect: false, // No "perfect" in blitz mode
      secondsRemaining: widget.timeRemaining,
    );

    setState(() {
      _bestScore = bestScore;
      _isNewBest = isNewBest;
      _xpAward = xpAward;
      _dailyStreak = streakResult.streak;
    });

    // Celebrate new record or level up
    if ((isNewBest && widget.score > 0) || xpAward.leveledUp) {
      HapticService.celebrate();
    }

    // Track analytics
    AnalyticsService.logGameCompleted(
      modeName: 'Timed Blitz',
      score: widget.score,
      totalQuestions: widget.totalAnswered,
      xpEarned: xpAward.totalXPEarned,
    );
    if (xpAward.leveledUp) {
      final levelTitle = XPService.getLevelTitle(xpAward.newLevel);
      AnalyticsService.logLevelUp(xpAward.newLevel, levelTitle);
    }
  }

  String _getVerdict() {
    if (widget.score >= 20) return 'World Class';
    if (widget.score >= 15) return 'Clinical';
    if (widget.score >= 12) return 'Sharp';
    if (widget.score >= 10) return 'Composed';
    if (widget.score >= 7) return 'Steady';
    if (widget.score >= 5) return 'Finding Form';
    return 'Rusty';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.totalAnswered > 0
        ? (widget.score / widget.totalAnswered * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              if (_isNewBest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NEW RECORD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const Text(
                '⚡',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'FULL TIME',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.score}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Correct Answers',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStat('Answered', '${widget.totalAnswered}'),
                  const SizedBox(width: 32),
                  _buildStat('Accuracy', '$accuracy%'),
                  const SizedBox(width: 32),
                  _buildStat('Best', '$_bestScore'),
                ],
              ),
              const SizedBox(height: 24),
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
              // XP earned
              if (_xpAward != null) ...[
                const SizedBox(height: 20),
                _BlitzXPRow(xpAward: _xpAward!, streak: _dailyStreak),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimedBlitzQuestionScreen(mode: widget.mode),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.mode.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                    'Back to Menu',
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

/// XP earned display for blitz results
class _BlitzXPRow extends StatelessWidget {
  final XPAward xpAward;
  final int streak;

  const _BlitzXPRow({
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
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
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
                color: AppTheme.gold.withOpacity(0.2),
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
