import 'package:cricket_scorer/presentation/scorecard/widgets/scorecard_dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(double width, Widget child, {double scale = 1}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 700),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: SizedBox(width: width, child: child),
        ),
      ),
    );

const tiles = ResponsiveScoreStatTiles(children: [
  PartnershipCard(runs: 1234, balls: 456, boundaries: 78, runRate: 16.75),
  ExtrasCard(wides: 120, noBalls: 34, byes: 5, legByes: 6, penalty: 7),
]);

void main() {
  testWidgets('standard mobile uses equal aligned two-column tiles',
      (tester) async {
    await tester.pumpWidget(app(400, tiles));

    final partnership =
        tester.getRect(find.byKey(const ValueKey('score-stat-partnership')));
    final extras =
        tester.getRect(find.byKey(const ValueKey('score-stat-extras')));
    expect(partnership.left, 0);
    expect(extras.right, 400);
    expect(partnership.top, extras.top);
    expect(partnership.bottom, extras.bottom);
    expect(partnership.width, extras.width);
    expect(extras.left - partnership.right, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('below 360dp stacks full-width consistently', (tester) async {
    await tester.pumpWidget(app(340, tiles));

    final partnership =
        tester.getRect(find.byKey(const ValueKey('score-stat-partnership')));
    final extras =
        tester.getRect(find.byKey(const ValueKey('score-stat-extras')));
    expect(partnership.left, 0);
    expect(partnership.right, 340);
    expect(extras.left, 0);
    expect(extras.right, 340);
    expect(extras.top - partnership.bottom, 12);
  });

  testWidgets('large values and text scaling do not overflow', (tester) async {
    await tester.pumpWidget(app(400, tiles, scale: 1.4));
    expect(find.text('1234 runs · 456 balls'), findsOneWidget);
    expect(find.text('Total 172'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal),
      findsNothing,
    );
  });

  testWidgets('empty-state tiles retain shared dimensions', (tester) async {
    await tester.pumpWidget(app(
      400,
      const ResponsiveScoreStatTiles(children: [
        CompactScoreStatTile(
          title: 'Partnership',
          primaryContent: Text('No active partnership'),
          secondaryContent: Text('Partnership details will appear here.'),
        ),
        ExtrasCard(wides: 0, noBalls: 0, byes: 0, legByes: 0, penalty: 0),
      ]),
    ));
    final partnership =
        tester.getRect(find.byKey(const ValueKey('score-stat-partnership')));
    final extras =
        tester.getRect(find.byKey(const ValueKey('score-stat-extras')));
    expect(partnership.size, extras.size);
    expect(find.text('No extras'), findsOneWidget);
  });
}
