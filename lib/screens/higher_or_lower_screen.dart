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
import '../widgets/xp_award_display.dart';
import '../widgets/unlock_celebration.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/new_record_badge.dart';
import 'home_screen.dart';

class HigherOrLowerIntroScreen extends StatelessWidget {
  final GameMode mode;

  const HigherOrLowerIntroScreen({super.key, required this.mode});

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
                  '10 Rounds • Trust your instincts',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You know the stats. Or do you?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                PrimaryButton(
                  text: 'Play the Odds',
                  backgroundColor: mode.color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HigherOrLowerGameScreen(mode: mode),
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

class HigherOrLowerGameScreen extends StatefulWidget {
  final GameMode mode;

  const HigherOrLowerGameScreen({super.key, required this.mode});

  @override
  State<HigherOrLowerGameScreen> createState() => _HigherOrLowerGameScreenState();
}

class _HigherOrLowerGameScreenState extends State<HigherOrLowerGameScreen> {
  List<Map<String, dynamic>> _comparisons = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _answered = false;
  bool _isCorrect = false;
  bool _showValue = false;

  @override
  void initState() {
    super.initState();
    _loadComparisons();
  }

  Future<void> _loadComparisons() async {
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

      // Validate and cast each comparison
      final validComparisons = <Map<String, dynamic>>[];
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;

        // Validate required fields exist
        if (item['item1'] == null || item['item2'] == null) continue;
        if (item['category'] == null) continue;

        final item1 = item['item1'];
        final item2 = item['item2'];

        // Validate item structure
        if (item1 is! Map<String, dynamic> || item2 is! Map<String, dynamic>) continue;
        if (item1['name'] == null || item1['value'] == null) continue;
        if (item2['name'] == null || item2['value'] == null) continue;

        // Validate value types (must be numeric)
        if (item1['value'] is! num || item2['value'] is! num) continue;

        validComparisons.add(item);
      }

      if (validComparisons.isEmpty) {
        throw Exception('No valid comparisons found in data file');
      }

      validComparisons.shuffle();
      _comparisons = validComparisons.take(10).toList();

      // Track game start
      AnalyticsService.logGameStarted(modeName: 'Higher or Lower');

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

  void _handleGuess(bool guessedHigher) {
    if (_answered) return;

    final comparison = _comparisons[_currentIndex];
    final value1 = comparison['item1']['value'] as num;
    final value2 = comparison['item2']['value'] as num;

    // Handle equal values - either guess is correct when values are equal
    final bool isCorrect;
    if (value2 == value1) {
      isCorrect = true; // Both answers are valid when equal
    } else {
      final isHigher = value2 > value1;
      isCorrect = guessedHigher == isHigher;
    }

    // Haptic and sound feedback
    if (isCorrect) {
      HapticService.correct();
      SoundService.correct();
    } else {
      HapticService.incorrect();
      SoundService.incorrect();
    }

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _showValue = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < _comparisons.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _showValue = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HigherOrLowerResultsScreen(
              mode: widget.mode,
              score: _score,
              totalQuestions: _comparisons.length,
            ),
          ),
        );
      }
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

    if (_hasError || _comparisons.isEmpty) {
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
          title: 'Unable to load data',
          onRetry: _loadComparisons,
          buttonColor: widget.mode.color,
        ),
      );
    }

    final comparison = _comparisons[_currentIndex];
    final item1 = comparison['item1'];
    final item2 = comparison['item2'];
    final category = comparison['category'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Text(
          'Round ${_currentIndex + 1}/${_comparisons.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PitchBackground.zone(
        zone: BackgroundZone.dugout,
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _comparisons.length,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(widget.mode.color),
              ),
            ),
            const SizedBox(height: 16),
            // Category label - more prominent
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.mode.color,
                borderRadius: BorderRadius.circular(12),
              ),
            child: Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // First item (known value)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32),
                            const Color(0xFF2E7D32).withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item1['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${item1['value']}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // VS divider
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Second item (guess)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _answered
                              ? (_isCorrect
                                  ? [Colors.green, Colors.green.withValues(alpha: 0.7)]
                                  : [Colors.red, Colors.red.withValues(alpha: 0.7)])
                              : [widget.mode.color, widget.mode.color.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item2['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _showValue ? '${item2['value']}' : '?',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Comparison prompt
          if (!_answered)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Does ${item2['name']} have more or less than ${item1['value']}?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          // Buttons
          if (!_answered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _handleGuess(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Higher',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _handleGuess(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Lower',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? 'Got it' : 'Not quite',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}

class HigherOrLowerResultsScreen extends StatefulWidget {
  final GameMode mode;
  final int score;
  final int totalQuestions;

  const HigherOrLowerResultsScreen({
    super.key,
    required this.mode,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<HigherOrLowerResultsScreen> createState() => _HigherOrLowerResultsScreenState();
}

class _HigherOrLowerResultsScreenState extends State<HigherOrLowerResultsScreen> {
  int _bestScore = 0;
  bool _isNewBest = false;
  XPAward? _xpAward;
  int _dailyStreak = 0;
  UnlockResult? _unlockResult;

  @override
  void initState() {
    super.initState();
    _loadAndSaveScore();
  }

  Future<void> _loadAndSaveScore() async {
    final isNewBest = await ScoreService.saveBestScore(widget.mode.id, widget.score);
    final bestScore = await ScoreService.getBestScore(widget.mode.id);

    // Record daily streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP
    final isPerfect = widget.score == widget.totalQuestions;
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: 'higher_or_lower',
      streakDays: streakResult.streak,
      isPerfect: isPerfect,
    );

    // Record Higher or Lower win for unlock progression (7+ is a win)
    UnlockResult unlockResult = UnlockResult();
    if (widget.score >= 7) {
      unlockResult = await UnlockService.recordHigherOrLowerWin();
    }

    setState(() {
      _bestScore = bestScore;
      _isNewBest = isNewBest;
      _xpAward = xpAward;
      _dailyStreak = streakResult.streak;
      _unlockResult = unlockResult;
    });

    // Celebrate new record, level up, or mode unlock
    if ((isNewBest && widget.score > 0) || xpAward.leveledUp || unlockResult.didUnlock) {
      HapticService.celebrate();
      SoundService.levelUp();
    }

    // Track analytics
    AnalyticsService.logGameCompleted(
      modeName: 'Higher or Lower',
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      xpEarned: xpAward.totalXPEarned,
    );
    if (isPerfect) {
      AnalyticsService.logPerfectScore('Higher or Lower');
    }
    if (xpAward.leveledUp) {
      final levelTitle = XPService.getLevelTitle(xpAward.newLevel);
      AnalyticsService.logLevelUp(xpAward.newLevel, levelTitle);
    }
  }

  String _getVerdict() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) return 'Stat King';
    if (percentage >= 80) return 'Data Analyst';
    if (percentage >= 60) return 'Numbers Man';
    if (percentage >= 40) return 'Work to Do';
    return 'Back to Basics';
  }

  IconData _getVerdictIcon() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) return Icons.emoji_events;
    if (percentage >= 80) return Icons.insights;
    if (percentage >= 60) return Icons.trending_up;
    if (percentage >= 40) return Icons.trending_flat;
    return Icons.trending_down;
  }

  BackgroundZone _getResultsZone() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 50) {
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
              Text(
                '${widget.score}/${widget.totalQuestions}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Best: $_bestScore/${widget.totalQuestions}',
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
              const SizedBox(height: 16),
              Text(
                widget.mode.name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
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
                text: 'Play Again',
                backgroundColor: widget.mode.color,
                onTap: () {
                  AnalyticsService.logPlayAgain('Higher or Lower');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HigherOrLowerGameScreen(mode: widget.mode),
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
