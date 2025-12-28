import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _prefix = 'best_score_';

  // Get best score for a mode (or club within Quiz Your Club)
  static Future<int> getBestScore(String modeId, {String? clubId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = clubId != null ? '${_prefix}${modeId}_$clubId' : '$_prefix$modeId';
    return prefs.getInt(key) ?? 0;
  }

  // Save best score if it's higher than current best
  static Future<bool> saveBestScore(String modeId, int score, {String? clubId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = clubId != null ? '${_prefix}${modeId}_$clubId' : '$_prefix$modeId';
    final currentBest = prefs.getInt(key) ?? 0;

    if (score > currentBest) {
      await prefs.setInt(key, score);
      return true; // New high score!
    }
    return false; // Not a new high score
  }

  // Get best streak for Survival Mode
  static Future<int> getBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}survival_streak') ?? 0;
  }

  // Save best streak for Survival Mode
  static Future<bool> saveBestStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('${_prefix}survival_streak') ?? 0;

    if (streak > currentBest) {
      await prefs.setInt('${_prefix}survival_streak', streak);
      return true;
    }
    return false;
  }

  // Get best score for Timed Blitz
  static Future<int> getBlitzBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}timed_blitz') ?? 0;
  }

  // Save best score for Timed Blitz
  static Future<bool> saveBlitzBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('${_prefix}timed_blitz') ?? 0;

    if (score > currentBest) {
      await prefs.setInt('${_prefix}timed_blitz', score);
      return true;
    }
    return false;
  }

  // Clear all scores (for testing/reset)
  static Future<void> clearAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
