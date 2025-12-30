import 'package:flutter/material.dart';

/// Represents a game mode in the app
class GameMode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool requiresClubSelection;
  final String? dataFile;
  final int unlockOrder; // Order in the unlock progression (0 = always unlocked)
  final bool isPremiumOnly; // True if this mode is ONLY available to premium users (not in unlock chain)

  GameMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.requiresClubSelection = true,
    this.dataFile,
    this.unlockOrder = 0,
    this.isPremiumOnly = false,
  });
}

/// All available game modes in unlock order
final List<GameMode> gameModes = [
  GameMode(
    id: 'quiz_your_club',
    name: 'Quiz Your Club',
    description: 'Prove your loyalty',
    icon: Icons.shield,
    color: const Color(0xFF7A263A), // Claret
    requiresClubSelection: true,
    unlockOrder: 0, // Always unlocked - starting mode
  ),
  GameMode(
    id: 'survival_mode',
    name: 'Survival Mode',
    description: 'One wrong answer ends it all',
    icon: Icons.local_fire_department,
    color: const Color(0xFFE65100), // Orange
    requiresClubSelection: false,
    dataFile: 'assets/data/survival_mode.json',
    unlockOrder: 1, // Unlock after 5 Club Quizzes
  ),
  GameMode(
    id: 'timed_blitz',
    name: 'Timed Blitz',
    description: 'Beat the clock',
    icon: Icons.timer,
    color: const Color(0xFFD32F2F), // Red
    requiresClubSelection: false,
    dataFile: 'assets/data/survival_mode.json',
    unlockOrder: 2, // Unlock after 10+ streak in Survival
  ),
  GameMode(
    id: 'higher_or_lower',
    name: 'Higher or Lower',
    description: 'The numbers game',
    icon: Icons.swap_vert,
    color: const Color(0xFF1565C0), // Blue
    requiresClubSelection: false,
    dataFile: 'assets/data/higher_or_lower.json',
    unlockOrder: 3, // Unlock after scoring 15+ in Timed Blitz
  ),
  GameMode(
    id: 'international_cup',
    name: 'International Cup',
    description: 'Glory awaits',
    icon: Icons.emoji_events,
    color: const Color(0xFF00695C), // Teal
    requiresClubSelection: false,
    dataFile: 'assets/data/international_cup.json',
    unlockOrder: 4, // Unlock after 3 Higher or Lower wins
  ),
  GameMode(
    id: 'premier_league_legends',
    name: 'Premier League Legends',
    description: 'Icons of the English game',
    icon: Icons.star,
    color: const Color(0xFF3D195B), // Premier League purple
    requiresClubSelection: false,
    dataFile: 'assets/data/premier_league_legends.json',
    isPremiumOnly: true, // Premium exclusive - not in unlock chain
  ),
];

/// Get a game mode by ID
GameMode? getGameModeById(String id) {
  try {
    return gameModes.firstWhere((mode) => mode.id == id);
  } catch (e) {
    return null;
  }
}
