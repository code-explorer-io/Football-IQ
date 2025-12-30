import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../services/analytics_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_background.dart';
import '../widgets/animated_answer_button.dart';
import 'home_screen.dart';

class SurvivalIntroScreen extends StatelessWidget {
  final GameMode mode;

  const SurvivalIntroScreen({super.key, required this.mode});

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
      body: PitchBackground.zone(
        zone: BackgroundZone.tunnel,
        child: Center(
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
                const Text(
                  'One wrong answer.\nThat\'s all it takes.\nHow long can you survive?',
                  style: TextStyle(
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
                          builder: (context) => SurvivalQuestionScreen(mode: mode),
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
      ),
    );
  }
}

class SurvivalQuestionScreen extends StatefulWidget {
  final GameMode mode;

  const SurvivalQuestionScreen({super.key, required this.mode});

  @override
  State<SurvivalQuestionScreen> createState() => _SurvivalQuestionScreenState();
}

class _SurvivalQuestionScreenState extends State<SurvivalQuestionScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _streak = 0;
  bool _isLoading = true;
  int? _selectedAnswer;
  bool _answered = false;

  // Void (death) transition animation
  late AnimationController _voidController;
  late Animation<double> _voidAnimation;
  bool _showingVoid = false;

  @override
  void initState() {
    super.initState();
    _voidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _voidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _voidController, curve: Curves.easeIn),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _voidController.dispose();
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    final isCorrect = selectedIndex == _questions[_currentIndex]['answerIndex'];

    // Haptic and sound feedback
    if (isCorrect) {
      HapticService.correct();
      SoundService.correct();
    } else {
      HapticService.incorrect();
      SoundService.incorrect();
    }

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (isCorrect) {
        _streak++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (isCorrect) {
        // Continue to next question
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _selectedAnswer = null;
            _answered = false;
          });
        } else {
          // Ran out of questions - you win!
          _showGameOver(true);
        }
      } else {
        // Game over
        _showGameOver(false);
      }
    });
  }

  void _showGameOver(bool ranOutOfQuestions) {
    if (ranOutOfQuestions) {
      // Player completed all questions - no death transition needed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SurvivalResultsScreen(
            mode: widget.mode,
            streak: _streak,
            ranOutOfQuestions: ranOutOfQuestions,
          ),
        ),
      );
    } else {
      // Death! Show the void transition
      _showVoidTransition();
    }
  }

  void _showVoidTransition() {
    setState(() {
      _showingVoid = true;
    });

    // Fade to black (200ms)
    _voidController.forward().then((_) {
      // Hold black (500ms)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        // Navigate to results
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SurvivalResultsScreen(
              mode: widget.mode,
              streak: _streak,
              ranOutOfQuestions: false,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Fade in from black
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      });
    });
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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, color: widget.mode.color),
            const SizedBox(width: 8),
            Text(
              'Streak: $_streak',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)], // Balance the leading icon
      ),
      body: Stack(
        children: [
          PitchBackground.zone(
            zone: BackgroundZone.dugout,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak indicator
                  Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.mode.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _streak.clamp(0, 10),
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.local_fire_department,
                      color: widget.mode.color,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  question['question'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: (question['options'] as List).length,
                itemBuilder: (context, index) {
                  return AnimatedAnswerButton(
                    text: question['options'][index],
                    index: index,
                    isSelected: _selectedAnswer == index,
                    isCorrect: index == question['answerIndex'],
                    showResult: _answered,
                    onTap: () => _handleAnswer(index),
                    accentColor: widget.mode.color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
          ),
          // Void overlay - fades to black on death
          if (_showingVoid)
            AnimatedBuilder(
              animation: _voidAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withValues(alpha: _voidAnimation.value),
                );
              },
            ),
        ],
      ),
    );
  }
}

class SurvivalResultsScreen extends StatefulWidget {
  final GameMode mode;
  final int streak;
  final bool ranOutOfQuestions;

  const SurvivalResultsScreen({
    super.key,
    required this.mode,
    required this.streak,
    this.ranOutOfQuestions = false,
  });

  @override
  State<SurvivalResultsScreen> createState() => _SurvivalResultsScreenState();
}

class _SurvivalResultsScreenState extends State<SurvivalResultsScreen> {
  int _bestStreak = 0;
  bool _isNewBest = false;
  XPAward? _xpAward;
  int _dailyStreak = 0;
  UnlockResult? _unlockResult;

  @override
  void initState() {
    super.initState();
    _loadAndSaveStreak();
  }

  Future<void> _loadAndSaveStreak() async {
    final isNewBest = await ScoreService.saveBestStreak(widget.streak);
    final bestStreak = await ScoreService.getBestStreak();

    // Record daily streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.streak,
      totalQuestions: widget.streak, // In survival, correct = total answered
      modeId: 'survival_mode',
      streakDays: streakResult.streak,
      isPerfect: widget.ranOutOfQuestions, // "Perfect" if they ran out of questions
    );

    // Record survival streak for unlock progression
    final unlockResult = await UnlockService.recordSurvivalStreak(widget.streak);

    setState(() {
      _bestStreak = bestStreak;
      _isNewBest = isNewBest;
      _xpAward = xpAward;
      _dailyStreak = streakResult.streak;
      _unlockResult = unlockResult;
    });

    // Celebrate new record, level up, or mode unlock
    if ((isNewBest && widget.streak > 0) || xpAward.leveledUp || unlockResult.didUnlock) {
      HapticService.celebrate();
      SoundService.levelUp();
    }

    // Track analytics
    AnalyticsService.logGameCompleted(
      modeName: 'Survival Mode',
      score: widget.streak,
      totalQuestions: widget.streak,
      xpEarned: xpAward.totalXPEarned,
    );
    if (xpAward.leveledUp) {
      final levelTitle = XPService.getLevelTitle(xpAward.newLevel);
      AnalyticsService.logLevelUp(xpAward.newLevel, levelTitle);
    }
  }

  String _getVerdict() {
    if (widget.ranOutOfQuestions) return 'Unbeaten';
    if (widget.streak >= 20) return 'World Class';
    if (widget.streak >= 15) return 'Top Flight';
    if (widget.streak >= 10) return 'Solid Run';
    if (widget.streak >= 5) return 'Decent Spell';
    return 'Early Exit';
  }

  IconData _getVerdictIcon() {
    if (widget.ranOutOfQuestions) return Icons.emoji_events;
    if (widget.streak >= 20) return Icons.local_fire_department;
    if (widget.streak >= 15) return Icons.star;
    if (widget.streak >= 10) return Icons.trending_up;
    if (widget.streak >= 5) return Icons.sports_soccer;
    return Icons.replay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: PitchBackground.zone(
        zone: BackgroundZone.results,
        child: SafeArea(
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
              Icon(
                _getVerdictIcon(),
                size: 80,
                color: widget.mode.color,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: widget.mode.color, size: 48),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.streak}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Text(
                'Question Streak',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Best: $_bestStreak',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
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
              // XP earned
              if (_xpAward != null) ...[
                const SizedBox(height: 20),
                _SurvivalXPRow(xpAward: _xpAward!, streak: _dailyStreak),
              ],
              // Mode unlock celebration
              if (_unlockResult != null && _unlockResult!.didUnlock) ...[
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold,
                          AppTheme.gold.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_open, color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_unlockResult!.unlockedModeName} Unlocked!',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        builder: (context) => SurvivalQuestionScreen(mode: widget.mode),
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
                    'Kick Off Again',
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
      ),
    );
  }
}

/// XP earned display for survival results
class _SurvivalXPRow extends StatelessWidget {
  final XPAward xpAward;
  final int streak;

  const _SurvivalXPRow({
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
