import 'package:flutter/material.dart';

class Club {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String dataFile;
  final bool isLocked;

  Club({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.dataFile,
    this.isLocked = false,
  });
}

// Predefined clubs
final List<Club> clubs = [
  Club(
    id: 'west_ham',
    name: 'West Ham United',
    primaryColor: const Color(0xFF7A263A), // Claret
    secondaryColor: const Color(0xFF1BB1E7), // Blue
    dataFile: 'assets/data/west_ham.json',
    isLocked: false,
  ),
  Club(
    id: 'manchester_city',
    name: 'Manchester City',
    primaryColor: const Color(0xFF6CABDD), // Sky blue
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/manchester_city.json',
    isLocked: false, // Unlocked for testing
  ),
  Club(
    id: 'arsenal',
    name: 'Arsenal',
    primaryColor: const Color(0xFFEF0107), // Red
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/arsenal.json',
    isLocked: false, // Unlocked for testing
  ),
];
