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
    // CRITICAL: Check mounted FIRST to prevent setState after dispose crash
    if (!mounted) return;

    if (status == AnimationStatus.dismissed && !_answered) {
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
    // Stop timer before removing listener to prevent callback during dispose
    _timerController.stop();
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
    // Use floor for secondsRemaining to avoid rounding errors at boundaries
    // e.g., 0.63 * 8 = 5.04 should give 5 seconds remaining, not 6
    final secondsRemaining = (_timerController.value * _questionTimeSeconds).floor();
    final secondsTaken = _questionTimeSeconds - secondsRemaining;
    final isFastAnswer = secondsTaken <= _fastAnswerThreshold;

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
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
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
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Text(
          'Question ${_currentIndex + 1}/${_questions.length}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
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
                    backgroundColor: AppTheme.glassWhite,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.club.primaryColor),
                    minHeight: 4,
                  );
                },
              ),
              const SizedBox(height: 12),
              // Timer bar with countdown - PROMINENT DESIGN
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  final secondsRemaining = (_timerController.value * _questionTimeSeconds).ceil();
                  final isLowTime = secondsRemaining <= 5;
                  final isCriticalTime = secondsRemaining <= 3;

                  // Pulse effect for low time - faster pulse as time gets more critical
                  final pulseValue = isLowTime && !_answered
                      ? 1.0 + (0.08 * (isCriticalTime ? 1.5 : 1.0) *
                          ((DateTime.now().millisecondsSinceEpoch % 500) / 500.0 > 0.5 ? 1 : 0.7))
                      : 1.0;

                  // Color for timer - bright by default, urgent colors when low
                  final timerColor = isCriticalTime
                      ? AppTheme.incorrect
                      : (isLowTime ? AppTheme.warning : widget.club.primaryColor);

                  return Transform.scale(
                    scale: pulseValue,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: timerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: timerColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Timer text - centered and prominent
                          if (!_answered) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCriticalTime ? Icons.warning_amber_rounded : Icons.timer,
                                  size: 24,
                                  color: timerColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '00:${secondsRemaining.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: timerColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ] else if (_timeExpired) ...[
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_off,
                                  size: 24,
                                  color: AppTheme.incorrect,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Time's up!",
                                  style: TextStyle(
                                    color: AppTheme.incorrect,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Answered but not expired - show nothing or minimal
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 8),
                          // Timer progress bar - thicker
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _answered ? 0 : _timerController.value,
                              backgroundColor: AppTheme.glassWhite,
                              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
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
                        style: AppTheme.questionText,
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
                          isTimeExpired: _timeExpired,
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
