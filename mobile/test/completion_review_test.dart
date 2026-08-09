import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const teamA = Team(
    id: 'a',
    name: 'Alpha',
    shortName: 'A',
    players: [Player(id: 'a1', name: 'A1'), Player(id: 'a2', name: 'A2')],
  );
  const teamB = Team(
    id: 'b',
    name: 'Beta',
    shortName: 'B',
    players: [Player(id: 'b1', name: 'B1'), Player(id: 'b2', name: 'B2')],
  );

  CricketScoringEngine engine() => CricketScoringEngine.createMatch(
        matchId: 'review',
        config: const MatchConfig(
          format: MatchFormat.custom,
          totalOvers: 1,
          maxOversPerBowler: 1,
        ),
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: 'a',
        tossDecision: 'BAT',
        openingStrikerId: 'a1',
        openingNonStrikerId: 'a2',
        openingBowlerId: 'b1',
      );

  void completeFirstInnings(CricketScoringEngine value) {
    for (var ball = 0; ball < 6; ball++) {
      value.recordDelivery(
        eventId: 'first-$ball',
        scorerDeviceId: 'test',
        runsBatter: ball == 5 ? 6 : 0,
      );
    }
  }

  test('first innings remains provisional until explicit confirmation', () {
    final value = engine();
    completeFirstInnings(value);

    expect(value.state.status, MatchStatus.inningsReview);
    expect(value.state.innings, hasLength(1));
    expect(value.state.activeInnings.totalRuns, 6);
    expect(
      () => value.startSecondInnings(
        openingStrikerId: 'b1',
        openingNonStrikerId: 'b2',
        openingBowlerId: 'a1',
      ),
      throwsStateError,
    );

    final restored = CricketScoringEngine(
      MatchState.fromJson(value.state.toJson()),
    );
    expect(restored.state.status, MatchStatus.inningsReview);

    value.confirmInningsEnd();
    value.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    expect(value.state.innings, hasLength(2));
    expect(value.state.activeInnings.targetRuns, 7);
  });

  test('undo and replacement final ball recalculate confirmed target', () {
    final value = engine();
    completeFirstInnings(value);
    value.undoLastDelivery();
    expect(value.state.status, MatchStatus.live);
    expect(value.state.activeInnings.legalBallsBowled, 5);

    value.recordDelivery(
      eventId: 'corrected-final',
      scorerDeviceId: 'test',
      runsBatter: 4,
    );
    expect(value.state.status, MatchStatus.inningsReview);
    expect(value.state.activeInnings.totalRuns, 4);
    value.confirmInningsEnd();
    value.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    expect(value.state.activeInnings.targetRuns, 5);
  });

  test('winning delivery remains provisional and can reopen the chase', () {
    final value = engine();
    completeFirstInnings(value);
    value.confirmInningsEnd();
    value.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    value.recordDelivery(
      eventId: 'provisional-win',
      scorerDeviceId: 'test',
      runsBatter: 7,
    );
    expect(value.state.status, MatchStatus.matchReview);
    expect(value.state.result, isNull);
    expect(value.state.awards, isEmpty);

    value.undoLastDelivery();
    expect(value.state.status, MatchStatus.live);
    expect(value.state.activeInnings.totalRuns, 0);

    value.recordDelivery(
      eventId: 'confirmed-win',
      scorerDeviceId: 'test',
      runsBatter: 7,
    );
    value.confirmMatchEnd();
    expect(value.state.status, MatchStatus.completed);
    expect(value.state.result, isNotNull);
  });
}
