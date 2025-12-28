import 'package:flutter/services.dart';

/// Haptic feedback service
/// Design principle: Haptics should feel meaningful, not constant
/// - Light tap for correct answers (satisfying confirmation)
/// - Medium impact for incorrect (gets attention without being annoying)
/// - Selection click for button presses
class HapticService {
  /// Light tap - use for correct answers
  static void correct() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - use for incorrect answers
  static void incorrect() {
    HapticFeedback.mediumImpact();
  }

  /// Selection click - use for button presses
  static void tap() {
    HapticFeedback.selectionClick();
  }

  /// Heavy impact - use sparingly (new high score, achievement)
  static void celebrate() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate pattern - use for major achievements only
  static void achievement() {
    HapticFeedback.vibrate();
  }
}
