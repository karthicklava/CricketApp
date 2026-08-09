import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../common/widgets/brand_logo.dart';

class TurfScoreStartupGate extends StatefulWidget {
  const TurfScoreStartupGate({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 2200),
    this.reducedMotionDuration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Duration animationDuration;
  final Duration reducedMotionDuration;

  @override
  State<TurfScoreStartupGate> createState() => _TurfScoreStartupGateState();
}

class _TurfScoreStartupGateState extends State<TurfScoreStartupGate> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showSplash)
            Positioned.fill(
              child: TurfScoreSplashScreen(
                animationDuration: widget.animationDuration,
                reducedMotionDuration: widget.reducedMotionDuration,
                onFinished: () {
                  if (mounted) setState(() => _showSplash = false);
                },
              ),
            ),
        ],
      );
}

class TurfScoreSplashScreen extends StatefulWidget {
  const TurfScoreSplashScreen({
    super.key,
    required this.onFinished,
    this.animationDuration = const Duration(milliseconds: 2200),
    this.reducedMotionDuration = const Duration(milliseconds: 420),
  });

  final VoidCallback onFinished;
  final Duration animationDuration;
  final Duration reducedMotionDuration;

  @override
  State<TurfScoreSplashScreen> createState() => _TurfScoreSplashScreenState();
}

class _TurfScoreSplashScreenState extends State<TurfScoreSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  bool _finished = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _controller.duration =
        _reduceMotion ? widget.reducedMotionDuration : widget.animationDuration;
    _controller.forward().whenComplete(_finishOnce);
  }

  void _finishOnce() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _phase(double begin, double end,
          [Curve curve = Curves.easeOut]) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 360 || size.height < 620;
    final logoSize = (size.shortestSide * .34).clamp(112.0, 172.0);
    final background = _reduceMotion ? _phase(0, .35) : _phase(0, .18);
    final logo = _reduceMotion ? _phase(.08, .55) : _phase(.36, .64);
    final title = _reduceMotion ? _phase(.3, .72) : _phase(.54, .79);
    final tagline = _reduceMotion ? _phase(.5, .85) : _phase(.7, .91);
    final exit = Tween<double>(begin: 1, end: 0).animate(
      _phase(_reduceMotion ? .88 : .92, 1, Curves.easeIn),
    );

    return PopScope(
      canPop: false,
      child: Material(
        color: const Color(0xFF031F18),
        child: FadeTransition(
          opacity: exit,
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeTransition(
                  opacity: background,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF021A14),
                          Color(0xFF063D2D),
                          Color(0xFF052E23),
                        ],
                        stops: [0, .58, 1],
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _StadiumPainter(
                      reveal: _reduceMotion
                          ? background.value
                          : _phase(.02, .28).value,
                      lightStrength: _reduceMotion
                          ? background.value * .65
                          : _phase(.08, .34).value,
                    ),
                  ),
                ),
                if (!_reduceMotion)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final progress = _phase(
                        .18,
                        .47,
                        Curves.easeInOutCubic,
                      ).value;
                      final point = _quadraticPoint(
                        progress,
                        Offset(size.width * .91, size.height * .17),
                        Offset(size.width * .68, size.height * .29),
                        Offset(size.width * .54, size.height * .42),
                      );
                      return Stack(children: [
                        for (var index = 3; index >= 1; index--)
                          Positioned(
                            left: point.dx + index * 10 - 9,
                            top: point.dy - index * 7 - 9,
                            child: Opacity(
                              opacity: (.18 - index * .035) * progress,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          key: const ValueKey('splash-cricket-ball'),
                          left: point.dx - 12,
                          top: point.dy - 12,
                          child: Transform.rotate(
                            angle: progress * math.pi * 4,
                            child: const CustomPaint(
                              size: Size.square(24),
                              painter: _CricketBallPainter(),
                            ),
                          ),
                        ),
                      ]);
                    },
                  ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 22 : 32,
                      vertical: compact ? 18 : 26,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        ScaleTransition(
                          scale: Tween<double>(begin: .85, end: 1).animate(
                            CurvedAnimation(
                              parent: logo,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: logo,
                            child: AnimatedBuilder(
                              animation: logo,
                              builder: (context, child) => Container(
                                key: const ValueKey('splash-logo-glow'),
                                padding: EdgeInsets.all(compact ? 10 : 14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(
                                        alpha: .12 * logo.value,
                                      ),
                                      blurRadius: 34,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: AppColors.primaryLight.withValues(
                                        alpha: .2 * logo.value,
                                      ),
                                      blurRadius: 50,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: child,
                              ),
                              child: BrandLogo(size: logoSize),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 16),
                        FadeTransition(
                          opacity: title,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, .18),
                              end: Offset.zero,
                            ).animate(title),
                            child: Text(
                              'TurfScore',
                              key: const ValueKey('splash-app-name'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 34 : 42,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.8,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x66000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: tagline,
                          child: const Text(
                            'EVERY MATCH. EVERY MOMENT.',
                            key: ValueKey('splash-tagline'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        FadeTransition(
                          opacity: tagline,
                          child: RotationTransition(
                            turns: Tween<double>(begin: 0, end: 1.5).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: const Icon(
                              Icons.sports_baseball_rounded,
                              key: ValueKey('splash-loading-indicator'),
                              size: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Offset _quadraticPoint(
  double progress,
  Offset start,
  Offset control,
  Offset end,
) {
  final inverse = 1 - progress;
  return start * (inverse * inverse) +
      control * (2 * inverse * progress) +
      end * (progress * progress);
}

class _StadiumPainter extends CustomPainter {
  const _StadiumPainter({required this.reveal, required this.lightStrength});

  final double reveal;
  final double lightStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final standPaint = Paint()
      ..color = const Color(0xFF011A13).withValues(alpha: .8 * reveal)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * .68),
        width: size.width * 1.35,
        height: size.height * .34,
      ),
      standPaint,
    );

    _drawFloodlight(canvas, size, true);
    _drawFloodlight(canvas, size, false);

    final fieldRect = Rect.fromLTWH(
      -size.width * .12,
      size.height * .69,
      size.width * 1.24,
      size.height * .36,
    );
    canvas.drawOval(
      fieldRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C6A48), Color(0xFF033326)],
        ).createShader(fieldRect)
        ..color = Colors.white.withValues(alpha: reveal),
    );

    final pitch = Path()
      ..moveTo(size.width * .45, size.height * .69)
      ..lineTo(size.width * .55, size.height * .69)
      ..lineTo(size.width * .64, size.height)
      ..lineTo(size.width * .36, size.height)
      ..close();
    canvas.drawPath(
      pitch,
      Paint()..color = const Color(0xFFB8954F).withValues(alpha: .36 * reveal),
    );

    final particlePaint = Paint()..color = const Color(0x55FFD166);
    for (var index = 0; index < 14; index++) {
      final x = ((index * 73) % 100) / 100 * size.width;
      final y = (.16 + ((index * 37) % 45) / 100) * size.height;
      canvas.drawCircle(
          Offset(x, y),
          index.isEven ? 1.1 : .7,
          particlePaint
            ..color = const Color(0x55FFD166).withValues(alpha: reveal * .3));
    }
  }

  void _drawFloodlight(Canvas canvas, Size size, bool left) {
    final x = left ? size.width * .11 : size.width * .89;
    final direction = left ? 1.0 : -1.0;
    final top = size.height * .12;
    final towerPaint = Paint()
      ..color = Colors.white.withValues(alpha: .18 * reveal)
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(x, top + 28), Offset(x, size.height * .68), towerPaint);

    final beam = Path()
      ..moveTo(x - direction * 9, top + 12)
      ..lineTo(size.width * .5, size.height * .62)
      ..lineTo(x + direction * 26, top + 25)
      ..close();
    final beamBounds = beam.getBounds();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: .18 * lightStrength),
            Colors.transparent,
          ],
        ).createShader(beamBounds),
    );

    final lampPaint = Paint()
      ..color = Colors.white.withValues(alpha: .85 * lightStrength);
    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 4; column++) {
        canvas.drawCircle(
          Offset(x + (column - 1.5) * 7, top + row * 8),
          2.2,
          lampPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StadiumPainter oldDelegate) =>
      oldDelegate.reveal != reveal ||
      oldDelegate.lightStrength != lightStrength;
}

class _CricketBallPainter extends CustomPainter {
  const _CricketBallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.35, -.4),
          colors: [Color(0xFFF05A55), Color(0xFF9D1F24)],
        ).createShader(Offset.zero & size),
    );
    final seam = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * .31),
      -math.pi / 2,
      math.pi,
      false,
      seam,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * .31),
      math.pi / 2,
      math.pi,
      false,
      seam,
    );
  }

  @override
  bool shouldRepaint(_CricketBallPainter oldDelegate) => false;
}
