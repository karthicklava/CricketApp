import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium, high-definition 3D metallic gold coin widget for TurfScore digital toss.
/// Renders crisp dual-sided graphics (HEADS & TAILS) with metallic gold gradients,
/// TurfScore green accents, inner bevels, depth shadows, and specular light reflections.
class TurfScoreCoinWidget extends StatelessWidget {
  final String side; // 'HEADS' or 'TAILS'
  final double size;
  final double rotationY; // Radians for Y-axis spin
  final double rotationX; // Radians for subtle tilt/pitch
  final double sheenProgress;

  const TurfScoreCoinWidget({
    super.key,
    required this.side,
    this.size = 180,
    this.rotationY = 0,
    this.rotationX = 0,
    this.sheenProgress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    // Determine effective face depending on rotation angle
    final cosY = math.cos(rotationY);
    final isFrontVisible = cosY >= 0;
    final displaySide = isFrontVisible
        ? side
        : (side == 'HEADS' ? 'TAILS' : 'HEADS');

    // Matrix4 3D transform with realistic perspective
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.002) // Perspective factor
      ..rotateY(rotationY)
      ..rotateX(rotationX);

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(90),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFFFD700).withAlpha(40),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _CoinPainter(
            displaySide: displaySide,
            isFlippedBack: !isFrontVisible,
            sheenProgress: sheenProgress,
          ),
        ),
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  final String displaySide;
  final bool isFlippedBack;
  final double sheenProgress;

  _CoinPainter({
    required this.displaySide,
    required this.isFlippedBack,
    required this.sheenProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // If flipped back, flip X on canvas so graphics and text stay un-mirrored
    if (isFlippedBack) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // 1. Outer metallic gold bevel rim
    final outerRimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFF8DC), // Champagne highlight
          Color(0xFFFFD700), // Gold
          Color(0xFFD4AF37), // Metallic gold
          Color(0xFFAA771C), // Deep bronze gold
          Color(0xFF5A4006), // Dark gold border
        ],
        stops: [0.0, 0.55, 0.78, 0.92, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, outerRimPaint);

    // 2. Beaded outer gold rim ring
    final beadPaint = Paint()
      ..color = const Color(0xFF78530D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 4, beadPaint);

    const int beadCount = 36;
    final beadDotPaint = Paint()..color = const Color(0xFFFFF3B0);
    for (int i = 0; i < beadCount; i++) {
      final angle = i * (2 * math.pi / beadCount);
      final bx = center.dx + (radius - 7) * math.cos(angle);
      final by = center.dy + (radius - 7) * math.sin(angle);
      canvas.drawCircle(Offset(bx, by), 1.6, beadDotPaint);
    }

    // 3. TurfScore Emerald Green Accent Ring
    final greenAccentPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF0F5132),
          Color(0xFF198754),
          Color(0xFF0F5132),
          Color(0xFF0D4329),
          Color(0xFF0F5132),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 11));
    canvas.drawCircle(center, radius - 11, greenAccentPaint);

    final greenBorderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 11, greenBorderPaint);
    canvas.drawCircle(center, radius - 20, greenBorderPaint);

    // 4. Inner Coin Face Base Gradient
    final innerRadius = radius - 20;
    final innerFacePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFF5C0),
          Color(0xFFFFD700),
          Color(0xFFC59B27),
          Color(0xFF8C620B),
        ],
        stops: [0.0, 0.45, 0.85, 1.0],
        center: Alignment(-0.2, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerFacePaint);

    // Subtle guilloche concentric rings
    final patternPaint = Paint()
      ..color = const Color(0xFFA87A14).withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (double r = innerRadius - 6; r > 10; r -= 7) {
      canvas.drawCircle(center, r, patternPaint);
    }

    // 5. Render Side Emblem & Text
    if (displaySide == 'HEADS') {
      _drawHeadsFace(canvas, center, innerRadius);
    } else {
      _drawTailsFace(canvas, center, innerRadius);
    }

    // 6. Dynamic Metallic Specular Light Reflection Beam
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.5 + sheenProgress * 2.0, -1.5),
        end: Alignment(-0.5 + sheenProgress * 2.0, 1.5),
        colors: [
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(100),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, innerRadius, sheenPaint);

    if (isFlippedBack) {
      canvas.restore();
    }
  }

  void _drawHeadsFace(Canvas canvas, Offset center, double innerRadius) {
    // Top Brand Text
    _drawArcText(
      canvas: canvas,
      text: 'TURFSCORE',
      center: center,
      radius: innerRadius - 12,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF3D2904),
      isTop: true,
    );

    // Center Gold Crown / Shield Emblem
    final emblemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5C3F05), Color(0xFF382502)],
      ).createShader(Rect.fromCircle(center: center, radius: 25));

    final path = Path();
    final cx = center.dx;
    final cy = center.dy - 12;

    // Crown / Crest Path
    path.moveTo(cx - 18, cy - 6);
    path.lineTo(cx - 24, cy - 18);
    path.lineTo(cx - 10, cy - 10);
    path.lineTo(cx, cy - 22);
    path.lineTo(cx + 10, cy - 10);
    path.lineTo(cx + 24, cy - 18);
    path.lineTo(cx + 18, cy - 6);
    path.lineTo(cx + 16, cy + 6);
    path.lineTo(cx - 16, cy + 6);
    path.close();

    canvas.drawPath(path, emblemPaint);

    // Star Jewels on Crown
    final starPaint = Paint()..color = const Color(0xFFFFF5C0);
    canvas.drawCircle(Offset(cx - 24, cy - 18), 2.2, starPaint);
    canvas.drawCircle(Offset(cx, cy - 22), 2.8, starPaint);
    canvas.drawCircle(Offset(cx + 24, cy - 18), 2.2, starPaint);

    // Center Star below crown
    _drawStar(canvas, Offset(cx, cy - 2), 6, const Color(0xFF0F5132));

    // Bold HEADS Title Text
    _drawText(
      canvas: canvas,
      text: 'HEADS',
      center: Offset(center.dx, center.dy + 20),
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2E1C02),
      letterSpacing: 2.0,
      shadowColor: const Color(0xFFFFF3B0),
    );

    // Bottom Subtitle Text
    _drawArcText(
      canvas: canvas,
      text: 'CRICKET TOSS',
      center: center,
      radius: innerRadius - 12,
      fontSize: 8.5,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF4A3105),
      isTop: false,
    );
  }

  void _drawTailsFace(Canvas canvas, Offset center, double innerRadius) {
    // Top Brand Text
    _drawArcText(
      canvas: canvas,
      text: 'TURFSCORE',
      center: center,
      radius: innerRadius - 12,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF3D2904),
      isTop: true,
    );

    // Center Crossed Cricket Bats and Ball Graphic
    final cy = center.dy - 12;
    final batPaint = Paint()
      ..color = const Color(0xFF4A3105)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;

    // Bat 1 (top-left to bottom-right)
    canvas.drawLine(
      Offset(center.dx - 18, cy - 16),
      Offset(center.dx + 18, cy + 12),
      batPaint,
    );
    // Bat 2 (top-right to bottom-left)
    canvas.drawLine(
      Offset(center.dx + 18, cy - 16),
      Offset(center.dx - 18, cy + 12),
      batPaint,
    );

    // Cricket Ball in middle of crossed bats
    final ballPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE63946), Color(0xFF990000)],
      ).createShader(Rect.fromCircle(center: Offset(center.dx, cy - 2), radius: 8));
    canvas.drawCircle(Offset(center.dx, cy - 2), 8, ballPaint);

    final ballSeamPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, cy - 2), radius: 6),
      -math.pi / 3,
      2 * math.pi / 3,
      false,
      ballSeamPaint,
    );

    // Bold TAILS Title Text
    _drawText(
      canvas: canvas,
      text: 'TAILS',
      center: Offset(center.dx, center.dy + 20),
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2E1C02),
      letterSpacing: 2.0,
      shadowColor: const Color(0xFFFFF3B0),
    );

    // Bottom Subtitle Text
    _drawArcText(
      canvas: canvas,
      text: 'MATCH OFFICIAL',
      center: center,
      radius: innerRadius - 12,
      fontSize: 8.5,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF4A3105),
      isTop: false,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * (2 * math.pi / 5);
      final innerAngle = outerAngle + math.pi / 5;
      final ox = center.dx + radius * math.cos(outerAngle);
      final oy = center.dy + radius * math.sin(outerAngle);
      final ix = center.dx + (radius * 0.45) * math.cos(innerAngle);
      final iy = center.dy + (radius * 0.45) * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
    Color? shadowColor,
  }) {
    if (shadowColor != null) {
      final shadowPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: shadowColor,
            letterSpacing: letterSpacing,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shadowPainter.layout();
      shadowPainter.paint(
        canvas,
        Offset(center.dx - shadowPainter.width / 2, center.dy - shadowPainter.height / 2 + 1),
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  void _drawArcText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double radius,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required bool isTop,
  }) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 1.5,
    );

    final charAngle = fontSize * 0.08;
    final totalAngle = text.length * charAngle;
    final startAngle = isTop
        ? -math.pi / 2 - totalAngle / 2 + charAngle / 2
        : math.pi / 2 - totalAngle / 2 + charAngle / 2;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final angle = startAngle + i * charAngle;
      final cx = center.dx + radius * math.cos(angle);
      final cy = center.dy + radius * math.sin(angle);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle + (isTop ? math.pi / 2 : -math.pi / 2));

      final tp = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CoinPainter oldDelegate) {
    return oldDelegate.displaySide != displaySide ||
        oldDelegate.isFlippedBack != isFlippedBack ||
        oldDelegate.sheenProgress != sheenProgress;
  }
}
