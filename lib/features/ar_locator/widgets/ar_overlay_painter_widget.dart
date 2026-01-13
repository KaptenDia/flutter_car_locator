import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArOverlayPainterWidget extends CustomPainter {
  final double distance;
  final double bearing;
  final double heading;
  final String distanceText;
  final double pulseAnimation;
  final double rotationAnimation;

  ArOverlayPainterWidget({
    required this.distance,
    required this.bearing,
    required this.heading,
    required this.distanceText,
    required this.pulseAnimation,
    required this.rotationAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw compass background
    final compassPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 80, compassPaint);

    // Draw bearing indicator
    // Subtract heading to make it relative to device orientation
    final relativeBearing = (bearing - heading) * math.pi / 180;
    final arrowEnd = Offset(
      center.dx + 60 * math.sin(relativeBearing),
      center.dy - 60 * math.cos(relativeBearing),
    );

    final arrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Draw car icon at the end of arrow
    final carIconPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(arrowEnd, 8 * pulseAnimation, carIconPaint);

    // Draw distance text
    final textPainter = TextPainter(
      text: TextSpan(
        text: distanceText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 100),
    );
  }

  @override
  bool shouldRepaint(ArOverlayPainterWidget oldDelegate) {
    return oldDelegate.distance != distance ||
        oldDelegate.bearing != bearing ||
        oldDelegate.heading != heading ||
        oldDelegate.distanceText != distanceText ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.rotationAnimation != rotationAnimation;
  }
}
