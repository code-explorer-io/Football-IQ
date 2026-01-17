import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_service.dart';

/// Manages game mode unlock progression
///
/// Unlock Flow:
/// 1. Club Quiz - Always unlocked (starting mode)
/// 2. Higher or Lower - Complete 2 Club Quizzes (fun casual mode)
/// 3. Survival Mode - Win 3 Higher or Lower games (harder mode)
/// 4. International Cup - Get 5+ streak in Survival
/// 5. Tournament Mode - Win a Cup (future)
///
/// Premium users have all modes unlocked immediately.
class UnlockService {
  // DEV MODE: Set to true to unlock all modes for testing
  // IMPORTANT: Must be false for production release!
  // SAFETY: This assertion will fail in release builds if left true
  static const bool devModeUnlockAll = false;

  /// Call this at app startup to verify dev mode is disabled in release builds
  static void assertDevModeDisabled() {
    assert(
      kDebugMode || !devModeUnlockAll,
      'CRITICAL: devModeUnlockAll must be false for production builds!',
    );
  }

  static const String _keyClubQuizzesCompleted = 'unlock_club_quizzes_completed';
  static const String _keyBestSurvivalStreak = 'unlock_best_survival_streak';
  static const String _keyHigherOrLowerWins = 'unlock_higher_or_lower_wins';
  static const String _keyCupWins = 'unlock_cup_wins';

  // Unlock thresholds
  // Note: Only West Ham is free, so keep quiz count low to avoid tedium
  static const int higherOrLowerUnlockQuizzes = 2; // Complete 2 Club Quizzes
  static const int survivalUnlockWins = 3; // Win 3 Higher or Lower games
  static const int cupModeUnlockStreak = 5; // Get 5+ streak in Survival
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
      case 'higher_or_lower':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return quizzes >= higherOrLowerUnlockQuizzes;

      case 'survival_mode':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return wins >= survivalUnlockWins;

      case 'international_cup':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return streak >= cupModeUnlockStreak;

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
      case 'higher_or_lower':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return (quizzes / higherOrLowerUnlockQuizzes).clamp(0.0, 1.0);

      case 'survival_mode':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return (wins / survivalUnlockWins).clamp(0.0, 1.0);

      case 'international_cup':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return (streak / cupModeUnlockStreak).clamp(0.0, 1.0);

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
      case 'higher_or_lower':
        return 'Finish $higherOrLowerUnlockQuizzes club quizzes (any score)';
      case 'survival_mode':
        return 'Score 8+ in $survivalUnlockWins Higher or Lower games';
      case 'international_cup':
        return 'Answer $cupModeUnlockStreak in a row in Survival';
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
      case 'higher_or_lower':
        final quizzes = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
        return '$quizzes/$higherOrLowerUnlockQuizzes quizzes';
      case 'survival_mode':
        final wins = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
        return '$wins/$survivalUnlockWins wins';
      case 'international_cup':
        final streak = prefs.getInt(_keyBestSurvivalStreak) ?? 0;
        return '$streak/$cupModeUnlockStreak streak';
      case 'tournament_mode':
        final cupWins = prefs.getInt(_keyCupWins) ?? 0;
        return '$cupWins/$tournamentUnlockCupWins cup wins';
      default:
        return '';
    }
  }

  // ========== Progress Recording Methods ==========

  /// Record a completed club quiz (for Higher or Lower unlock)
  static Future<UnlockResult> recordClubQuizCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyClubQuizzesCompleted) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_keyClubQuizzesCompleted, newValue);

    // Check if this unlocked Higher or Lower
    if (current < higherOrLowerUnlockQuizzes && newValue >= higherOrLowerUnlockQuizzes) {
      return UnlockResult(
        unlockedModeId: 'higher_or_lower',
        unlockedModeName: 'Higher or Lower',
      );
    }
    return UnlockResult();
  }

  /// Record a Higher or Lower win (for Survival Mode unlock)
  static Future<UnlockResult> recordHigherOrLowerWin() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyHigherOrLowerWins) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_keyHigherOrLowerWins, newValue);

    // Check if this unlocked Survival Mode
    if (current < survivalUnlockWins && newValue >= survivalUnlockWins) {
      return UnlockResult(
        unlockedModeId: 'survival_mode',
        unlockedModeName: 'Survival Mode',
      );
    }
    return UnlockResult();
  }

  /// Record best survival streak (for International Cup unlock)
  static Future<UnlockResult> recordSurvivalStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBestSurvivalStreak) ?? 0;

    if (streak > current) {
      await prefs.setInt(_keyBestSurvivalStreak, streak);

      // Check if this unlocked International Cup
      if (current < cupModeUnlockStreak && streak >= cupModeUnlockStreak) {
        return UnlockResult(
          unlockedModeId: 'international_cup',
          unlockedModeName: 'International Cup',
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
