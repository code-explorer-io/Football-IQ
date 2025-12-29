import 'package:flutter/material.dart';

class GameMode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final bool requiresClubSelection;
  final String? dataFile; // For modes that don't need club selection

  GameMode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isLocked = false,
    this.requiresClubSelection = true,
    this.dataFile,
  });
}

// Available game modes
final List<GameMode> gameModes = [
  GameMode(
    id: 'quiz_your_club',
    name: 'Quiz Your Club',
    description: 'Prove your loyalty',
    icon: Icons.shield,
    color: const Color(0xFF7A263A),
    isLocked: false,
    requiresClubSelection: true,
  ),
  GameMode(
    id: 'premier_league_legends',
    name: 'Premier League Legends',
    description: 'Icons of the English game',
    icon: Icons.star,
    color: const Color(0xFF3D195B), // Premier League purple
    isLocked: false,
    requiresClubSelection: false,
    dataFile: 'assets/data/premier_league_legends.json',
  ),
  GameMode(
    id: 'higher_or_lower',
    name: 'Higher or Lower',
    description: 'The numbers game',
    icon: Icons.swap_vert,
    color: const Color(0xFF1565C0), // Blue
    isLocked: false,
    requiresClubSelection: false,
    dataFile: 'assets/data/higher_or_lower.json',
  ),
  GameMode(
    id: 'survival_mode',
    name: 'Survival Mode',
    description: 'One mistake and it\'s over',
    icon: Icons.local_fire_department,
    color: const Color(0xFFE65100), // Orange
    isLocked: false,
    requiresClubSelection: false,
    dataFile: 'assets/data/survival_mode.json',
  ),
  GameMode(
    id: 'timed_blitz',
    name: 'Timed Blitz',
    description: 'Beat the clock',
    icon: Icons.timer,
    color: const Color(0xFFD32F2F), // Red
    isLocked: false,
    requiresClubSelection: false,
    dataFile: 'assets/data/survival_mode.json', // Reuses survival questions
  ),
  GameMode(
    id: 'international_cup',
    name: 'International Cup',
    description: 'Glory awaits',
    icon: Icons.emoji_events,
    color: const Color(0xFF00695C), // Teal
    isLocked: false,
    requiresClubSelection: false,
    dataFile: 'assets/data/international_cup.json',
  ),
];
