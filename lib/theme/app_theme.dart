import 'package:flutter/material.dart';

/// Football IQ App Theme
/// Design principle: "Premium pub quiz" - confident, restrained, adult
class AppTheme {
  // Core Dark Theme Colors
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color elevated = Color(0xFF0F3460);

  // Text Hierarchy (avoiding pure white for eye comfort)
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textMuted = Color(0xFF6B6B6B);

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

  // Typography Scale
  static const double fontSizeXL = 32.0;   // Score reveals
  static const double fontSizeLG = 24.0;   // Screen titles, verdicts
  static const double fontSizeMD = 20.0;   // Question text
  static const double fontSizeBody = 18.0; // Answer options
  static const double fontSizeSM = 16.0;   // Secondary text
  static const double fontSizeXS = 14.0;   // Captions
  static const double fontSizeXXS = 12.0;  // Labels

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 100);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Shadows for elevated elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
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
    colors: [color, color.withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Answer button states
  static BoxDecoration answerButtonDecoration({
    required bool answered,
    required bool isCorrectAnswer,
    required bool isSelected,
  }) {
    Color bgColor;

    if (!answered) {
      bgColor = Colors.white.withOpacity(0.1);
    } else if (isCorrectAnswer) {
      bgColor = correct;
    } else if (isSelected) {
      bgColor = incorrect;
    } else {
      bgColor = Colors.white.withOpacity(0.1);
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radiusMD),
    );
  }

  // Text Styles
  static const TextStyle headlineXL = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headlineLG = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.bold,
    color: textPrimary,
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
        side: BorderSide(color: textSecondary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );
}
