import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scorer/presentation/common/widgets/sports_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sports theme uses the product palette and Material 3', () {
    final theme = AppTheme.lightTheme;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, const Color(0xFF0B6E4F));
    expect(theme.colorScheme.secondary, const Color(0xFFFFB000));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F7FA));
  });

  test('all Material CTA families share the capsule specification', () {
    final theme = AppTheme.lightTheme;
    final states = <WidgetState>{};
    final filled = theme.filledButtonTheme.style!;
    final elevated = theme.elevatedButtonTheme.style!;
    final outlined = theme.outlinedButtonTheme.style!;

    for (final style in [filled, elevated, outlined]) {
      expect(style.minimumSize?.resolve(states)?.height, AppCtaStyle.height);
      expect(style.shape?.resolve(states), isA<StadiumBorder>());
      expect(style.textStyle?.resolve(states)?.fontWeight, FontWeight.w800);
    }
    expect(filled.backgroundColor?.resolve(states), AppColors.primary);
    expect(elevated.backgroundColor?.resolve(states), AppColors.primary);
    expect(outlined.backgroundColor?.resolve(states), Colors.white);
    expect(outlined.side?.resolve(states)?.color, AppColors.primary);
  });

  testWidgets('shared controls and floating navigation fit compact phones',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppCard(child: Text('Premium sports card')),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Continue', onPressed: () {}),
            const SizedBox(height: 8),
            SecondaryButton(label: 'View scorecard', onPressed: () {}),
          ],
        ),
        bottomNavigationBar: PremiumBottomNavigation(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      ),
    ));

    expect(find.text('Premium sports card'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    final primarySize = tester.getSize(find.byType(FilledButton));
    final secondarySize = tester.getSize(find.byType(OutlinedButton));
    expect(primarySize.height, AppCtaStyle.height);
    expect(secondarySize.height, AppCtaStyle.height);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and status components expose readable labels',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Column(
          children: [
            StatusBadge(label: 'Live', tone: StatusBadgeTone.live),
            Expanded(
              child: EmptyStateWidget(
                icon: Icons.sports_cricket,
                title: 'No live match',
                message: 'Create a match to begin scoring.',
              ),
            ),
          ],
        ),
      ),
    ));

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('No live match'), findsOneWidget);
    expect(find.text('Create a match to begin scoring.'), findsOneWidget);
  });
}
