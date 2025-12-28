import 'package:shared_preferences/shared_preferences.dart';

/// Stats tracking service for Football IQ rating and form guide
///
/// Football IQ Rating: 0-99 scale (like FIFA player ratings)
/// - Starts at 50 (average)
/// - Increases with correct answers, streaks, achievements
/// - Decreases slightly with poor performance (floor of 30)
///
/// Form Guide: Last 5 quiz results as W/D/L
/// - W (Win): 8+ correct out of 10 (80%+)
/// - D (Draw): 5-7 correct out of 10 (50-79%)
/// - L (Loss): 0-4 correct out of 10 (<50%)
class StatsService {
  static const String _iqKey = 'football_iq_rating';
  static const String _formKey = 'form_guide';
  static const String _totalCorrectKey = 'total_correct_answers';
  static const String _totalQuestionsKey = 'total_questions_answered';
  static const String _quizzesPlayedKey = 'total_quizzes_played';
  static const String _perfectScoresKey = 'perfect_scores';
  static const String _currentStreakKey = 'current_daily_streak';
  static const String _lastPlayedKey = 'last_played_date';

  // Football IQ bounds
  static const int minIQ = 30;
  static const int maxIQ = 99;
  static const int startingIQ = 50;

  /// Get current Football IQ rating
  static Future<int> getFootballIQ() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_iqKey) ?? startingIQ;
  }

  /// Get form guide as list of results (W, D, L)
  /// Returns most recent first, max 5 entries
  static Future<List<String>> getFormGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final formString = prefs.getString(_formKey) ?? '';
    if (formString.isEmpty) return [];
    return formString.split(',').take(5).toList();
  }

  /// Record a quiz result and update all stats
  /// Returns the new Football IQ and whether it increased
  static Future<({int newIQ, int change, bool isPerfect})> recordQuizResult({
    required int score,
    required int totalQuestions,
    required String modeId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate percentage
    final percentage = (score / totalQuestions) * 100;
    final isPerfect = score == totalQuestions;

    // Update form guide
    String result;
    if (percentage >= 80) {
      result = 'W';
    } else if (percentage >= 50) {
      result = 'D';
    } else {
      result = 'L';
    }

    final currentForm = await getFormGuide();
    final newForm = [result, ...currentForm].take(5).join(',');
    await prefs.setString(_formKey, newForm);

    // Update totals
    final totalCorrect = (prefs.getInt(_totalCorrectKey) ?? 0) + score;
    final totalQuestions_ = (prefs.getInt(_totalQuestionsKey) ?? 0) + totalQuestions;
    final quizzesPlayed = (prefs.getInt(_quizzesPlayedKey) ?? 0) + 1;
    final perfectScores = (prefs.getInt(_perfectScoresKey) ?? 0) + (isPerfect ? 1 : 0);

    await prefs.setInt(_totalCorrectKey, totalCorrect);
    await prefs.setInt(_totalQuestionsKey, totalQuestions_);
    await prefs.setInt(_quizzesPlayedKey, quizzesPlayed);
    await prefs.setInt(_perfectScoresKey, perfectScores);

    // Calculate new Football IQ
    final currentIQ = prefs.getInt(_iqKey) ?? startingIQ;
    int iqChange = 0;

    // IQ adjustment based on performance
    if (isPerfect) {
      iqChange = 3; // Perfect score = big boost
    } else if (percentage >= 80) {
      iqChange = 2; // Great performance
    } else if (percentage >= 60) {
      iqChange = 1; // Good performance
    } else if (percentage >= 40) {
      iqChange = 0; // Average - no change
    } else {
      iqChange = -1; // Poor performance
    }

    // Bonus for streaks (consecutive Ws in form)
    final newFormList = newForm.split(',');
    if (newFormList.length >= 3 &&
        newFormList.take(3).every((r) => r == 'W')) {
      iqChange += 1; // Streak bonus
    }

    final newIQ = (currentIQ + iqChange).clamp(minIQ, maxIQ);
    await prefs.setInt(_iqKey, newIQ);

    // Update last played date
    await prefs.setString(_lastPlayedKey, DateTime.now().toIso8601String());

    return (newIQ: newIQ, change: iqChange, isPerfect: isPerfect);
  }

  /// Get total stats
  static Future<Map<String, int>> getTotalStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalCorrect': prefs.getInt(_totalCorrectKey) ?? 0,
      'totalQuestions': prefs.getInt(_totalQuestionsKey) ?? 0,
      'quizzesPlayed': prefs.getInt(_quizzesPlayedKey) ?? 0,
      'perfectScores': prefs.getInt(_perfectScoresKey) ?? 0,
    };
  }

  /// Get IQ tier name (like FIFA card ratings)
  static String getIQTier(int iq) {
    if (iq >= 90) return 'World Class';
    if (iq >= 80) return 'Elite';
    if (iq >= 70) return 'Professional';
    if (iq >= 60) return 'Semi-Pro';
    if (iq >= 50) return 'Amateur';
    if (iq >= 40) return 'Beginner';
    return 'Rookie';
  }

  /// Get IQ tier color
  static int getIQTierColor(int iq) {
    if (iq >= 90) return 0xFFD4AF37; // Gold
    if (iq >= 80) return 0xFFC0C0C0; // Silver
    if (iq >= 70) return 0xFFCD7F32; // Bronze
    if (iq >= 60) return 0xFF3498DB; // Blue
    if (iq >= 50) return 0xFF2ECC71; // Green
    return 0xFF95A5A6; // Grey
  }

  /// Reset all stats (for testing)
  static Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_iqKey);
    await prefs.remove(_formKey);
    await prefs.remove(_totalCorrectKey);
    await prefs.remove(_totalQuestionsKey);
    await prefs.remove(_quizzesPlayedKey);
    await prefs.remove(_perfectScoresKey);
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_lastPlayedKey);
  }
}
