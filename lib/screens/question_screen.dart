import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/club.dart';
import '../models/question.dart';
import 'results_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Club club;

  const QuestionScreen({super.key, required this.club});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> _questions = [];
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
      final String jsonString = await rootBundle.loadString(widget.club.dataFile);
      final List<dynamic> jsonList = json.decode(jsonString);
      final allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();

      // Shuffle and take 10 questions
      allQuestions.shuffle();
      _questions = allQuestions.take(10).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, use placeholder questions
      setState(() {
        _isLoading = false;
        _questions = _getPlaceholderQuestions();
      });
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

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (selectedIndex == _questions[_currentIndex].answerIndex) {
        _score++;
      }
    });

    // Wait a moment then move to next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        // Quiz complete - go to results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              club: widget.club,
              score: _score,
              totalQuestions: _questions.length,
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
            // Progress bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(widget.club.primaryColor),
            ),
            const SizedBox(height: 32),
            // Question text
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Answer options
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return _AnswerButton(
                    text: question.options[index],
                    index: index,
                    isSelected: _selectedAnswer == index,
                    isCorrect: index == question.answerIndex,
                    showResult: _answered,
                    onTap: () => _handleAnswer(index),
                    clubColor: widget.club.primaryColor,
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
      child: Container(
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
              const Icon(Icons.check_circle, color: Colors.white),
            if (showResult && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
