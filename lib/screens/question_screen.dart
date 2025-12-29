import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/club.dart';
import '../models/question.dart';
import '../services/haptic_service.dart';
import 'results_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Club club;

  const QuestionScreen({super.key, required this.club});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int? _selectedAnswer;
  bool _answered = false;

  // Animation for question transitions
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadQuestions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString(widget.club.dataFile);
      final List<dynamic> jsonList = json.decode(jsonString);
      final allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();

      // Shuffle and take 10 questions
      allQuestions.shuffle();
      _questions = allQuestions.take(10).toList();

      setState(() {
        _isLoading = false;
      });

      // Start animation
      _animController.forward();
    } catch (e) {
      // If loading fails, use placeholder questions
      setState(() {
        _isLoading = false;
        _questions = _getPlaceholderQuestions();
      });
      _animController.forward();
    }
  }

  List<Question> _getPlaceholderQuestions() {
    return List.generate(10, (index) => Question(
      id: 'placeholder_$index',
      question: 'Sample question ${index + 1} for ${widget.club.name}?',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      answerIndex: 0,
      difficulty: 'easy',
    ));
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    final isCorrect = selectedIndex == _questions[_currentIndex].answerIndex;

    // Haptic feedback
    if (isCorrect) {
      HapticService.correct();
    } else {
      HapticService.incorrect();
    }

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Wait a moment then move to next question
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_currentIndex < _questions.length - 1) {
        // Animate out, change question, animate in
        _animController.reverse().then((_) {
          setState(() {
            _currentIndex++;
            _selectedAnswer = null;
            _answered = false;
          });
          _animController.forward();
        });
      } else {
        // Quiz complete - go to results with fade transition
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ResultsScreen(
              club: widget.club,
              score: _score,
              totalQuestions: _questions.length,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar with smooth animation
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: _currentIndex / _questions.length,
                end: (_currentIndex + 1) / _questions.length,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.club.primaryColor),
                  minHeight: 4,
                );
              },
            ),
            const SizedBox(height: 32),
            // Question text with animation
            Expanded(
              flex: 2,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            // Answer options with staggered animation
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _AnswerButton(
                        text: question.options[index],
                        index: index,
                        isSelected: _selectedAnswer == index,
                        isCorrect: index == question.answerIndex,
                        showResult: _answered,
                        onTap: () => _handleAnswer(index),
                        clubColor: widget.club.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;
  final Color clubColor;

  const _AnswerButton({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
    required this.clubColor,
  });

  Color _getBackgroundColor() {
    if (!showResult) {
      return Colors.white.withOpacity(0.1);
    }
    if (isCorrect) {
      return Colors.green;
    }
    if (isSelected && !isCorrect) {
      return Colors.red;
    }
    return Colors.white.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && !showResult ? clubColor : Colors.transparent,
            width: 2,
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
                  String.fromCharCode(65 + index), // A, B, C, D
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
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            if (showResult && isCorrect)
              AnimatedScale(
                scale: showResult ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: const Icon(Icons.check_circle, color: Colors.white),
              ),
            if (showResult && isSelected && !isCorrect)
              AnimatedScale(
                scale: showResult ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: const Icon(Icons.cancel, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
