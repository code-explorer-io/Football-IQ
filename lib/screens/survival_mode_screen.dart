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
import '../widgets/animated_button.dart';
import '../widgets/pitch_background.dart';
import '../widgets/animated_answer_button.dart';
import '../widgets/xp_award_display.dart';
import '../widgets/unlock_celebration.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/new_record_badge.dart';
import 'home_screen.dart';

class SurvivalIntroScreen extends StatelessWidget {
  final GameMode mode;

  const SurvivalIntroScreen({super.key, required this.mode});

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
                  'One wrong answer ends it all',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'How long can you survive?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                PrimaryButton(
                  text: 'Enter the Arena',
                  backgroundColor: mode.color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurvivalQuestionScreen(mode: mode),
                      ),
                    );
                  },
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
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _streak = 0;
  bool _isLoading = true;
  bool _hasError = false;
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
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.mode.dataFile == null) {
        throw Exception('No data file configured for this mode');
      }

      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString(widget.mode.dataFile!);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Validate and cast each question
      final validQuestions = <Map<String, dynamic>>[];
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;

        // Validate required fields exist
        if (item['question'] == null ||
            item['options'] == null ||
            item['answerIndex'] == null) {
          continue;
        }

        // Validate types
        if (item['question'] is! String) continue;
        if (item['options'] is! List) continue;
        if (item['answerIndex'] is! int) continue;

        // Validate answer index is in range
        final options = item['options'] as List;
        final answerIndex = item['answerIndex'] as int;
        if (answerIndex < 0 || answerIndex >= options.length) continue;

        validQuestions.add(item);
      }

      if (validQuestions.isEmpty) {
        throw Exception('No valid questions found in data file');
      }

      validQuestions.shuffle();
      _questions = validQuestions;

      // Track game start
      AnalyticsService.logGameStarted(modeName: 'Survival Mode');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
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
      if (!mounted) return;
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
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.highlight),
        ),
      );
    }

    if (_hasError || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ErrorStateWidget(
          onRetry: _loadQuestions,
          buttonColor: widget.mode.color,
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                    key: ValueKey('q${_currentIndex}_opt$index'),
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

  BackgroundZone _getResultsZone() {
    // 5+ streak is a decent run, show win locker
    if (widget.streak >= 5) {
      return BackgroundZone.resultsWin;
    } else {
      return BackgroundZone.resultsLoss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: PitchBackground.zone(
        zone: _getResultsZone(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                if (_isNewBest) const NewRecordBadge(),
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
                XPAwardDisplay(xpAward: _xpAward!, streak: _dailyStreak),
              ],
              // Mode unlock celebration
              if (_unlockResult != null && _unlockResult!.didUnlock) ...[
                const SizedBox(height: 16),
                UnlockCelebration(unlockResult: _unlockResult!),
              ],
              const Spacer(),
              PrimaryButton(
                text: 'Try Again',
                backgroundColor: widget.mode.color,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurvivalQuestionScreen(mode: widget.mode),
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
      ),
    );
  }
}
