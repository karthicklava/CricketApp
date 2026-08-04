import 'package:cricket_scorer/presentation/scorecard/widgets/responsive_scorecard_tables.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const batter = BatterScorecard(
  playerId: 'b1',
  playerName: 'Chandra Mohan With A Very Long Name',
  runs: 118,
  ballsFaced: 87,
  fours: 12,
  sixes: 5,
  dismissalInfo: 'c Maheshwaran b Kabilash Cricket Club Captain',
  isDismissed: true,
  battingPosition: 1,
  hasBatted: true,
);

const bowler = BowlerScorecard(
  playerId: 'p1',
  playerName: 'Saravanan With A Very Long Bowling Name',
  legalBallsBowled: 12,
  maidens: 1,
  runsConceded: 22,
  wickets: 3,
  wides: 1,
  noBalls: 2,
  bowlingPosition: 1,
);

Widget app(Widget child, {double width = 320, double scale = 1}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(body: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  testWidgets('role labels stay inside scorecard player columns',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(ResponsiveBattingTable(
      rows: const [batter],
      didNotBat: const [],
      isCompleted: true,
      displayName: (_, name) => '$name (C & WK)',
    )));

    expect(find.textContaining('(C & WK)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('essential batting columns fit 320dp without horizontal scroll',
      (tester) async {
    await tester.pumpWidget(app(const ResponsiveBattingTable(
      rows: [batter],
      didNotBat: [
        BatterScorecard(playerId: 'dnb', playerName: 'Unused Player')
      ],
      isCompleted: true,
    )));

    expect(find.text('R'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('4s'), findsOneWidget);
    expect(find.text('6s'), findsOneWidget);
    expect(find.text('SR'), findsOneWidget);
    expect(find.text('118'), findsOneWidget);
    expect(find.text('135.6'), findsOneWidget);
    expect(find.byType(DidNotBatRow), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('bowling columns and long names fit with scaled text',
      (tester) async {
    await tester.pumpWidget(app(
      const ResponsiveBowlingTable(rows: [bowler]),
      scale: 1.4,
    ));

    for (final label in ['O', 'M', 'R', 'W', 'Eco', '2.0', '22', '3']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Wd 1 · Nb 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet batting layout exposes a dismissal column',
      (tester) async {
    await tester.pumpWidget(app(
      const ResponsiveBattingTable(
          rows: [batter], didNotBat: [], isCompleted: true),
      width: 700,
    ));
    expect(find.text('Dismissal'), findsOneWidget);
    expect(find.text(batter.dismissalInfo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
