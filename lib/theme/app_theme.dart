import 'package:flutter/material.dart';

/// Football IQ App Theme
/// Design: Modern sports app with green gradient accents
class AppTheme {
  // ============ CORE COLORS ============
  // Dark background with green accents (like the Dribbble inspiration)
  static const Color background = Color(0xFF0D1117); // Deep dark
  static const Color surface = Color(0xFF161B22); // Card background
  static const Color surfaceLight = Color(0xFF21262D); // Elevated cards

  // Primary Green Gradient Colors
  static const Color primaryGreen = Color(0xFF22C55E); // Vibrant green
  static const Color primaryGreenLight = Color(0xFF4ADE80); // Lighter green
  static const Color primaryGreenDark = Color(0xFF16A34A); // Darker green
  static const Color accentTeal = Color(0xFF14B8A6); // Teal accent
  static const Color accentLime = Color(0xFF84CC16); // Lime accent

  // The main gradient used throughout the app
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primaryGreen, accentTeal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC); // Almost white
  static const Color textSecondary = Color(0xFF8B949E); // Muted gray
  static const Color textMuted = Color(0xFF6E7681); // More muted
  static const Color textOnGreen = Color(0xFF052E16); // Dark text on green buttons

  // Feedback Colors
  static const Color correct = Color(0xFF22C55E); // Green (matches primary)
  static const Color correctDark = Color(0xFF16A34A);
  static const Color incorrect = Color(0xFFEF4444); // Red
  static const Color incorrectDark = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color highlight = Color(0xFF3B82F6); // Blue

  // Premium Accents
  static const Color gold = Color(0xFFFBBF24);
  static const Color silver = Color(0xFF9CA3AF);
  static const Color bronze = Color(0xFFF97316);

  // Glassmorphism
  static Color get glassWhite => Colors.white.withValues(alpha: 0.1);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.2);

  // ============ TYPOGRAPHY ============
  static const double fontSizeXL = 32.0;
  static const double fontSizeLG = 24.0;
  static const double fontSizeMD = 20.0;
  static const double fontSizeBody = 18.0;
  static const double fontSizeSM = 16.0;
  static const double fontSizeXS = 14.0;
  static const double fontSizeXXS = 12.0;

  // ============ SPACING & RADIUS ============
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusPill = 100.0; // For pill-shaped buttons

  // ============ ANIMATIONS ============
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ============ SHADOWS ============
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ============ DECORATIONS ============

  /// Glass card decoration (semi-transparent with blur effect)
  static BoxDecoration get glassCard => BoxDecoration(
    color: glassWhite,
    borderRadius: BorderRadius.circular(radiusLG),
    border: Border.all(color: glassBorder),
  );

  /// Solid surface card
  static BoxDecoration get surfaceCard => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLG),
    border: Border.all(color: glassBorder),
  );

  /// Primary gradient button decoration
  static BoxDecoration get gradientButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusPill),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withValues(alpha: 0.4),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Secondary/outline button decoration
  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(radiusPill),
    border: Border.all(color: glassBorder, width: 1.5),
  );

  /// Mode card gradient (for game mode selection)
  static BoxDecoration modeCardDecoration(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radiusXL),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Answer button decoration (for quiz answers)
  static BoxDecoration answerButtonDecoration({
    required bool answered,
    required bool isCorrectAnswer,
    required bool isSelected,
  }) {
    if (!answered) {
      return BoxDecoration(
        color: glassWhite,
        borderRadius: BorderRadius.circular(radiusLG),
        border: Border.all(color: glassBorder),
      );
    } else if (isCorrectAnswer) {
      return BoxDecoration(
        color: correct,
        borderRadius: BorderRadius.circular(radiusLG),
        boxShadow: [
          BoxShadow(
            color: correct.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      );
    } else if (isSelected) {
      return BoxDecoration(
        color: incorrect,
        borderRadius: BorderRadius.circular(radiusLG),
        boxShadow: [
          BoxShadow(
            color: incorrect.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      );
    } else {
      return BoxDecoration(
        color: glassWhite,
        borderRadius: BorderRadius.circular(radiusLG),
        border: Border.all(color: glassBorder),
      );
    }
  }

  // ============ TEXT STYLES ============
  static const TextStyle headlineXL = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineLG = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMD = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLG = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySM = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: FontWeight.normal,
    color: textMuted,
  );

  static const TextStyle questionText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.w600,
    color: textOnGreen,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonTextLight = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle scoreDisplay = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -2,
  );

  // ============ BUTTON HELPERS ============
  static const double buttonPressedScale = 0.96;

  // ============ THEME DATA ============
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primaryGreen,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentTeal,
      surface: surface,
      error: incorrect,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: fontSizeBody,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textOnGreen,
        backgroundColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
      ),
    ),
  );

  // ============ LEGACY COMPATIBILITY ============
  // These are kept for backward compatibility with existing code
  static const Color elevated = surfaceLight;
  static const Color quizYourClub = primaryGreen;
  static const Color plLegends = accentTeal;
  static const Color higherOrLower = Color(0xFF3B82F6); // Blue
  static const Color survivalMode = Color(0xFFEF4444); // Red
  static const Color iconicMoments = Color(0xFF8B5CF6); // Purple

  static LinearGradient modeGradient(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? surface,
    borderRadius: BorderRadius.circular(radiusLG),
    border: Border.all(color: glassBorder),
  );

  static List<BoxShadow> get elevatedShadow => softShadow;

  static const TextStyle modeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
}
