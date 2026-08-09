import 'package:cricket_scorer/presentation/scoring/widgets/completion_review_bottom_sheet.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/score_summary_card.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _batting = Team(
  id: 'a',
  name: 'Alpha',
  shortName: 'A',
  players: [Player(id: 'a1', name: 'A1'), Player(id: 'a2', name: 'A2')],
);
const _bowling = Team(
  id: 'b',
  name: 'Beta',
  shortName: 'B',
  players: [Player(id: 'b1', name: 'B1'), Player(id: 'b2', name: 'B2')],
);

CricketScoringEngine _engine(int totalOvers) =>
    CricketScoringEngine.createMatch(
      matchId: 'terminal-$totalOvers',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: totalOvers,
        maxOversPerBowler: totalOvers,
        allowConsecutiveOvers: true,
      ),
      teamA: _batting,
      teamB: _bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

void _completeScheduledOvers(CricketScoringEngine engine, int totalOvers) {
  for (var over = 0; over < totalOvers; over++) {
    for (var ball = 0; ball < 6; ball++) {
      engine.recordDelivery(
        eventId: '$over-$ball',
        scorerDeviceId: 'test',
      );
    }
    if (over < totalOvers - 1) engine.selectNextBowler('b1');
  }
}

DeliveryEvent _delivery({
  int runs = 0,
  bool four = false,
  bool six = false,
  int wideRuns = 0,
  int additionalWideRuns = 0,
  int noBallRuns = 0,
  int byeRuns = 0,
  int legByeRuns = 0,
  WicketDetail? wicket,
}) =>
    DeliveryEvent(
      eventId: 'label',
      matchId: 'match',
      inningsId: 'innings',
      overNumber: 0,
      legalBallNumber: 1,
      eventSequence: 1,
      sequenceInOver: 1,
      scorerDeviceId: 'test',
      strikerId: 'a1',
      nonStrikerId: 'a2',
      bowlerId: 'b1',
      runsBatter: runs,
      extrasType: wideRuns > 0
          ? ExtrasType.wide
          : noBallRuns > 0
              ? ExtrasType.noBall
              : legByeRuns > 0
                  ? ExtrasType.legBye
                  : byeRuns > 0
                      ? ExtrasType.bye
                      : ExtrasType.none,
      extrasRuns: wideRuns + noBallRuns + byeRuns + legByeRuns,
      wideRuns: wideRuns,
      additionalWideRuns: additionalWideRuns,
      noBallRuns: noBallRuns,
      byeRuns: byeRuns,
      legByeRuns: legByeRuns,
      isLegal: wideRuns == 0 && noBallRuns == 0,
      isBoundaryFour: four,
      isBoundarySix: six,
      wicket: wicket,
      previousEventHash: 'GENESIS',
      clientTimestamp: 1,
    );

void main() {
  test('terminal innings does not advance beyond configured over', () {
    for (final overs in [2, 5, 10]) {
      final engine = _engine(overs);
      _completeScheduledOvers(engine, overs);

      expect(engine.state.status, MatchStatus.inningsReview);
      expect(engine.state.activeInnings.nextOverNumber, overs - 1);
      expect(engine.state.events.last.overNumber + 1, overs);
      expect(engine.state.activeInnings.activeOverId, isNotNull);
    }
  });

  test('final delivery descriptions are clear and non-duplicated', () {
    expect(finalDeliveryDescription(_delivery()), 'Dot Ball');
    expect(finalDeliveryDescription(_delivery(runs: 4, four: true)),
        'Boundary Four');
    expect(finalDeliveryDescription(_delivery(runs: 4)), '4 Runs');
    expect(finalDeliveryDescription(_delivery(runs: 6, six: true)), 'Six');
    expect(finalDeliveryDescription(_delivery(wideRuns: 1)), 'Wide');
    expect(
        finalDeliveryDescription(_delivery(wideRuns: 3, additionalWideRuns: 2)),
        'Wd + 2');
    expect(finalDeliveryDescription(_delivery(noBallRuns: 1)), 'No Ball');
    expect(
        finalDeliveryDescription(_delivery(noBallRuns: 1, runs: 1)), 'Nb + 1');
    expect(finalDeliveryDescription(_delivery(legByeRuns: 2)), 'Leg Bye 2');
    expect(finalDeliveryDescription(_delivery(byeRuns: 3)), 'Bye 3');
    expect(
      finalDeliveryDescription(_delivery(
        wicket: const WicketDetail(
          type: WicketType.runOut,
          dismissedPlayerId: 'a1',
        ),
      )),
      'Run Out',
    );
  });

  testWidgets('completed two-over innings freezes Current Over at 2',
      (tester) async {
    final engine = _engine(2);
    _completeScheduledOvers(engine, 2);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScoreSummaryCard(
          matchState: engine.state,
          syncStatusText: 'Saved',
          isOnline: true,
        ),
      ),
    ));

    expect(find.text('Current Over · 2'), findsOneWidget);
    expect(find.text('Current Over · 3'), findsNothing);
    expect(find.text('No deliveries yet'), findsNothing);
  });

  testWidgets('target review shows one clear final-delivery description',
      (tester) async {
    final first = _engine(1);
    for (var ball = 0; ball < 6; ball++) {
      first.recordDelivery(
        eventId: 'first-$ball',
        scorerDeviceId: 'test',
        runsBatter: ball == 0 ? 3 : 0,
      );
    }
    first.confirmInningsEnd();
    first.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    first.recordDelivery(
      eventId: 'winning-four',
      scorerDeviceId: 'test',
      runsBatter: 4,
      isBoundaryFour: true,
    );

    expect(first.state.status, MatchStatus.matchReview);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompletionReviewBottomSheet(
          matchState: first.state,
          onUndo: () async => false,
          onEdit: () async => false,
          onConfirm: () async => false,
        ),
      ),
    ));

    expect(find.text('TARGET REACHED'), findsOneWidget);
    expect(find.text('Boundary Four'), findsOneWidget);
    expect(find.textContaining('4 · 4'), findsNothing);
  });
}
