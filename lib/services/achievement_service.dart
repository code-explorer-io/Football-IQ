import 'package:shared_preferences/shared_preferences.dart';

/// Achievement definitions with football-themed names
/// Design principle: Earned, not given. Sophisticated, not childish.
enum Achievement {
  // Score-based
  cleanSheet('Clean Sheet', 'Score 10/10 on a quiz', 'clean_sheet'),
  hatTrick('Hat Trick', 'Get 3 perfect scores', 'hat_trick'),
  pokerHand('Poker', 'Get 4 perfect scores in a row', 'poker_hand'),
  centuryMaker('Century Maker', '100 correct answers total', 'century_maker'),
  doublecentury('Double Century', '200 correct answers total', 'double_century'),

  // Streak-based
  onForm('On Form', '3 quiz wins (80%+) in a row', 'on_form'),
  hotStreak('Hot Streak', '5 quiz wins in a row', 'hot_streak'),
  unbeaten('Unbeaten Run', '10 quizzes without a loss (<50%)', 'unbeaten'),

  // Survival mode
  survivor('Survivor', 'Reach 10 streak in Survival', 'survivor'),
  endurance('Endurance', 'Reach 20 streak in Survival', 'endurance'),
  ironMan('Iron Man', 'Reach 30 streak in Survival', 'iron_man'),

  // Variety
  groundHopper('Ground Hopper', 'Complete quiz for 3 different clubs', 'ground_hopper'),
  allRounder('All-Rounder', 'Play all 5 game modes', 'all_rounder'),
  specialist('Specialist', 'Score 90%+ in same mode 5 times', 'specialist'),

  // Time-based
  earlyKickOff('Early Kick-Off', 'Play before 9am', 'early_kick_off'),
  midweekFixture('Midweek Fixture', 'Play on a Wednesday', 'midweek_fixture'),
  weekendWarrior('Weekend Warrior', 'Play on Saturday and Sunday', 'weekend_warrior'),

  // IQ milestones
  risingTalent('Rising Talent', 'Reach Football IQ of 60', 'rising_talent'),
  establishedPro('Established Pro', 'Reach Football IQ of 70', 'established_pro'),
  eliteStatus('Elite Status', 'Reach Football IQ of 80', 'elite_status'),
  worldClass('World Class', 'Reach Football IQ of 90', 'world_class');

  final String title;
  final String description;
  final String id;

  const Achievement(this.title, this.description, this.id);
}

/// Achievement tiers for visual styling
enum AchievementTier { bronze, silver, gold, platinum }

class AchievementService {
  static const String _prefix = 'achievement_';
  static const String _unlockedAtPrefix = 'achievement_unlocked_at_';

  /// Check if an achievement is unlocked
  static Future<bool> isUnlocked(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix${achievement.id}') ?? false;
  }

  /// Unlock an achievement
  /// Returns true if newly unlocked, false if already had it
  static Future<bool> unlock(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyUnlocked = prefs.getBool('$_prefix${achievement.id}') ?? false;

    if (!alreadyUnlocked) {
      await prefs.setBool('$_prefix${achievement.id}', true);
      await prefs.setString(
        '$_unlockedAtPrefix${achievement.id}',
        DateTime.now().toIso8601String(),
      );
      return true;
    }
    return false;
  }

  /// Get all unlocked achievements
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = <Achievement>[];

    for (final achievement in Achievement.values) {
      if (prefs.getBool('$_prefix${achievement.id}') ?? false) {
        unlocked.add(achievement);
      }
    }

    return unlocked;
  }

  /// Get count of unlocked achievements
  static Future<int> getUnlockedCount() async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.length;
  }

  /// Get total achievement count
  static int get totalCount => Achievement.values.length;

  /// Check and unlock achievements based on current state
  /// Call this after quiz completion
  static Future<List<Achievement>> checkAndUnlockAchievements({
    required int score,
    required int totalQuestions,
    required String modeId,
    int? survivalStreak,
    int? totalCorrectAnswers,
    int? perfectScoreCount,
    int? footballIQ,
    List<String>? formGuide,
    Set<String>? playedClubs,
    Set<String>? playedModes,
  }) async {
    final newlyUnlocked = <Achievement>[];
    final isPerfect = score == totalQuestions;

    // Clean Sheet - perfect score
    if (isPerfect) {
      if (await unlock(Achievement.cleanSheet)) {
        newlyUnlocked.add(Achievement.cleanSheet);
      }
    }

    // Hat Trick - 3 perfect scores
    if (perfectScoreCount != null && perfectScoreCount >= 3) {
      if (await unlock(Achievement.hatTrick)) {
        newlyUnlocked.add(Achievement.hatTrick);
      }
    }

    // Century Maker - 100 correct answers
    if (totalCorrectAnswers != null && totalCorrectAnswers >= 100) {
      if (await unlock(Achievement.centuryMaker)) {
        newlyUnlocked.add(Achievement.centuryMaker);
      }
    }

    // Double Century - 200 correct answers
    if (totalCorrectAnswers != null && totalCorrectAnswers >= 200) {
      if (await unlock(Achievement.doublecentury)) {
        newlyUnlocked.add(Achievement.doublecentury);
      }
    }

    // On Form - 3 wins in a row
    if (formGuide != null && formGuide.length >= 3) {
      if (formGuide.take(3).every((r) => r == 'W')) {
        if (await unlock(Achievement.onForm)) {
          newlyUnlocked.add(Achievement.onForm);
        }
      }
    }

    // Hot Streak - 5 wins in a row
    if (formGuide != null && formGuide.length >= 5) {
      if (formGuide.take(5).every((r) => r == 'W')) {
        if (await unlock(Achievement.hotStreak)) {
          newlyUnlocked.add(Achievement.hotStreak);
        }
      }
    }

    // Survival mode achievements
    if (survivalStreak != null) {
      if (survivalStreak >= 10) {
        if (await unlock(Achievement.survivor)) {
          newlyUnlocked.add(Achievement.survivor);
        }
      }
      if (survivalStreak >= 20) {
        if (await unlock(Achievement.endurance)) {
          newlyUnlocked.add(Achievement.endurance);
        }
      }
      if (survivalStreak >= 30) {
        if (await unlock(Achievement.ironMan)) {
          newlyUnlocked.add(Achievement.ironMan);
        }
      }
    }

    // Ground Hopper - 3 different clubs
    if (playedClubs != null && playedClubs.length >= 3) {
      if (await unlock(Achievement.groundHopper)) {
        newlyUnlocked.add(Achievement.groundHopper);
      }
    }

    // All-Rounder - all 5 modes
    if (playedModes != null && playedModes.length >= 5) {
      if (await unlock(Achievement.allRounder)) {
        newlyUnlocked.add(Achievement.allRounder);
      }
    }

    // IQ milestones
    if (footballIQ != null) {
      if (footballIQ >= 60) {
        if (await unlock(Achievement.risingTalent)) {
          newlyUnlocked.add(Achievement.risingTalent);
        }
      }
      if (footballIQ >= 70) {
        if (await unlock(Achievement.establishedPro)) {
          newlyUnlocked.add(Achievement.establishedPro);
        }
      }
      if (footballIQ >= 80) {
        if (await unlock(Achievement.eliteStatus)) {
          newlyUnlocked.add(Achievement.eliteStatus);
        }
      }
      if (footballIQ >= 90) {
        if (await unlock(Achievement.worldClass)) {
          newlyUnlocked.add(Achievement.worldClass);
        }
      }
    }

    // Time-based achievements
    final now = DateTime.now();

    // Early Kick-Off - before 9am
    if (now.hour < 9) {
      if (await unlock(Achievement.earlyKickOff)) {
        newlyUnlocked.add(Achievement.earlyKickOff);
      }
    }

    // Midweek Fixture - Wednesday
    if (now.weekday == DateTime.wednesday) {
      if (await unlock(Achievement.midweekFixture)) {
        newlyUnlocked.add(Achievement.midweekFixture);
      }
    }

    return newlyUnlocked;
  }

  /// Get achievement tier (for visual styling)
  static AchievementTier getTier(Achievement achievement) {
    switch (achievement) {
      case Achievement.worldClass:
      case Achievement.ironMan:
      case Achievement.pokerHand:
        return AchievementTier.platinum;

      case Achievement.eliteStatus:
      case Achievement.endurance:
      case Achievement.hotStreak:
      case Achievement.doublecentury:
        return AchievementTier.gold;

      case Achievement.establishedPro:
      case Achievement.survivor:
      case Achievement.onForm:
      case Achievement.centuryMaker:
      case Achievement.hatTrick:
      case Achievement.allRounder:
        return AchievementTier.silver;

      default:
        return AchievementTier.bronze;
    }
  }

  /// Get tier color
  static int getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.platinum:
        return 0xFFE5E4E2; // Platinum
      case AchievementTier.gold:
        return 0xFFD4AF37; // Gold
      case AchievementTier.silver:
        return 0xFFC0C0C0; // Silver
      case AchievementTier.bronze:
        return 0xFFCD7F32; // Bronze
    }
  }

  /// Reset all achievements (for testing)
  static Future<void> resetAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    for (final achievement in Achievement.values) {
      await prefs.remove('$_prefix${achievement.id}');
      await prefs.remove('$_unlockedAtPrefix${achievement.id}');
    }
  }
}
