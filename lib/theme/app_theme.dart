import 'package:flutter/material.dart';

/// Football IQ App Theme
/// Design principle: "Premium pub quiz" - confident, restrained, adult
class AppTheme {
  // Core Dark Theme Colors (Updated from Dribbble research)
  static const Color background = Color(0xFF2D3E50);  // Softer dark blue-grey
  static const Color surface = Color(0xFF34495E);     // Slightly lighter surface
  static const Color elevated = Color(0xFF3D5368);    // Elevated elements

  // Text Hierarchy (avoiding pure white for eye comfort)
  static const Color textPrimary = Color(0xFFECF0F1);  // Slightly warmer white
  static const Color textSecondary = Color(0xFFBDC3C7); // Better contrast
  static const Color textMuted = Color(0xFF95A5A6);     // Lighter muted

  // Accent Colors (New - Primary green from Dribbble research)
  static const Color accent = Color(0xFF4ADE80);       // Bright grass green
  static const Color accentDark = Color(0xFF16A34A);   // Darker green (selected)
  static const Color accentLight = Color(0xFF86EFAC);  // Light green (hover)

  // Feedback Colors (desaturated for dark mode)
  static const Color correct = Color(0xFF2ECC71);
  static const Color correctDark = Color(0xFF27AE60);
  static const Color incorrect = Color(0xFFE74C3C);
  static const Color incorrectDark = Color(0xFFC0392B);
  static const Color highlight = Color(0xFF3498DB);

  // Premium Accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Mode Colors (already defined, kept for reference)
  static const Color quizYourClub = Color(0xFF6C5CE7);
  static const Color plLegends = Color(0xFF00B894);
  static const Color higherOrLower = Color(0xFFE17055);
  static const Color survivalMode = Color(0xFFD63031);
  static const Color iconicMoments = Color(0xFF0984E3);

  // Typography Scale (Enhanced for Dribbble-inspired design)
  static const double fontSizeXXXL = 80.0;  // Mega scores (results screen)
  static const double fontSizeXXL = 64.0;   // Big numbers (countdown, large scores)
  static const double fontSizeXL = 48.0;    // Large headings
  static const double fontSizeLG = 32.0;    // Section headings
  static const double fontSizeMD = 24.0;    // Subheadings
  static const double fontSizeBody = 18.0;  // Body text
  static const double fontSizeSM = 16.0;    // Secondary text
  static const double fontSizeXS = 14.0;    // Captions
  static const double fontSizeXXS = 12.0;   // Labels

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 100);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Border Radius (Updated for rounder, modern look)
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Spacing System (Standardized)
  static const double spaceXXS = 4.0;
  static const double spaceXS = 8.0;
  static const double spaceS = 12.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double spaceXXXL = 64.0;

  // Shadows for elevated elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Card decoration
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? surface,
    borderRadius: BorderRadius.circular(radiusMD),
    boxShadow: elevatedShadow,
  );

  // Gradient for mode cards
  static LinearGradient modeGradient(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary green gradient for buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle background gradient
  static LinearGradient subtleGradient(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Primary button decoration with gradient
  static BoxDecoration primaryButtonDecoration({bool selected = false}) => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusLG),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Secondary button decoration (outlined)
  static BoxDecoration secondaryButtonDecoration({bool selected = false}) => BoxDecoration(
    border: Border.all(color: accent, width: 2),
    borderRadius: BorderRadius.circular(radiusLG),
    color: Colors.transparent,
  );

  // Answer button states
  static BoxDecoration answerButtonDecoration({
    required bool answered,
    required bool isCorrectAnswer,
    required bool isSelected,
  }) {
    Color bgColor;
    Border? border;

    if (!answered) {
      bgColor = Colors.white.withValues(alpha: 0.1);
      if (isSelected) {
        border = Border.all(color: accent, width: 2);
      }
    } else if (isCorrectAnswer) {
      bgColor = correct;
    } else if (isSelected) {
      bgColor = incorrect;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.1);
    }

    return BoxDecoration(
      color: bgColor,
      border: border,
      borderRadius: BorderRadius.circular(radiusLG),
    );
  }

  // Text Styles
  static const TextStyle headlineXXXL = TextStyle(
    fontSize: fontSizeXXXL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -2.0,
  );

  static const TextStyle headlineXXL = TextStyle(
    fontSize: fontSizeXXL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -1.5,
  );

  static const TextStyle headlineXL = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle headlineLG = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMD = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
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

  // Question text style - premium, readable
  static const TextStyle questionText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Mode title style
  static const TextStyle modeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  // Streak/score display
  static const TextStyle scoreDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: gold,
    letterSpacing: -1,
  );

  // Button scale animation value
  static const double buttonPressedScale = 0.95;

  // ThemeData for MaterialApp
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: highlight,
    colorScheme: const ColorScheme.dark(
      primary: highlight,
      secondary: gold,
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
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: textSecondary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );
}
