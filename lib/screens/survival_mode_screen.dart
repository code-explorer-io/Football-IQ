import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
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
                'Answer correctly to survive\nOne wrong answer ends the game\nHow far can you go?',
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
                    'Start Survival',
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

class SurvivalQuestionScreen extends StatefulWidget {
  final GameMode mode;

  const SurvivalQuestionScreen({super.key, required this.mode});

  @override
  State<SurvivalQuestionScreen> createState() => _SurvivalQuestionScreenState();
}

class _SurvivalQuestionScreenState extends State<SurvivalQuestionScreen> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _streak = 0;
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.mode.color.withOpacity(0.2),
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

  @override
  void initState() {
    super.initState();
    _loadAndSaveStreak();
  }

  Future<void> _loadAndSaveStreak() async {
    final isNewBest = await ScoreService.saveBestStreak(widget.streak);
    final bestStreak = await ScoreService.getBestStreak();
    setState(() {
      _bestStreak = bestStreak;
      _isNewBest = isNewBest;
    });
  }

  String _getVerdict() {
    if (widget.ranOutOfQuestions) return 'LEGENDARY!';
    if (widget.streak >= 20) return 'Incredible!';
    if (widget.streak >= 15) return 'Amazing!';
    if (widget.streak >= 10) return 'Great Run!';
    if (widget.streak >= 5) return 'Good Effort';
    return 'Keep Trying';
  }

  String _getVerdictEmoji() {
    if (widget.ranOutOfQuestions) return '👑';
    if (widget.streak >= 20) return '🔥';
    if (widget.streak >= 15) return '⭐';
    if (widget.streak >= 10) return '💪';
    if (widget.streak >= 5) return '👍';
    return '📚';
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
              if (_isNewBest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
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
              const Text(
                'GAME OVER',
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
}
