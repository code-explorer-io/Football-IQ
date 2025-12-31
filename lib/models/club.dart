import 'package:flutter/material.dart';
import '../services/purchase_service.dart';

class Club {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String dataFile;
  final bool isFree; // True if club is free, false if requires premium

  Club({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.dataFile,
    this.isFree = false,
  });

  /// Check if this club is locked (requires premium but user doesn't have it)
  bool get isLocked => !isFree && !PurchaseService.isPremium;
}

// Predefined clubs - 10 Premier League teams
final List<Club> clubs = [
  // Free club
  Club(
    id: 'west_ham',
    name: 'West Ham United',
    primaryColor: const Color(0xFF7A263A), // Claret
    secondaryColor: const Color(0xFF1BB1E7), // Blue
    dataFile: 'assets/data/west_ham.json',
    isFree: true, // West Ham is the free club
  ),
  // Big Six
  Club(
    id: 'manchester_city',
    name: 'Manchester City',
    primaryColor: const Color(0xFF6CABDD), // Sky blue
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/manchester_city.json',
  ),
  Club(
    id: 'arsenal',
    name: 'Arsenal',
    primaryColor: const Color(0xFFEF0107), // Red
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/arsenal.json',
  ),
  Club(
    id: 'liverpool',
    name: 'Liverpool',
    primaryColor: const Color(0xFFC8102E), // Red
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/liverpool.json',
  ),
  Club(
    id: 'manchester_united',
    name: 'Manchester United',
    primaryColor: const Color(0xFFDA291C), // Red
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/manchester_united.json',
  ),
  Club(
    id: 'chelsea',
    name: 'Chelsea',
    primaryColor: const Color(0xFF034694), // Blue
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/chelsea.json',
  ),
  Club(
    id: 'tottenham',
    name: 'Tottenham Hotspur',
    primaryColor: const Color(0xFF132257), // Navy
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/tottenham.json',
  ),
  // Fan favorites
  Club(
    id: 'newcastle',
    name: 'Newcastle United',
    primaryColor: const Color(0xFF241F20), // Black
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/newcastle.json',
  ),
  Club(
    id: 'aston_villa',
    name: 'Aston Villa',
    primaryColor: const Color(0xFF670E36), // Claret
    secondaryColor: const Color(0xFF95BFE5), // Sky blue
    dataFile: 'assets/data/aston_villa.json',
  ),
  Club(
    id: 'everton',
    name: 'Everton',
    primaryColor: const Color(0xFF003399), // Royal blue
    secondaryColor: const Color(0xFFFFFFFF), // White
    dataFile: 'assets/data/everton.json',
  ),
];
