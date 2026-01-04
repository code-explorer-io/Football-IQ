import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/game_mode.dart';
import '../services/score_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/haptic_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../services/analytics_service.dart';
import '../services/unlock_service.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_answer_button.dart';
import '../widgets/form_guide.dart';
import '../widgets/pitch_background.dart';
import '../widgets/xp_award_display.dart';
import 'club_selection_screen.dart';
import 'survival_mode_screen.dart';
import 'higher_or_lower_screen.dart';
import 'timed_blitz_screen.dart';
import 'cup_mode_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentStreak = 0;
  int _currentLevel = 1;
  double _levelProgress = 0.0;
  bool _streakAtRisk = false;
  Map<String, bool> _unlockedModes = {};
  Map<String, double> _unlockProgress = {};
  bool _isLoadingUnlocks = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    AnalyticsService.logScreenView('home');
    AnalyticsService.logAppOpen();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadGamificationData(),
      _loadUnlockData(),
    ]);
  }

  Future<void> _loadGamificationData() async {
    final streak = await StreakService.getCurrentStreak();
    final level = await XPService.getCurrentLevel();
    final progress = await XPService.getLevelProgress();
    final atRisk = await StreakService.isStreakAtRisk();

    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _currentLevel = level;
        _levelProgress = progress;
        _streakAtRisk = atRisk;
      });
    }
  }

  Future<void> _loadUnlockData() async {
    final Map<String, bool> unlocked = {};
    final Map<String, double> progress = {};

    for (final mode in gameModes) {
      unlocked[mode.id] = await UnlockService.isModeUnlocked(mode.id);
      progress[mode.id] = await UnlockService.getUnlockProgress(mode.id);
    }

    if (mounted) {
      setState(() {
        _unlockedModes = unlocked;
        _unlockProgress = progress;
        _isLoadingUnlocks = false;
      });
    }
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: const Color(0xFF2A2A4E),
            onSelected: (value) {
              if (value == 'privacy') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              } else if (value == 'terms') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'privacy',
                child: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'terms',
                child: Text('Terms of Service', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: PitchBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gamification stats row
                _GamificationHeader(
                  streak: _currentStreak,
                  level: _currentLevel,
                  levelProgress: _levelProgress,
                  streakAtRisk: _streakAtRisk,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatsScreen()),
                    ).then((_) => _loadAllData());
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Mode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test your football knowledge',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoadingUnlocks
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.highlight))
                      : ListView.builder(
                          itemCount: gameModes.length,
                          itemBuilder: (context, index) {
                            final mode = gameModes[index];
                            final isUnlocked = _unlockedModes[mode.id] ?? false;
                            final progress = _unlockProgress[mode.id] ?? 0.0;
                            return _GameModeCard(
                              mode: mode,
                              isUnlocked: isUnlocked,
                              unlockProgress: progress,
                              onRefresh: _loadAllData,
                            );
                          },
                        ),
                ),
                // Premium unlock all button
                if (!PurchaseService.isPremium)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: _UnlockAllButton(
                      onTap: () async {
                        final purchased = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (context) => const PaywallScreen()),
                        );
                        if (purchased == true) {
                          _loadAllData();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameModeCard extends StatefulWidget {
  final GameMode mode;
  final bool isUnlocked;
  final double unlockProgress;
  final VoidCallback onRefresh;

  const _GameModeCard({
    required this.mode,
    required this.isUnlocked,
    required this.unlockProgress,
    required this.onRefresh,
  });

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isPressed = false;
  String? _progressText;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    // Subtle glow pulse for unlocked cards
    if (widget.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
    _loadProgressText();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_GameModeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start glow when newly unlocked
    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  Future<void> _loadProgressText() async {
    if (!widget.isUnlocked && !widget.mode.isPremiumOnly) {
      final text = await UnlockService.getProgressText(widget.mode.id);
      if (mounted) {
        setState(() => _progressText = text);
      }
    }
  }

  void _onTap(BuildContext context) async {
    if (!widget.isUnlocked) {
      // Show what's needed to unlock
      _showUnlockRequirement(context);
      return;
    }

    // Track mode selection
    AnalyticsService.logModeSelected(widget.mode.name);

    if (widget.mode.requiresClubSelection) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClubSelectionScreen(),
        ),
      ).then((_) => widget.onRefresh());
    } else if (widget.mode.id == 'survival_mode') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurvivalIntroScreen(mode: widget.mode),
        ),
      ).then((_) => widget.onRefresh());
    } else if (widget.mode.id == 'higher_or_lower') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HigherOrLowerIntroScreen(mode: widget.mode),
        ),
      ).then((_) => widget.onRefresh());
    } else if (widget.mode.id == 'timed_blitz') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimedBlitzIntroScreen(mode: widget.mode),
        ),
      ).then((_) => widget.onRefresh());
    } else if (widget.mode.id == 'international_cup') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CupModeIntroScreen(mode: widget.mode),
        ),
      ).then((_) => widget.onRefresh());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenericQuizIntroScreen(mode: widget.mode),
        ),
      ).then((_) => widget.onRefresh());
    }
  }

  void _showUnlockRequirement(BuildContext context) {
    final requirement = UnlockService.getUnlockRequirement(widget.mode.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.mode.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.mode.icon,
                color: widget.mode.color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.mode.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  requirement,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            if (!widget.mode.isPremiumOnly && widget.unlockProgress > 0) ...[
              const SizedBox(height: 20),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        _progressText ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.unlockProgress,
                      backgroundColor: AppTheme.elevated,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.mode.color),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // Unlock instantly button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final purchased = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (context) => const PaywallScreen()),
                  );
                  if (purchased == true) {
                    widget.onRefresh();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Unlock All Modes - £2.49',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Keep Playing to Unlock',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });
    HapticService.tap();
    _onTap(context);
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !widget.isUnlocked;
    final accentColor = isLocked ? AppTheme.textMuted : widget.mode.color;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                // Gradient from accent color on left to dark surface on right
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isLocked
                      ? [AppTheme.surface, AppTheme.surface]
                      : [
                          Color.lerp(accentColor, AppTheme.surface, 0.85)!,
                          AppTheme.surface,
                        ],
                  stops: const [0.0, 0.4],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLocked
                      ? AppTheme.textMuted.withValues(alpha: 0.15)
                      : accentColor.withValues(alpha: _isPressed ? 0.4 : 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.2 : 0.4),
                    blurRadius: _isPressed ? 4 : 10,
                    offset: Offset(0, _isPressed ? 1 : 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // Left accent stripe - thicker for more impact
                Container(
                  width: 5,
                  height: 84,
                  decoration: BoxDecoration(
                    color: accentColor,
                    boxShadow: isLocked ? null : [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        // Icon container with accent color
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isLocked ? 0.08 : 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: isLocked ? null : Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            widget.mode.icon,
                            color: isLocked
                                ? AppTheme.textMuted
                                : accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.mode.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked
                                      ? AppTheme.textSecondary
                                      : AppTheme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (isLocked && !widget.mode.isPremiumOnly)
                                // Show unlock progress
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _progressText ?? 'Locked',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: SizedBox(
                                        height: 3,
                                        child: LinearProgressIndicator(
                                          value: widget.unlockProgress,
                                          backgroundColor: AppTheme.elevated,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else if (isLocked && widget.mode.isPremiumOnly)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: AppTheme.gold, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.gold,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  widget.mode.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLocked ? Icons.lock_outline : Icons.chevron_right,
                          color: isLocked
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ],
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
}

/// Premium unlock button at bottom of home screen with shimmer effect
class _UnlockAllButton extends StatefulWidget {
  final VoidCallback onTap;

  const _UnlockAllButton({required this.onTap});

  @override
  State<_UnlockAllButton> createState() => _UnlockAllButtonState();
}

class _UnlockAllButtonState extends State<_UnlockAllButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticService.tap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [AppTheme.gold, Color(0xFFFFD700), AppTheme.gold],
                  stops: [
                    0.0,
                    (_shimmerAnimation.value).clamp(0.0, 1.0),
                    1.0,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: _isPressed ? 0.2 : 0.5),
                    blurRadius: _isPressed ? 6 : 14,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, color: Colors.black, size: 22),
              SizedBox(width: 8),
              Text(
                'Unlock All Modes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '£2.49',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
                '10 Questions • Mixed Difficulty',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Test your knowledge',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Begin',
                backgroundColor: mode.color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenericQuestionScreen(mode: mode),
                    ),
                  );
                },
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
      if (!mounted) return;
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
                  return AnimatedAnswerButton(
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
  XPAward? _xpAward;
  int _currentStreak = 0;

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

    // Record streak activity
    final streakResult = await StreakService.recordActivity();

    // Award XP
    final isPerfect = widget.score == widget.totalQuestions;
    final xpAward = await XPService.awardXP(
      correctAnswers: widget.score,
      totalQuestions: widget.totalQuestions,
      modeId: widget.mode.id,
      streakDays: streakResult.streak,
      isPerfect: isPerfect,
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
      _xpAward = xpAward;
      _currentStreak = streakResult.streak;
    });

    // Celebrate perfect score or new best with confetti
    if (isPerfect || isNewBest || xpAward.leveledUp) {
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

  IconData _getVerdictIcon() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 50) return Icons.sports_soccer;
    return Icons.school;
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
                        'NEW RECORD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
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
                  // XP earned
                  if (_xpAward != null) ...[
                    const SizedBox(height: 20),
                    XPAwardDisplay(xpAward: _xpAward!, streak: _currentStreak),
                  ],
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
                    text: 'Kick Off Again',
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

/// Gamification header showing streak and level with pulse animation when at risk
class _GamificationHeader extends StatefulWidget {
  final int streak;
  final int level;
  final double levelProgress;
  final bool streakAtRisk;
  final VoidCallback onTap;

  const _GamificationHeader({
    required this.streak,
    required this.level,
    required this.levelProgress,
    required this.streakAtRisk,
    required this.onTap,
  });

  @override
  State<_GamificationHeader> createState() => _GamificationHeaderState();
}

class _GamificationHeaderState extends State<_GamificationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.streakAtRisk) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_GamificationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakAtRisk && !oldWidget.streakAtRisk) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.streakAtRisk && oldWidget.streakAtRisk) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticService.tap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: widget.streakAtRisk
                    ? Border.all(
                        color: AppTheme.gold.withValues(alpha: _pulseAnimation.value),
                        width: 1.5,
                      )
                    : null,
                boxShadow: widget.streakAtRisk
                    ? [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: _pulseAnimation.value * 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              // Streak indicator
              _StatPill(
                icon: Icons.local_fire_department,
                iconColor: widget.streak > 0 ? const Color(0xFFFF6B35) : AppTheme.textMuted,
                value: '${widget.streak}',
                label: 'day${widget.streak != 1 ? 's' : ''}',
                isHighlighted: widget.streakAtRisk,
              ),
              const SizedBox(width: 16),
              // Level indicator with progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Level ${widget.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          XPService.getLevelTitle(widget.level),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.levelProgress,
                        backgroundColor: AppTheme.elevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.highlight),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arrow to indicate tappable
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small stat pill for the gamification header
class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isHighlighted;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppTheme.gold : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Stats screen showing detailed progress
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalXP = 0;
  int _weeklyXP = 0;
  int _todayXP = 0;
  int _level = 1;
  double _levelProgress = 0.0;
  int _xpToNextLevel = 0;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    final currentStreak = await StreakService.getCurrentStreak();
    final longestStreak = await StreakService.getLongestStreak();
    final totalXP = await XPService.getTotalXP();
    final weeklyXP = await XPService.getWeeklyXP();
    final todayXP = await XPService.getTodayXP();
    final level = await XPService.getCurrentLevel();
    final levelProgress = await XPService.getLevelProgress();
    final xpToNext = await XPService.getXPToNextLevel();
    final stats = await StatsService.getTotalStats();

    if (mounted) {
      setState(() {
        _currentStreak = currentStreak;
        _longestStreak = longestStreak;
        _totalXP = totalXP;
        _weeklyXP = weeklyXP;
        _todayXP = todayXP;
        _level = level;
        _levelProgress = levelProgress;
        _xpToNextLevel = xpToNext;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Stats',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.highlight))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level card
                  _LevelCard(
                    level: _level,
                    levelProgress: _levelProgress,
                    totalXP: _totalXP,
                    xpToNextLevel: _xpToNextLevel,
                  ),
                  const SizedBox(height: 20),
                  // Streak section
                  _SectionTitle(title: 'Streak'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFFF6B35),
                          title: 'Current',
                          value: '$_currentStreak',
                          subtitle: 'day${_currentStreak != 1 ? 's' : ''}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events,
                          iconColor: AppTheme.gold,
                          title: 'Longest',
                          value: '$_longestStreak',
                          subtitle: 'day${_longestStreak != 1 ? 's' : ''}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // XP section
                  _SectionTitle(title: 'Experience'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.today,
                          iconColor: AppTheme.highlight,
                          title: 'Today',
                          value: '$_todayXP',
                          subtitle: 'XP',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.date_range,
                          iconColor: AppTheme.correct,
                          title: 'This Week',
                          value: '$_weeklyXP',
                          subtitle: 'XP',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quiz stats section
                  _SectionTitle(title: 'Performance'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          iconColor: AppTheme.quizYourClub,
                          title: 'Quizzes',
                          value: '${_stats['quizzesPlayed'] ?? 0}',
                          subtitle: 'played',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          iconColor: AppTheme.correct,
                          title: 'Correct',
                          value: '${_stats['totalCorrect'] ?? 0}',
                          subtitle: 'answers',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star,
                          iconColor: AppTheme.gold,
                          title: 'Perfect',
                          value: '${_stats['perfectScores'] ?? 0}',
                          subtitle: 'scores',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.percent,
                          iconColor: AppTheme.silver,
                          title: 'Accuracy',
                          value: _getAccuracy(),
                          subtitle: '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getAccuracy() {
    final total = _stats['totalQuestions'] ?? 0;
    final correct = _stats['totalCorrect'] ?? 0;
    if (total == 0) return '--%';
    return '${((correct / total) * 100).round()}%';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final double levelProgress;
  final int totalXP;
  final int xpToNextLevel;

  const _LevelCard({
    required this.level,
    required this.levelProgress,
    required this.totalXP,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.elevated, AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.highlight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.highlight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      XPService.getLevelTitle(level),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalXP XP total',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '$xpToNextLevel XP to go',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.highlight),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

