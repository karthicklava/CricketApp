import 'package:flutter/material.dart';
import '../../profile/profile_state.dart';

class CricketBadgeWidget extends StatelessWidget {
  final String jerseyNumber;
  final CricketIconStyle style;
  final Color primaryColor;
  final double size;

  const CricketBadgeWidget({
    super.key,
    required this.jerseyNumber,
    this.style = CricketIconStyle.shield,
    this.primaryColor = const Color(0xFF0D6EFD),
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BadgePainter(
          jerseyNumber: jerseyNumber,
          style: style,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  final String jerseyNumber;
  final CricketIconStyle style;
  final Color primaryColor;

  _BadgePainter({
    required this.jerseyNumber,
    required this.style,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    final bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.04;

    final accentPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    switch (style) {
      case CricketIconStyle.shield:
        _drawShield(canvas, size, bgPaint, borderPaint, accentPaint);
        break;
      case CricketIconStyle.jersey:
        _drawJersey(canvas, size, bgPaint, borderPaint);
        break;
      case CricketIconStyle.ball:
        _drawBall(canvas, size, bgPaint, borderPaint);
        break;
      case CricketIconStyle.wickets:
        _drawWickets(canvas, size, bgPaint, borderPaint);
        break;
      case CricketIconStyle.captain:
        _drawCaptain(canvas, size, bgPaint, borderPaint, accentPaint);
        break;
    }

    // Paint Text (Jersey Number)
    _drawText(canvas, center, width);
  }

  void _drawShield(Canvas canvas, Size size, Paint bgPaint, Paint borderPaint,
      Paint accentPaint) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.1, h * 0.1)
      ..lineTo(w * 0.9, h * 0.1)
      ..lineTo(w * 0.9, h * 0.5)
      ..cubicTo(w * 0.9, h * 0.85, w * 0.5, h * 0.98, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.5, h * 0.98, w * 0.1, h * 0.85, w * 0.1, h * 0.5)
      ..close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);

    // Ball accent at bottom
    canvas.drawCircle(Offset(w * 0.5, h * 0.78), w * 0.08, accentPaint);
  }

  void _drawJersey(Canvas canvas, Size size, Paint bgPaint, Paint borderPaint) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.3, h * 0.15)
      ..lineTo(w * 0.1, h * 0.3)
      ..lineTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.3, h * 0.35)
      ..lineTo(w * 0.3, h * 0.9)
      ..lineTo(w * 0.7, h * 0.9)
      ..lineTo(w * 0.7, h * 0.35)
      ..lineTo(w * 0.78, h * 0.42)
      ..lineTo(w * 0.9, h * 0.3)
      ..lineTo(w * 0.7, h * 0.15)
      ..quadraticBezierTo(w * 0.5, h * 0.25, w * 0.3, h * 0.15)
      ..close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawBall(Canvas canvas, Size size, Paint bgPaint, Paint borderPaint) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.drawCircle(center, radius * 0.92, bgPaint);
    canvas.drawCircle(center, radius * 0.92, borderPaint);

    // Seam line arc
    final seamPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;

    final seamPath = Path()
      ..addArc(
          Rect.fromCircle(center: center, radius: radius * 0.8), -0.5, 3.14);
    canvas.drawPath(seamPath, seamPaint);
  }

  void _drawWickets(
      Canvas canvas, Size size, Paint bgPaint, Paint borderPaint) {
    final w = size.width;
    final h = size.height;

    // Background Container
    final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
        Radius.circular(w * 0.2));
    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    final wicketPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;

    // 3 Stumps
    canvas.drawLine(
        Offset(w * 0.3, h * 0.2), Offset(w * 0.3, h * 0.8), wicketPaint);
    canvas.drawLine(
        Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.8), wicketPaint);
    canvas.drawLine(
        Offset(w * 0.7, h * 0.2), Offset(w * 0.7, h * 0.8), wicketPaint);

    // Bails
    canvas.drawLine(
        Offset(w * 0.25, h * 0.2), Offset(w * 0.75, h * 0.2), wicketPaint);
  }

  void _drawCaptain(Canvas canvas, Size size, Paint bgPaint, Paint borderPaint,
      Paint accentPaint) {
    _drawShield(canvas, size, bgPaint, borderPaint, accentPaint);

    final w = size.width;
    final h = size.height;

    // Captain Star / Crown at top
    final starPath = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.54, h * 0.12)
      ..lineTo(w * 0.63, h * 0.12)
      ..lineTo(w * 0.56, h * 0.17)
      ..lineTo(w * 0.58, h * 0.25)
      ..lineTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.42, h * 0.25)
      ..lineTo(w * 0.44, h * 0.17)
      ..lineTo(w * 0.37, h * 0.12)
      ..lineTo(w * 0.46, h * 0.12)
      ..close();

    canvas.drawPath(starPath, Paint()..color = Colors.amber.shade700);
  }

  void _drawText(Canvas canvas, Offset center, double size) {
    final fontSize = size * 0.4;

    // Ensure contrast: if primary is light gold, use dark text; else white
    final isLightPrimary = primaryColor.computeLuminance() > 0.6;
    final textColor = isLightPrimary ? Colors.black87 : Colors.white;

    final textPainter = TextPainter(
      text: TextSpan(
        text: jerseyNumber.isEmpty ? 'CR' : jerseyNumber,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2) - (size * 0.04),
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _BadgePainter oldDelegate) {
    return oldDelegate.jerseyNumber != jerseyNumber ||
        oldDelegate.style != style ||
        oldDelegate.primaryColor != primaryColor;
  }
}
