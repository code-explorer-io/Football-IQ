import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics service for tracking user behavior.
/// All events are logged to Firebase Analytics.
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ SCREEN VIEWS ============

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ============ GAME MODE EVENTS ============

  /// User selected a game mode from home screen
  static Future<void> logModeSelected(String modeName) async {
    await _analytics.logEvent(
      name: 'mode_selected',
      parameters: {'mode_name': modeName},
    );
  }

  /// User started a quiz/game
  static Future<void> logGameStarted({
    required String modeName,
    String? clubName,
  }) async {
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'mode_name': modeName,
        if (clubName != null) 'club_name': clubName,
      },
    );
  }

  /// User completed a quiz/game
  static Future<void> logGameCompleted({
    required String modeName,
    required int score,
    required int totalQuestions,
    required int xpEarned,
    String? clubName,
  }) async {
    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'mode_name': modeName,
        'score': score,
        'total_questions': totalQuestions,
        'percentage': totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0,
        'xp_earned': xpEarned,
        if (clubName != null) 'club_name': clubName,
      },
    );
  }

  /// User got a perfect score
  static Future<void> logPerfectScore(String modeName) async {
    await _analytics.logEvent(
      name: 'perfect_score',
      parameters: {'mode_name': modeName},
    );
  }

  // ============ PROGRESSION EVENTS ============

  /// User leveled up
  static Future<void> logLevelUp(int newLevel, String levelTitle) async {
    await _analytics.logEvent(
      name: 'level_up',
      parameters: {
        'new_level': newLevel,
        'level_title': levelTitle,
      },
    );
  }

  /// User achieved a streak milestone
  static Future<void> logStreakMilestone(int streakDays) async {
    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {'streak_days': streakDays},
    );
  }

  /// User unlocked an achievement
  static Future<void> logAchievementUnlocked(String achievementId, String achievementName) async {
    await _analytics.logUnlockAchievement(id: achievementId);
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
      },
    );
  }

  // ============ ENGAGEMENT EVENTS ============

  /// User opened the app (daily active)
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// User tapped play again
  static Future<void> logPlayAgain(String modeName) async {
    await _analytics.logEvent(
      name: 'play_again',
      parameters: {'mode_name': modeName},
    );
  }

  /// User viewed stats screen
  static Future<void> logStatsViewed() async {
    await _analytics.logEvent(name: 'stats_viewed');
  }

  // ============ MONETIZATION EVENTS ============

  /// User viewed the paywall/upgrade screen
  static Future<void> logPaywallViewed() async {
    await _analytics.logEvent(name: 'paywall_viewed');
  }

  /// User started purchase flow
  static Future<void> logPurchaseStarted() async {
    await _analytics.logEvent(name: 'purchase_started');
  }

  /// User completed purchase
  static Future<void> logPurchaseCompleted(double price, String currency) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
    );
  }

  /// User restored purchases
  static Future<void> logPurchaseRestored() async {
    await _analytics.logEvent(name: 'purchase_restored');
  }

  // ============ USER PROPERTIES ============

  /// Set user's current level
  static Future<void> setUserLevel(int level) async {
    await _analytics.setUserProperty(name: 'user_level', value: level.toString());
  }

  /// Set user's total XP
  static Future<void> setUserXP(int totalXP) async {
    await _analytics.setUserProperty(name: 'total_xp', value: totalXP.toString());
  }

  /// Set user's current streak
  static Future<void> setUserStreak(int streakDays) async {
    await _analytics.setUserProperty(name: 'streak_days', value: streakDays.toString());
  }

  /// Set whether user is premium
  static Future<void> setUserPremium(bool isPremium) async {
    await _analytics.setUserProperty(name: 'is_premium', value: isPremium.toString());
  }
}
