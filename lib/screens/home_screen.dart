import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/form_guide.dart';
import 'club_selection_screen.dart';
import 'survival_mode_screen.dart';
import 'higher_or_lower_screen.dart';
import 'timed_blitz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _footballIQ = 50;
  List<String> _formGuide = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final iq = await StatsService.getFootballIQ();
    final form = await StatsService.getFormGuide();
    setState(() {
      _footballIQ = iq;
      _formGuide = form;
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row - Football IQ and Form Guide
            StatsRow(
              footballIQ: _footballIQ,
              formGuide: _formGuide,
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose your game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How much do you really know?',
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

  void _onTap(BuildContext context) {
    if (mode.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
            colors: [mode.color, mode.color.withOpacity(0.7)],
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
                      color: Colors.white.withOpacity(0.2),
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
                            color: Colors.white.withOpacity(0.8),
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
