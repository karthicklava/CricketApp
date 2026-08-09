import 'dart:io';

import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scorer/presentation/common/widgets/brand_logo.dart';
import 'package:cricket_scorer/presentation/splash/turf_score_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget splashApp({
  Duration duration = const Duration(milliseconds: 80),
  Duration reducedDuration = const Duration(milliseconds: 20),
  bool reduceMotion = false,
}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
        ),
        child: child!,
      ),
      home: TurfScoreStartupGate(
        animationDuration: duration,
        reducedMotionDuration: reducedDuration,
        child: const Scaffold(body: Center(child: Text('HOME READY'))),
      ),
    );

class _StartupProbe extends StatefulWidget {
  const _StartupProbe();

  static int initializationCount = 0;

  @override
  State<_StartupProbe> createState() => _StartupProbeState();
}

class _StartupProbeState extends State<_StartupProbe> {
  @override
  void initState() {
    super.initState();
    _StartupProbe.initializationCount++;
  }

  @override
  Widget build(BuildContext context) => const Text('RESTORED MATCH STATE');
}

void main() {
  testWidgets('cold start shows bundled TurfScore branding then reveals Home',
      (tester) async {
    await tester.pumpWidget(splashApp());

    expect(find.byKey(const ValueKey('splash-app-name')), findsOneWidget);
    expect(find.text('EVERY MATCH. EVERY MOMENT.'), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    final image = tester.widget<Image>(
      find.descendant(
        of: find.byType(BrandLogo),
        matching: find.byType(Image),
      ),
    );
    expect((image.image as AssetImage).assetName, BrandLogo.assetPath);

    await tester.pumpAndSettle();

    expect(find.text('HOME READY'), findsOneWidget);
    expect(find.byKey(const ValueKey('splash-app-name')), findsNothing);
  });

  testWidgets('reduced motion skips ball trajectory and finishes quickly',
      (tester) async {
    await tester.pumpWidget(splashApp(
      duration: const Duration(seconds: 2),
      reducedDuration: const Duration(milliseconds: 30),
      reduceMotion: true,
    ));

    expect(find.byKey(const ValueKey('splash-cricket-ball')), findsNothing);
    expect(find.byType(BrandLogo), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('splash-app-name')), findsNothing);
  });

  testWidgets('startup child initializes once underneath the splash',
      (tester) async {
    _StartupProbe.initializationCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: TurfScoreStartupGate(
        animationDuration: const Duration(milliseconds: 50),
        child: const Scaffold(body: _StartupProbe()),
      ),
    ));

    expect(_StartupProbe.initializationCount, 1);
    await tester.pumpAndSettle();
    expect(find.text('RESTORED MATCH STATE'), findsOneWidget);
    expect(_StartupProbe.initializationCount, 1);
  });

  for (final size in [const Size(320, 568), const Size(1024, 1366)]) {
    testWidgets('splash remains centered without overflow at ${size.width}px',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(splashApp());
      await tester.pump(const Duration(milliseconds: 35));

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.byKey(const ValueKey('splash-tagline')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('splash is offline-only and native launch screens stay branded', () {
    final source = File(
      'lib/presentation/splash/turf_score_splash_screen.dart',
    ).readAsStringSync();
    final androidLaunch =
        File('android/app/src/main/res/drawable/launch_background.xml')
            .readAsStringSync();
    final androidColors =
        File('android/app/src/main/res/values/colors.xml').readAsStringSync();
    final android12Launch =
        File('android/app/src/main/res/values-v31/styles.xml')
            .readAsStringSync();
    final iosLaunch = File('ios/Runner/Base.lproj/LaunchScreen.storyboard')
        .readAsStringSync();

    expect(source, isNot(contains('Image.network')));
    expect(source, isNot(contains('http')));
    expect(source, contains('BrandLogo'));
    expect(androidLaunch, contains('@drawable/brand_splash_logo'));
    expect(androidColors, contains('#052E23'));
    expect(android12Launch, contains('windowSplashScreenBackground'));
    expect(android12Launch, contains('@drawable/brand_splash_logo'));
    expect(iosLaunch, contains('image="LaunchImage"'));
  });
}
