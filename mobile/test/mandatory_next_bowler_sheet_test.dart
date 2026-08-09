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
                onUndoLastBall: engine.undoLastDelivery,
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
    expect(find.text('UNDO LAST BALL'), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsOneWidget);

    await tester.tap(find.text('UNDO LAST BALL'));
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BOWLER'), findsNothing);
    expect(engine.state.activeInnings.legalBallsBowled, 5);
    expect(engine.state.activeInnings.flowState, InningsFlowState.scoring);
  });

  test('undo after next-bowler selection removes the empty next over', () {
    const batting = Team(
      id: 'a',
      name: 'Alpha',
      shortName: 'A',
      players: [Player(id: 'a1', name: 'A1'), Player(id: 'a2', name: 'A2')],
    );
    const bowling = Team(
      id: 'b',
      name: 'Beta',
      shortName: 'B',
      players: [Player(id: 'b1', name: 'B1'), Player(id: 'b2', name: 'B2')],
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'empty-next-over',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
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
    for (var ball = 0; ball < 6; ball++) {
      engine.recordDelivery(eventId: 'ball-$ball', scorerDeviceId: 'test');
    }
    engine.selectNextBowler('b2');
    expect(engine.state.activeInnings.activeOverId, endsWith('_over_1'));

    engine.undoLastDelivery();

    expect(engine.state.events, hasLength(5));
    expect(engine.state.activeInnings.legalBallsBowled, 5);
    expect(engine.state.activeInnings.currentBowlerId, 'b1');
    expect(engine.state.activeInnings.activeOverId, endsWith('_over_0'));
    expect(engine.state.activeInnings.flowState, InningsFlowState.scoring);
    expect(
      engine.state.bowlingSegments.where((segment) => segment.overNumber == 1),
      isEmpty,
    );
  });
}
