import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Stadium background types (legacy - kept for backward compatibility)
enum StadiumBackground {
  night,   // Default night stadium
  day,     // Daytime stadium (future)
  classic, // Original pitch pattern (no image)
}

/// Background zones for visual storytelling
/// Each zone represents a distinct emotional state in the user journey
enum BackgroundZone {
  /// Hub/Home zone - Stadium wide shot (calm, possibilities)
  /// Screens: Home, Stats, Mode Selection, Club Selection
  stadium,

  /// Entry/Anticipation zone - Walking toward something
  /// Screens: All Intro Screens, Splash Screen
  tunnel,

  /// Active Play zone - Intimate, focused, tactical decisions
  /// Screens: ALL gameplay/question screens
  dugout,

  /// Reflection zone - Game over, back to earth, assessment
  /// Screens: All Results Screens
  results,

  /// Death/Failure zone (Survival Only) - Pure black, no comfort
  /// This is CODE, not an image - abrupt, final
  void_,
}

/// Subtle football pitch pattern background
/// Creates a premium, understated football atmosphere
class PitchBackground extends StatelessWidget {
  final Widget child;
  final bool showCenterCircle;
  final bool showHalfwayLine;
  final double opacity;
  final StadiumBackground background;
  final bool useStadiumImage;
  final BackgroundZone? zone;

  const PitchBackground({
    super.key,
    required this.child,
    this.showCenterCircle = true,
    this.showHalfwayLine = true,
    this.opacity = 0.03,
    this.background = StadiumBackground.night,
    this.useStadiumImage = true,
    this.zone,
  });

  /// Named constructor for zone-based backgrounds (preferred)
  const PitchBackground.zone({
    super.key,
    required this.child,
    required BackgroundZone this.zone,
    this.showCenterCircle = true,
    this.showHalfwayLine = true,
    this.opacity = 0.03,
  })  : background = StadiumBackground.night,
        useStadiumImage = true;

  /// Get overlay opacity based on zone
  double get _overlayOpacity {
    if (zone == null) return 0.4; // Default
    switch (zone!) {
      case BackgroundZone.stadium:
        return 0.3; // Light (30% dark)
      case BackgroundZone.tunnel:
        return 0.4; // Medium (40% dark)
      case BackgroundZone.dugout:
        return 0.5; // Medium-heavy (50% dark) for text readability
      case BackgroundZone.results:
        return 0.3; // Light (30% dark)
      case BackgroundZone.void_:
        return 1.0; // Pure black
    }
  }

  String? get _backgroundImage {
    // Zone-based system takes priority
    if (zone != null) {
      switch (zone!) {
        case BackgroundZone.stadium:
          return 'assets/images/stadium_night.png';
        case BackgroundZone.tunnel:
          // Falls back to stadium_night until tunnel.png is added
          return 'assets/images/tunnel.png';
        case BackgroundZone.dugout:
          // Falls back to stadium_night until dugout.png is added
          return 'assets/images/dugout.png';
        case BackgroundZone.results:
          // Uses stadium_night (or pitch_empty for survival - handled by caller)
          return 'assets/images/stadium_night.png';
        case BackgroundZone.void_:
          return null; // Pure black, no image
      }
    }

    // Legacy system
    if (!useStadiumImage) return null;
    switch (background) {
      case StadiumBackground.night:
        return 'assets/images/stadium_night.png';
      case StadiumBackground.day:
        return 'assets/images/stadium_day.png'; // Future
      case StadiumBackground.classic:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _backgroundImage;
    final overlayAlpha = _overlayOpacity;

    // Special case: void zone is pure black
    if (zone == BackgroundZone.void_) {
      return Container(
        color: Colors.black,
        child: child,
      );
    }

    return Stack(
      children: [
        // Stadium image background (if available)
        if (imagePath != null)
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to stadium_night if specific zone image not found
                return Image.asset(
                  'assets/images/stadium_night.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                );
              },
            ),
          ),
        // Dark overlay to ensure text readability (uses zone-based opacity)
        if (imagePath != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: overlayAlpha - 0.1),
                    Colors.black.withValues(alpha: overlayAlpha + 0.1),
                    Colors.black.withValues(alpha: overlayAlpha - 0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        // Pitch pattern (shown if no image or as subtle overlay)
        if (imagePath == null)
          Positioned.fill(
            child: CustomPaint(
              painter: _PitchPatternPainter(
                lineColor: Colors.white.withValues(alpha: opacity),
                showCenterCircle: showCenterCircle,
                showHalfwayLine: showHalfwayLine,
              ),
            ),
          ),
        // Subtle gradient overlay for depth (classic mode only)
        if (imagePath == null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    AppTheme.background.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        // Content
        child,
      ],
    );
  }
}

class _PitchPatternPainter extends CustomPainter {
  final Color lineColor;
  final bool showCenterCircle;
  final bool showHalfwayLine;

  _PitchPatternPainter({
    required this.lineColor,
    required this.showCenterCircle,
    required this.showHalfwayLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Halfway line
    if (showHalfwayLine) {
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        paint,
      );
    }

    // Center circle
    if (showCenterCircle) {
      final circleRadius = size.width * 0.2;
      canvas.drawCircle(
        Offset(centerX, centerY),
        circleRadius,
        paint,
      );

      // Center spot
      final spotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(centerX, centerY),
        4,
        spotPaint,
      );
    }

    // Outer boundary (subtle)
    final boundaryRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.05,
        size.width * 0.9,
        size.height * 0.9,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(boundaryRect, paint..strokeWidth = 1.0);

    // Corner arcs (subtle touch)
    final cornerRadius = size.width * 0.03;
    _drawCornerArc(canvas, paint, size.width * 0.05, size.height * 0.05, cornerRadius, 0);
    _drawCornerArc(canvas, paint, size.width * 0.95, size.height * 0.05, cornerRadius, 1);
    _drawCornerArc(canvas, paint, size.width * 0.95, size.height * 0.95, cornerRadius, 2);
    _drawCornerArc(canvas, paint, size.width * 0.05, size.height * 0.95, cornerRadius, 3);
  }

  void _drawCornerArc(Canvas canvas, Paint paint, double x, double y, double radius, int corner) {
    final startAngle = corner * 1.5708; // 90 degrees in radians
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius),
      startAngle,
      1.5708,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Alternative: Simple pitch lines without full boundary
class SimplePitchLines extends StatelessWidget {
  final Widget child;
  final double opacity;

  const SimplePitchLines({
    super.key,
    required this.child,
    this.opacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SimplePitchPainter(
              lineColor: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _SimplePitchPainter extends CustomPainter {
  final Color lineColor;

  _SimplePitchPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Just center circle and halfway line for minimal look
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    final circleRadius = size.width * 0.25;
    canvas.drawCircle(
      Offset(centerX, centerY),
      circleRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
