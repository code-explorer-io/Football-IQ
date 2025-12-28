import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Typography system using Google Fonts
/// Montserrat: Headlines (confident, geometric)
/// Inter: Body text (exceptional readability)
class AppTypography {
  // Headlines - Montserrat (bold, confident)
  static TextStyle get headlineXL => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeXL,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  static TextStyle get headlineLG => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeLG,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  static TextStyle get headlineMD => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeMD,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // Score display - Extra large for impact
  static TextStyle get scoreDisplay => GoogleFonts.montserrat(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  static TextStyle get streakDisplay => GoogleFonts.montserrat(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // Body text - Inter (clean, readable)
  static TextStyle get bodyLG => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeBody,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static TextStyle get bodyMD => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSM,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static TextStyle get bodySM => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXS,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  // Question text - slightly larger Inter for readability
  static TextStyle get questionText => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
    height: 1.3,
  );

  // Answer option text
  static TextStyle get answerText => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSM,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  // Button text
  static TextStyle get buttonText => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeBody,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // Verdict/badge text
  static TextStyle get verdictText => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeLG,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // Caption text
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXS,
    fontWeight: FontWeight.normal,
    color: AppTheme.textMuted,
  );

  // Muted text (for "Best: X" etc)
  static TextStyle get mutedText => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeSM,
    fontWeight: FontWeight.normal,
    color: AppTheme.textMuted,
  );

  // Category labels (Higher or Lower)
  static TextStyle get categoryLabel => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeSM,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    letterSpacing: 1,
  );

  // Stats/numbers in cards
  static TextStyle get statNumber => GoogleFonts.montserrat(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // NEW BEST badge
  static TextStyle get badgeText => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeSM,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Game over text
  static TextStyle get gameOverText => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeMD,
    fontWeight: FontWeight.bold,
    color: AppTheme.textMuted,
    letterSpacing: 4,
  );

  // Mode card title
  static TextStyle get modeTitle => GoogleFonts.montserrat(
    fontSize: AppTheme.fontSizeBody,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  // Mode card subtitle
  static TextStyle get modeSubtitle => GoogleFonts.inter(
    fontSize: AppTheme.fontSizeXS,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );
}
