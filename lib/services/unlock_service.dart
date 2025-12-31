import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_service.dart';

/// Manages game mode unlock progression
///
/// Unlock Flow:
/// 1. Club Quiz - Always unlocked (starting mode)
/// 2. Survival Mode - Complete 5 Club Quizzes
/// 3. Higher or Lower - Get 10+ streak in Survival
/// 4. Cup Mode - Win 3 Higher or Lower games
/// 5. Tournament Mode - Win a Cup (future)
///
/// PARKED: Timed Blitz (similar to Survival, will introduce later)
///
/// Premium users have all modes unlocked immediately.
class UnlockService {
  // DEV MODE: Set to true to unlock all modes for testing
  // IMPORTANT: Must be false for production release!
  static const bool devModeUnlockAll = false;

  static const String _keyClubQuizzesCompleted = 'unlock_club_quizzes_completed';
  static const String _keyBestSurvivalStreak = 'unlock_best_survival_streak';
  static const String _keyHigherOrLowerWins = 'unlock_higher_or_lower_wins';
  static const String _keyCupWins = 'unlock_cup_wins';

  // Unlock thresholds
  static const int survivalUnlockQuizzes = 5;
  static const int higherOrLowerUnlockStreak = 10; // Streak in Survival to unlock H/L
  static const int cupModeUnlockWins = 3;
  static const int tournamentUnlockCupWins = 1;

  /// Check if a mode is unlocked (either through progression or premium)
  static Future<bool> isModeUnlocked(String modeId) async {
    // DEV MODE: Unlock everything for testing
    if (devModeUnlockAll) return true;

    // Premium users have everything unlocked
    if (PurchaseService.isPremium) return true;

    // Club Quiz is always free
    if (modeId == 'quiz_your_club') return true;

    final prefs = await SharedPreferences.getInstance();

    switch (modeId) {
      case 'survival_mode':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return quizzes >= survivalUnlockQuizzes;

      case 'higher_or_lower':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return streak >= higherOrLowerUnlockStreak;

      case 'international_cup':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return wins >= cupModeUnlockWins;

      case 'premier_league_legends':
        // This is a premium-only mode, not part of unlock chain
        return false;

      case 'tournament_mode':
        final cupWins = prefs.getInt(_keyCupWins) ?? 0;
        return cupWins >= tournamentUnlockCupWins;

      default:
        return false;
    }
  }

  /// Get unlock progress for a mode (returns value between 0.0 and 1.0)
  static Future<double> getUnlockProgress(String modeId) async {
    if (PurchaseService.isPremium) return 1.0;
    if (modeId == 'quiz_your_club') return 1.0;

    final prefs = await SharedPreferences.getInstance();

    switch (modeId) {
      case 'survival_mode':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return (quizzes / survivalUnlockQuizzes).clamp(0.0, 1.0);

      case 'higher_or_lower':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return (streak / higherOrLowerUnlockStreak).clamp(0.0, 1.0);

      case 'international_cup':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return (wins / cupModeUnlockWins).clamp(0.0, 1.0);

      case 'tournament_mode':
        final cupWins = prefs.getInt(_keyCupWins) ?? 0;
        return (cupWins / tournamentUnlockCupWins).clamp(0.0, 1.0);

      default:
        return 0.0;
    }
  }

  /// Get unlock requirement description for a mode
  static String getUnlockRequirement(String modeId) {
    switch (modeId) {
      case 'survival_mode':
        return 'Complete $survivalUnlockQuizzes Club Quizzes';
      case 'higher_or_lower':
        return 'Get $higherOrLowerUnlockStreak+ streak in Survival';
      case 'international_cup':
        return 'Win $cupModeUnlockWins Higher or Lower games';
      case 'tournament_mode':
        return 'Win a Cup';
      case 'premier_league_legends':
        return 'Premium Only';
      default:
        return '';
    }
  }

  /// Get current progress text for a mode
  static Future<String> getProgressText(String modeId) async {
    final prefs = await SharedPreferences.getInstance();

    switch (modeId) {
      case 'survival_mode':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return '$quizzes/$survivalUnlockQuizzes quizzes';
      case 'higher_or_lower':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return '$streak/$higherOrLowerUnlockStreak streak';
      case 'international_cup':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return '$wins/$cupModeUnlockWins wins';
      case 'tournament_mode':
        final cupWins = prefs.getInt(_keyCupWins) ?? 0;
        return '$cupWins/$tournamentUnlockCupWins cup wins';
      default:
        return '';
    }
  }

  // ========== Progress Recording Methods ==========

  /// Record a completed club quiz (for Survival unlock)
  static Future<UnlockResult> recordClubQuizCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_keyClubQuizzesCompleted, newValue);

    // Check if this unlocked Survival Mode
    if (current < survivalUnlockQuizzes && newValue >= survivalUnlockQuizzes) {
      return UnlockResult(
        unlockedModeId: 'survival_mode',
        unlockedModeName: 'Survival Mode',
      );
    }
    return UnlockResult();
  }

  /// Record best survival streak (for Higher or Lower unlock)
  static Future<UnlockResult> recordSurvivalStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBestSurvivalStreak) ?? 0;

    if (streak > current) {
      await prefs.setInt(_keyBestSurvivalStreak, streak);

      // Check if this unlocked Higher or Lower
      if (current < higherOrLowerUnlockStreak && streak >= higherOrLowerUnlockStreak) {
        return UnlockResult(
          unlockedModeId: 'higher_or_lower',
          unlockedModeName: 'Higher or Lower',
        );
      }
    }
    return UnlockResult();
  }

  /// PARKED: Record timed blitz score (Timed Blitz mode is parked)
  /// Keeping this method so the screen code still compiles
  static Future<UnlockResult> recordTimedBlitzScore(int score) async {
    // Timed Blitz is parked - this method does nothing
    return UnlockResult();
  }

  /// Record a Higher or Lower win (for Cup Mode unlock)
  static Future<UnlockResult> recordHigherOrLowerWin() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_keyHigherOrLowerWins, newValue);

    // Check if this unlocked Cup Mode
    if (current < cupModeUnlockWins && newValue >= cupModeUnlockWins) {
      return UnlockResult(
        unlockedModeId: 'international_cup',
        unlockedModeName: 'International Cup',
      );
    }
    return UnlockResult();
  }

  /// Record a Cup win (for Tournament Mode unlock)
  static Future<UnlockResult> recordCupWin() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCupWins) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_keyCupWins, newValue);

    // Check if this unlocked Tournament Mode
    if (current < tournamentUnlockCupWins && newValue >= tournamentUnlockCupWins) {
      return UnlockResult(
        unlockedModeId: 'tournament_mode',
        unlockedModeName: 'Tournament Mode',
      );
    }
    return UnlockResult();
  }

  // ========== Utility Methods ==========

  /// Get all unlock stats for debugging/display
  static Future<Map<String, int>> getAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'clubQuizzesCompleted': prefs.getInt(_keyClubQuizzesCompleted) ?? 0,
      'bestSurvivalStreak': prefs.getInt(_keyBestSurvivalStreak) ?? 0,
      'higherOrLowerWins': prefs.getInt(_keyHigherOrLowerWins) ?? 0,
      'cupWins': prefs.getInt(_keyCupWins) ?? 0,
    };
  }

  /// Reset all unlock progress (for testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyClubQuizzesCompleted);
    await prefs.remove(_keyBestSurvivalStreak);
    await prefs.remove(_keyHigherOrLowerWins);
    await prefs.remove(_keyCupWins);
  }
}

/// Result of recording progress - may include a newly unlocked mode
class UnlockResult {
  final String? unlockedModeId;
  final String? unlockedModeName;

  UnlockResult({this.unlockedModeId, this.unlockedModeName});

  bool get didUnlock => unlockedModeId != null;
}
