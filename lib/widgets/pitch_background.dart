import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Subtle football pitch pattern background
/// Creates a premium, understated football atmosphere
class PitchBackground extends StatelessWidget {
  final Widget child;
  final bool showCenterCircle;
  final bool showHalfwayLine;
  final double opacity;

  const PitchBackground({
    super.key,
    required this.child,
    this.showCenterCircle = true,
    this.showHalfwayLine = true,
    this.opacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pitch pattern
        Positioned.fill(
          child: CustomPaint(
            painter: _PitchPatternPainter(
              lineColor: Colors.white.withValues(alpha: opacity),
              showCenterCircle: showCenterCircle,
              showHalfwayLine: showHalfwayLine,
            ),
          ),
        ),
        // Subtle gradient overlay for depth
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
