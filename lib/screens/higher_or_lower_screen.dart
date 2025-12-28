import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import 'home_screen.dart';

class HigherOrLowerIntroScreen extends StatelessWidget {
  final GameMode mode;

  const HigherOrLowerIntroScreen({super.key, required this.mode});

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
                '10 Rounds\nCompare stats and guess:\nIs it higher or lower?',
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
                        builder: (context) => HigherOrLowerGameScreen(mode: mode),
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
                    'Start Game',
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

class HigherOrLowerGameScreen extends StatefulWidget {
  final GameMode mode;

  const HigherOrLowerGameScreen({super.key, required this.mode});

  @override
  State<HigherOrLowerGameScreen> createState() => _HigherOrLowerGameScreenState();
}

class _HigherOrLowerGameScreenState extends State<HigherOrLowerGameScreen> {
  List<dynamic> _comparisons = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _answered = false;
  bool _isCorrect = false;
  bool _showValue = false;

  @override
  void initState() {
    super.initState();
    _loadComparisons();
  }

  Future<void> _loadComparisons() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString(widget.mode.dataFile!);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      jsonList.shuffle();
      _comparisons = jsonList.take(10).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGuess(bool guessedHigher) {
    if (_answered) return;

    final comparison = _comparisons[_currentIndex];
    final value1 = comparison['item1']['value'] as num;
    final value2 = comparison['item2']['value'] as num;

    final isHigher = value2 > value1;
    final isCorrect = guessedHigher == isHigher;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _showValue = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
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
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_comparisons.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: Text('No data available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final comparison = _comparisons[_currentIndex];
    final item1 = comparison['item1'];
    final item2 = comparison['item2'];
    final category = comparison['category'];

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
          'Round ${_currentIndex + 1}/${_comparisons.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                            const Color(0xFF2E7D32).withOpacity(0.7),
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
                        color: const Color(0xFF1A1A2E),
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
                                  ? [Colors.green, Colors.green.withOpacity(0.7)]
                                  : [Colors.red, Colors.red.withOpacity(0.7)])
                              : [widget.mode.color, widget.mode.color.withOpacity(0.7)],
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
                color: Colors.white.withOpacity(0.1),
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
                        _isCorrect ? 'Correct!' : 'Wrong!',
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

  @override
  void initState() {
    super.initState();
    _loadAndSaveScore();
  }

  Future<void> _loadAndSaveScore() async {
    final isNewBest = await ScoreService.saveBestScore(widget.mode.id, widget.score);
    final bestScore = await ScoreService.getBestScore(widget.mode.id);
    setState(() {
      _bestScore = bestScore;
      _isNewBest = isNewBest;
    });
  }

  String _getVerdict() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) return 'Stats Master!';
    if (percentage >= 60) return 'Good Knowledge';
    if (percentage >= 40) return 'Room to Improve';
    return 'Keep Learning';
  }

  String _getVerdictEmoji() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) return '📊';
    if (percentage >= 60) return '👍';
    if (percentage >= 40) return '🤔';
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HigherOrLowerGameScreen(mode: widget.mode),
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
                    'Play Again',
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
