import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/club.dart';
import '../models/question.dart';
import '../services/analytics_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_background.dart';
import '../widgets/animated_answer_button.dart';
import 'results_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Club club;
  final QuizDifficulty difficulty;

  const QuestionScreen({
    super.key,
    required this.club,
    this.difficulty = QuizDifficulty.normal,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
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

  // Timer for questions
  late AnimationController _timerController;
  int get _questionTimeSeconds => widget.difficulty.timePerQuestion;
  static const int _fastAnswerThreshold = 5; // Seconds for "fast answer" bonus
  bool _timeExpired = false;
  int _fastAnswerCount = 0; // Track fast correct answers for bonus XP

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

    // Timer controller - counts down from 1.0 to 0.0
    // Duration is set later after first build since widget.difficulty isn't available yet
    _timerController = AnimationController(
      duration: Duration(seconds: widget.difficulty.timePerQuestion),
      vsync: this,
    );
    _timerController.addStatusListener(_onTimerStatusChanged);

    _loadQuestions();
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !_answered && mounted) {
      // Time ran out - treat as wrong answer
      _handleTimeExpired();
    }
  }

  void _handleTimeExpired() {
    if (_answered) return;

    setState(() {
      _timeExpired = true;
      _answered = true;
      _selectedAnswer = -1; // No selection
    });

    // Haptic and sound for timeout
    HapticService.incorrect();
    SoundService.incorrect();

    // Move to next question after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      _moveToNextQuestion();
    });
  }

  void _startTimer() {
    _timerController.value = 1.0; // Reset to full
    _timerController.reverse(); // Count down to 0
  }

  void _stopTimer() {
    _timerController.stop();
  }

  @override
  void dispose() {
    _timerController.removeStatusListener(_onTimerStatusChanged);
    _timerController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _moveToNextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      // Animate out, change question, animate in
      _animController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
          _timeExpired = false;
        });
        _animController.forward();
        _startTimer(); // Start timer for new question
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
            fastAnswerCount: _fastAnswerCount,
            difficulty: widget.difficulty,
          ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
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

      // Track game start
      AnalyticsService.logGameStarted(
        modeName: 'Quiz Your Club',
        clubName: widget.club.name,
      );

      // Start animation and timer
      _animController.forward();
      _startTimer();
    } catch (e) {
      // If loading fails, use placeholder questions
      setState(() {
        _isLoading = false;
        _questions = _getPlaceholderQuestions();
      });
      _animController.forward();
      _startTimer();
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

    // Calculate time taken before stopping timer
    final secondsRemaining = (_timerController.value * _questionTimeSeconds).ceil();
    final secondsTaken = _questionTimeSeconds - secondsRemaining;
    final isFastAnswer = secondsTaken < _fastAnswerThreshold;

    // Stop the timer immediately
    _stopTimer();

    final isCorrect = selectedIndex == _questions[_currentIndex].answerIndex;

    // Track fast correct answers for bonus XP
    if (isCorrect && isFastAnswer) {
      _fastAnswerCount++;
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
      _selectedAnswer = selectedIndex;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Wait a moment then move to next question
    Future.delayed(const Duration(milliseconds: 1200), () {
      _moveToNextQuestion();
    });
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
      body: PitchBackground.zone(
        zone: BackgroundZone.dugout,
        child: Padding(
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
              const SizedBox(height: AppTheme.spaceL),
              // Enhanced timer with large countdown (Dribbble-inspired)
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  final secondsRemaining = (_timerController.value * _questionTimeSeconds).ceil();
                  final isLowTime = secondsRemaining <= 5;
                  final isCritical = secondsRemaining <= 3;

                  return Column(
                    children: [
                      // Large countdown number
                      if (!_answered)
                        TweenAnimationBuilder<double>(
                          key: ValueKey(secondsRemaining),
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Text(
                                '$secondsRemaining',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeXXL,
                                  fontWeight: FontWeight.bold,
                                  color: isCritical
                                      ? Colors.red
                                      : isLowTime
                                          ? Colors.orange
                                          : AppTheme.accent,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  shadows: isCritical
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      else if (_timeExpired)
                        Text(
                          "Time's up!",
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLG,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      const SizedBox(height: AppTheme.spaceM),
                      // Timer progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        child: LinearProgressIndicator(
                          value: _answered ? 0 : _timerController.value,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCritical
                                ? Colors.red
                                : isLowTime
                                    ? Colors.orange
                                    : AppTheme.accent,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceXL),
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                          letterSpacing: -0.3,
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
                        child: AnimatedAnswerButton(
                          text: question.options[index],
                          index: index,
                          isSelected: _selectedAnswer == index,
                          isCorrect: index == question.answerIndex,
                          showResult: _answered,
                          onTap: () => _handleAnswer(index),
                          accentColor: widget.club.primaryColor,
                        ),
                      );
                    },
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
