import 'package:shared_preferences/shared_preferences.dart';

/// XP (Experience Points) service for gamification
/// Professional, understated approach - XP represents accumulated knowledge
class XPService {
  static const String _totalXPKey = 'total_xp';
  static const String _levelKey = 'current_level';
  static const String _weeklyXPKey = 'weekly_xp';
  static const String _weekStartKey = 'week_start_date';
  static const String _todayXPKey = 'today_xp';
  static const String _todayDateKey = 'today_date';

  // XP rewards - balanced for professional feel
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerfectQuizBonus = 50;
  static const int xpStreakBonus = 25; // Per streak day
  static const int xpSpeedBonus = 5; // For quick answers
  static const int xpSurvivalPerQuestion = 15; // Higher stakes = more XP
  static const int xpBlitzPerCorrect = 12;

  // Level thresholds - logarithmic progression
  static const List<int> levelThresholds = [
    0,      // Level 1
    100,    // Level 2
    250,    // Level 3
    500,    // Level 4
    800,    // Level 5
    1200,   // Level 6
    1700,   // Level 7
    2300,   // Level 8
    3000,   // Level 9
    4000,   // Level 10
    5000,   // Level 11
    6500,   // Level 12
    8000,   // Level 13
    10000,  // Level 14
    12500,  // Level 15
    15000,  // Level 16
    18000,  // Level 17
    22000,  // Level 18
    27000,  // Level 19
    33000,  // Level 20 (max display, continues beyond)
  ];

  /// Get total XP earned
  static Future<int> getTotalXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXPKey) ?? 0;
  }

  /// Get current level based on XP
  static Future<int> getCurrentLevel() async {
    final totalXP = await getTotalXP();
    return getLevelForXP(totalXP);
  }

  /// Calculate level for given XP amount
  static int getLevelForXP(int xp) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (xp >= levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  /// Get XP progress within current level (0.0 to 1.0)
  static Future<double> getLevelProgress() async {
    final totalXP = await getTotalXP();
    final level = getLevelForXP(totalXP);

    if (level >= levelThresholds.length) return 1.0;

    final currentLevelXP = levelThresholds[level - 1];
    final nextLevelXP = levelThresholds[level];
    final xpIntoLevel = totalXP - currentLevelXP;
    final xpNeeded = nextLevelXP - currentLevelXP;

    return xpIntoLevel / xpNeeded;
  }

  /// Get XP needed for next level
  static Future<int> getXPToNextLevel() async {
    final totalXP = await getTotalXP();
    final level = getLevelForXP(totalXP);

    if (level >= levelThresholds.length) return 0;

    return levelThresholds[level] - totalXP;
  }

  /// Award XP and return details
  static Future<XPAward> awardXP({
    required int correctAnswers,
    required int totalQuestions,
    required String modeId,
    int? streakDays,
    bool isPerfect = false,
    int? secondsRemaining, // For timed modes
    int fastAnswerCount = 0, // Fast answers (under 5 seconds)
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final previousXP = prefs.getInt(_totalXPKey) ?? 0;
    final previousLevel = getLevelForXP(previousXP);

    // Calculate XP based on mode
    int baseXP = 0;
    int bonusXP = 0;
    List<String> bonusReasons = [];

    switch (modeId) {
      case 'quiz_your_club':
        baseXP = correctAnswers * xpPerCorrectAnswer;
        break;
      case 'survival_mode':
        baseXP = correctAnswers * xpSurvivalPerQuestion;
        break;
      case 'timed_blitz':
        baseXP = correctAnswers * xpBlitzPerCorrect;
        // Speed bonus for time remaining
        if (secondsRemaining != null && secondsRemaining > 0) {
          final speedBonus = (secondsRemaining / 10).round() * xpSpeedBonus;
          bonusXP += speedBonus;
          if (speedBonus > 0) {
            bonusReasons.add('Speed Bonus +$speedBonus');
          }
        }
        break;
      case 'higher_or_lower':
        baseXP = correctAnswers * xpPerCorrectAnswer;
        break;
      default:
        baseXP = correctAnswers * xpPerCorrectAnswer;
    }

    // Perfect quiz bonus
    if (isPerfect && totalQuestions >= 5) {
      bonusXP += xpPerfectQuizBonus;
      bonusReasons.add('Perfect +$xpPerfectQuizBonus');
    }

    // Streak bonus (multiplier based on streak length)
    if (streakDays != null && streakDays > 1) {
      final streakBonus = (streakDays - 1) * xpStreakBonus;
      bonusXP += streakBonus.clamp(0, 100); // Cap at 100 bonus
      if (streakBonus > 0) {
        bonusReasons.add('$streakDays-Day Streak +${streakBonus.clamp(0, 100)}');
      }
    }

    // Fast answer bonus (5 XP per fast answer)
    if (fastAnswerCount > 0) {
      final fastBonus = fastAnswerCount * xpSpeedBonus;
      bonusXP += fastBonus;
      bonusReasons.add('Quick Reflexes x$fastAnswerCount +$fastBonus');
    }

    final totalXPEarned = baseXP + bonusXP;
    final newTotalXP = previousXP + totalXPEarned;
    final newLevel = getLevelForXP(newTotalXP);
    final leveledUp = newLevel > previousLevel;

    // Save new total
    await prefs.setInt(_totalXPKey, newTotalXP);

    // Update weekly XP
    await _updateWeeklyXP(totalXPEarned);

    // Update today's XP
    await _updateTodayXP(totalXPEarned);

    return XPAward(
      baseXP: baseXP,
      bonusXP: bonusXP,
      totalXPEarned: totalXPEarned,
      newTotalXP: newTotalXP,
      previousLevel: previousLevel,
      newLevel: newLevel,
      leveledUp: leveledUp,
      bonusReasons: bonusReasons,
    );
  }

  /// Update weekly XP tracking
  static Future<void> _updateWeeklyXP(int xpEarned) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final storedWeekStart = prefs.getString(_weekStartKey);

    if (storedWeekStart == null ||
        DateTime.parse(storedWeekStart).isBefore(weekStart)) {
      // New week - reset weekly XP
      await prefs.setString(_weekStartKey, weekStart.toIso8601String());
      await prefs.setInt(_weeklyXPKey, xpEarned);
    } else {
      // Same week - add to total
      final currentWeekly = prefs.getInt(_weeklyXPKey) ?? 0;
      await prefs.setInt(_weeklyXPKey, currentWeekly + xpEarned);
    }
  }

  /// Update today's XP tracking
  static Future<void> _updateTodayXP(int xpEarned) async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final storedToday = prefs.getString(_todayDateKey);

    if (storedToday != todayStr) {
      // New day - reset today's XP
      await prefs.setString(_todayDateKey, todayStr);
      await prefs.setInt(_todayXPKey, xpEarned);
    } else {
      // Same day - add to total
      final currentToday = prefs.getInt(_todayXPKey) ?? 0;
      await prefs.setInt(_todayXPKey, currentToday + xpEarned);
    }
  }

  /// Get start of current week (Monday)
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get weekly XP
  static Future<int> getWeeklyXP() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we're still in the same week
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final storedWeekStart = prefs.getString(_weekStartKey);

    if (storedWeekStart == null ||
        DateTime.parse(storedWeekStart).isBefore(weekStart)) {
      return 0; // New week, no XP yet
    }

    return prefs.getInt(_weeklyXPKey) ?? 0;
  }

  /// Get today's XP
  static Future<int> getTodayXP() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final storedToday = prefs.getString(_todayDateKey);

    if (storedToday != todayStr) {
      return 0; // New day, no XP yet
    }

    return prefs.getInt(_todayXPKey) ?? 0;
  }

  /// Get level title (professional football-themed)
  static String getLevelTitle(int level) {
    if (level >= 20) return 'Legend';
    if (level >= 18) return 'Icon';
    if (level >= 16) return 'World Class';
    if (level >= 14) return 'Elite';
    if (level >= 12) return 'International';
    if (level >= 10) return 'Professional';
    if (level >= 8) return 'Semi-Pro';
    if (level >= 6) return 'Club Player';
    if (level >= 4) return 'Sunday League';
    if (level >= 2) return 'Park Footballer';
    return 'Amateur';
  }

  /// Reset all XP data (for testing)
  static Future<void> resetAllXPData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalXPKey);
    await prefs.remove(_levelKey);
    await prefs.remove(_weeklyXPKey);
    await prefs.remove(_weekStartKey);
    await prefs.remove(_todayXPKey);
    await prefs.remove(_todayDateKey);
  }
}

/// Result of awarding XP
class XPAward {
  final int baseXP;
  final int bonusXP;
  final int totalXPEarned;
  final int newTotalXP;
  final int previousLevel;
  final int newLevel;
  final bool leveledUp;
  final List<String> bonusReasons;

  XPAward({
    required this.baseXP,
    required this.bonusXP,
    required this.totalXPEarned,
    required this.newTotalXP,
    required this.previousLevel,
    required this.newLevel,
    required this.leveledUp,
    required this.bonusReasons,
  });
}
