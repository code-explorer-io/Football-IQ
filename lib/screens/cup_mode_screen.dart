import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_background.dart';
import 'home_screen.dart';

// Cup stages in order
enum CupStage {
  groupStage,
  roundOf16,
  quarterFinal,
  semiFinal,
  final_,
}

extension CupStageExtension on CupStage {
  String get displayName {
    switch (this) {
      case CupStage.groupStage:
        return 'Group Stage';
      case CupStage.roundOf16:
        return 'Round of 16';
      case CupStage.quarterFinal:
        return 'Quarter Final';
      case CupStage.semiFinal:
        return 'Semi Final';
      case CupStage.final_:
        return 'Final';
    }
  }

  String get shortName {
    switch (this) {
      case CupStage.groupStage:
        return 'GRP';
      case CupStage.roundOf16:
        return 'R16';
      case CupStage.quarterFinal:
        return 'QF';
      case CupStage.semiFinal:
        return 'SF';
      case CupStage.final_:
        return 'F';
    }
  }

  int get requiredScore {
    switch (this) {
      case CupStage.groupStage:
        return 6; // 6/10 to advance
      case CupStage.roundOf16:
        return 6;
      case CupStage.quarterFinal:
        return 7;
      case CupStage.semiFinal:
        return 7;
      case CupStage.final_:
        return 8; // Harder to win the cup
    }
  }

  CupStage? get nextStage {
    switch (this) {
      case CupStage.groupStage:
        return CupStage.roundOf16;
      case CupStage.roundOf16:
        return CupStage.quarterFinal;
      case CupStage.quarterFinal:
        return CupStage.semiFinal;
      case CupStage.semiFinal:
        return CupStage.final_;
      case CupStage.final_:
        return null; // Winner!
    }
  }
}

class CupModeIntroScreen extends StatefulWidget {
  final GameMode mode;

  const CupModeIntroScreen({super.key, required this.mode});

  @override
  State<CupModeIntroScreen> createState() => _CupModeIntroScreenState();
}

class _CupModeIntroScreenState extends State<CupModeIntroScreen> {
  final CupStage _currentStage = CupStage.groupStage;
  int _cupsWon = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final cupsWon = await ScoreService.getCupsWon();
    setState(() {
      _cupsWon = cupsWon;
      _isLoading = false;
    });
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Trophy icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.mode.color, widget.mode.color.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.mode.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cups Won: $_cupsWon',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tournament bracket visualization
                    _buildBracket(),
                    const SizedBox(height: 24),
                    // Rules
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildRule(Icons.sports_soccer, 'Win matches to advance'),
                          const SizedBox(height: 8),
                          _buildRule(Icons.trending_up, 'Each round gets harder'),
                          const SizedBox(height: 8),
                          _buildRule(Icons.emoji_events, 'Win the Final to lift the Cup'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Start button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CupMatchScreen(
                                mode: widget.mode,
                                stage: _currentStage,
                              ),
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
                        child: Text(
                          'Start ${_currentStage.displayName}',
                          style: const TextStyle(
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

  Widget _buildBracket() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: CupStage.values.map((stage) {
          final isCurrentStage = stage == _currentStage;
          final isPastStage = stage.index < _currentStage.index;

          return Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPastStage
                      ? Colors.green
                      : isCurrentStage
                          ? widget.mode.color
                          : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: isCurrentStage
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Center(
                  child: isPastStage
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : Text(
                          stage.shortName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: isCurrentStage ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stage == CupStage.final_ ? 'Final' : '',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
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

class CupMatchScreen extends StatefulWidget {
  final GameMode mode;
  final CupStage stage;

  const CupMatchScreen({
    super.key,
    required this.mode,
    required this.stage,
  });

  @override
  State<CupMatchScreen> createState() => _CupMatchScreenState();
}

class _CupMatchScreenState extends State<CupMatchScreen> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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

      jsonList.shuffle();
      _questions = jsonList.take(10).toList();

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
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        _showMatchResult();
      }
    });
  }

  void _showMatchResult() {
    final didAdvance = _score >= widget.stage.requiredScore;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CupResultScreen(
          mode: widget.mode,
          stage: widget.stage,
          score: _score,
          totalQuestions: _questions.length,
          didAdvance: didAdvance,
        ),
      ),
    );
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
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load questions',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.mode.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
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
        title: Column(
          children: [
            Text(
              widget.stage.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              'Question ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.mode.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PitchBackground.zone(
        zone: BackgroundZone.dugout,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(widget.mode.color),
            ),
            // Target score indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Need ${widget.stage.requiredScore}/10 to advance',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }
}

class CupResultScreen extends StatefulWidget {
  final GameMode mode;
  final CupStage stage;
  final int score;
  final int totalQuestions;
  final bool didAdvance;

  const CupResultScreen({
    super.key,
    required this.mode,
    required this.stage,
    required this.score,
    required this.totalQuestions,
    required this.didAdvance,
  });

  @override
  State<CupResultScreen> createState() => _CupResultScreenState();
}

class _CupResultScreenState extends State<CupResultScreen> {
  bool _isWinner = false;
  UnlockResult? _unlockResult;

  @override
  void initState() {
    super.initState();
    _checkWinner();
  }

  Future<void> _checkWinner() async {
    // If won the final, increment cups won and record for unlock progression
    if (widget.didAdvance && widget.stage == CupStage.final_) {
      await ScoreService.incrementCupsWon();
      final unlockResult = await UnlockService.recordCupWin();

      setState(() {
        _isWinner = true;
        _unlockResult = unlockResult;
      });

      // Celebrate cup win (and mode unlock if applicable)
      HapticService.celebrate();
      SoundService.levelUp();
    }
  }

  String _getResultTitle() {
    if (_isWinner) return 'CHAMPION!';
    if (widget.didAdvance) return 'QUALIFIED!';
    return 'KNOCKED OUT';
  }

  IconData _getResultIcon() {
    if (_isWinner) return Icons.emoji_events;
    if (widget.didAdvance) return Icons.sports_soccer;
    return Icons.sentiment_dissatisfied;
  }

  String _getResultMessage() {
    if (_isWinner) {
      return 'You\'ve won the International Cup!';
    }
    if (widget.didAdvance) {
      return 'You advance to the ${widget.stage.nextStage?.displayName ?? "next round"}!';
    }
    return 'You needed ${widget.stage.requiredScore} to advance';
  }

  BackgroundZone _getResultsZone() {
    // Cup winner gets trophy room
    if (_isWinner) {
      return BackgroundZone.trophy;
    }
    // Advanced = win locker, knocked out = loss locker
    if (widget.didAdvance) {
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
                // Stage badge
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.mode.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.stage.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.mode.color,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                _getResultIcon(),
                size: 80,
                color: widget.didAdvance ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _getResultTitle(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: widget.didAdvance ? Colors.green : Colors.red,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.score}/${widget.totalQuestions}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getResultMessage(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              // Mode unlock celebration (for future Tournament Mode)
              if (_unlockResult != null && _unlockResult!.didUnlock) ...[
                const SizedBox(height: 20),
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
              if (widget.didAdvance && !_isWinner)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CupMatchScreen(
                            mode: widget.mode,
                            stage: widget.stage.nextStage!,
                          ),
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
                    child: Text(
                      'Continue to ${widget.stage.nextStage?.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (!widget.didAdvance)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CupMatchScreen(
                            mode: widget.mode,
                            stage: CupStage.groupStage, // Start over
                          ),
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
              if (_isWinner)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CupMatchScreen(
                            mode: widget.mode,
                            stage: CupStage.groupStage, // New tournament
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Defend Your Title',
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
