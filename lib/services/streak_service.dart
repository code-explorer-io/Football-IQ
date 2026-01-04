import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Daily streak tracking service
/// Tracks consecutive days of app usage (playing at least one quiz)
class StreakService {
  static const String _currentStreakKey = 'daily_streak_current';
  static const String _longestStreakKey = 'daily_streak_longest';
  static const String _lastPlayDateKey = 'daily_streak_last_date';
  static const String _streakFreezeKey = 'streak_freeze_count';

  /// Get current daily streak
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if streak is still valid (played yesterday or today)
    final lastPlayDate = prefs.getString(_lastPlayDateKey);
    if (lastPlayDate == null) return 0;

    final lastDate = DateTime.parse(lastPlayDate);
    final today = _getDateOnly(DateTime.now());
    final daysDiff = today.difference(_getDateOnly(lastDate)).inDays;

    // If more than 1 day has passed, streak is broken
    if (daysDiff > 1) {
      await _resetStreak();
      return 0;
    }

    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Get longest streak ever
  static Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Record activity for today
  /// Call this when a quiz is completed
  /// Returns the new streak count and whether it increased
  static Future<({int streak, bool increased, bool isNewRecord})> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();

    final lastPlayDate = prefs.getString(_lastPlayDateKey);
    final today = _getDateOnly(DateTime.now());
    final todayStr = today.toIso8601String();

    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    bool increased = false;

    if (lastPlayDate == null) {
      // First time playing
      currentStreak = 1;
      increased = true;
    } else {
      final lastDate = _getDateOnly(DateTime.parse(lastPlayDate));
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Already played today, no change to streak
        increased = false;
      } else if (daysDiff == 1) {
        // Consecutive day - increase streak
        currentStreak++;
        increased = true;
      } else {
        // Streak broken - start fresh
        currentStreak = 1;
        increased = true;
      }
    }

    // Update storage
    await prefs.setInt(_currentStreakKey, currentStreak);
    await prefs.setString(_lastPlayDateKey, todayStr);

    // Check and update longest streak
    final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    final isNewRecord = currentStreak > longestStreak;
    if (isNewRecord) {
      await prefs.setInt(_longestStreakKey, currentStreak);
    }

    // Track streak milestones (7, 14, 30, 60, 100 days)
    if (increased && _isStreakMilestone(currentStreak)) {
      AnalyticsService.logStreakMilestone(currentStreak);
    }

    return (streak: currentStreak, increased: increased, isNewRecord: isNewRecord);
  }

  /// Check if streak count is a milestone worth tracking
  static bool _isStreakMilestone(int streak) {
    return streak == 7 || streak == 14 || streak == 30 || streak == 60 || streak == 100;
  }

  /// Check if user has played today
  static Future<bool> hasPlayedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayDate = prefs.getString(_lastPlayDateKey);

    if (lastPlayDate == null) return false;

    final lastDate = _getDateOnly(DateTime.parse(lastPlayDate));
    final today = _getDateOnly(DateTime.now());

    return lastDate.isAtSameMomentAs(today);
  }

  /// Check if streak is at risk (hasn't played today and played yesterday)
  static Future<bool> isStreakAtRisk() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayDate = prefs.getString(_lastPlayDateKey);
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;

    if (lastPlayDate == null || currentStreak == 0) return false;

    final lastDate = _getDateOnly(DateTime.parse(lastPlayDate));
    final today = _getDateOnly(DateTime.now());
    final daysDiff = today.difference(lastDate).inDays;

    // At risk if played yesterday but not today
    return daysDiff == 1;
  }

  /// Get days until streak expires (0 = expires today, 1 = expires tomorrow)
  static Future<int> getDaysUntilStreakExpires() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayDate = prefs.getString(_lastPlayDateKey);

    if (lastPlayDate == null) return 0;

    final lastDate = _getDateOnly(DateTime.parse(lastPlayDate));
    final today = _getDateOnly(DateTime.now());
    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) return 1; // Played today, expires tomorrow
    if (daysDiff == 1) return 0; // Played yesterday, expires today
    return -1; // Already expired
  }

  /// Reset streak (internal use)
  static Future<void> _resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStreakKey, 0);
  }

  /// Get date only (no time component)
  static DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Reset all streak data (for testing)
  static Future<void> resetAllStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_longestStreakKey);
    await prefs.remove(_lastPlayDateKey);
    await prefs.remove(_streakFreezeKey);
  }
}
