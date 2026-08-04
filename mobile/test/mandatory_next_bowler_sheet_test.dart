import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/over_summary_bottom_sheet.dart';

void main() {
  testWidgets('over-complete sheet ignores outside tap and system back',
      (tester) async {
    const batting = Team(
      id: 'a',
      name: 'Alpha',
      shortName: 'A',
      players: [
        Player(id: 'a1', name: 'A1'),
        Player(id: 'a2', name: 'A2'),
        Player(id: 'a3', name: 'A3'),
      ],
    );
    const bowling = Team(
      id: 'b',
      name: 'Beta',
      shortName: 'B',
      players: [
        Player(id: 'b1', name: 'B1'),
        Player(id: 'b2', name: 'B2'),
      ],
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'sheet',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        ballsPerOver: 6,
        maxOversPerBowler: 1,
      ),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    for (var ball = 1; ball <= 6; ball++) {
      engine.recordDelivery(eventId: '$ball', scorerDeviceId: 'test');
    }

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              builder: (_) => OverSummaryBottomSheet(
                matchState: engine.state,
                onSelectNextBowler: () {},
                onEndMatch: () {},
              ),
            ),
            child: const Text('Open'),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsOneWidget);
  });
}
