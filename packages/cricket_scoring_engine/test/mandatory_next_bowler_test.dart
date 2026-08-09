import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

void main() {
  const batting = Team(
    id: 'bat',
    name: 'Batting',
    shortName: 'BAT',
    players: [
      Player(id: 'a1', name: 'A1'),
      Player(id: 'a2', name: 'A2'),
      Player(id: 'a3', name: 'A3'),
    ],
  );
  const bowling = Team(
    id: 'bowl',
    name: 'Bowling',
    shortName: 'BWL',
    players: [
      Player(id: 'b1', name: 'B1'),
      Player(id: 'b2', name: 'B2'),
      Player(id: 'b3', name: 'B3'),
    ],
  );

  CricketScoringEngine engine({bool allowConsecutive = false}) =>
      CricketScoringEngine.createMatch(
        matchId: 'mandatory-bowler',
        config: MatchConfig(
          format: MatchFormat.custom,
          totalOvers: 2,
          ballsPerOver: 6,
          maxOversPerBowler: 2,
          allowConsecutiveOvers: allowConsecutive,
        ),
        teamA: batting,
        teamB: bowling,
        tossWinnerTeamId: batting.id,
        tossDecision: 'BAT',
        openingStrikerId: 'a1',
        openingNonStrikerId: 'a2',
        openingBowlerId: 'b1',
      );

  void completeOver(CricketScoringEngine value) {
    for (var ball = 1; ball <= 6; ball++) {
      value.recordDelivery(
        eventId: 'ball-$ball',
        scorerDeviceId: 'device',
      );
    }
  }

  test('completed over clears active bowler and locks scoring', () {
    final value = engine();
    completeOver(value);

    expect(value.state.activeInnings.flowState,
        InningsFlowState.awaitingNextBowler);
    expect(value.state.activeInnings.currentBowlerId, isNull);
    expect(value.state.activeInnings.activeOverId, isNull);
    expect(value.state.activeInnings.previousOverBowlerId, 'b1');
    expect(
      () => value.recordDelivery(
        eventId: 'stale-ball',
        scorerDeviceId: 'device',
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      () => value.recordDelivery(
        eventId: 'stale-wide',
        scorerDeviceId: 'device',
        extrasType: ExtrasType.wide,
        wideRuns: 1,
      ),
      throwsA(isA<StateError>()),
    );
    expect(value.state.events, hasLength(6));
  });

  test('next over exists only after explicit eligible bowler confirmation', () {
    final value = engine();
    completeOver(value);

    expect(() => value.selectNextBowler('b1'), throwsArgumentError);
    value.selectNextBowler('b2');

    expect(value.state.activeInnings.flowState, InningsFlowState.scoring);
    expect(value.state.activeInnings.currentBowlerId, 'b2');
    expect(value.state.activeInnings.activeOverId,
        'mandatory-bowler_inn_1_over_1');
    value.recordDelivery(eventId: 'over-2-ball-1', scorerDeviceId: 'device');
    expect(value.state.events.last.bowlerId, 'b2');
  });

  test('last-ball wicket installs batter before awaiting next bowler', () {
    final value = engine();
    for (var ball = 1; ball <= 5; ball++) {
      value.recordDelivery(
        eventId: 'wicket-over-$ball',
        scorerDeviceId: 'device',
      );
    }

    value.recordDelivery(
      eventId: 'wicket-over-6',
      scorerDeviceId: 'device',
      wicket: const WicketDetail(
        type: WicketType.bowled,
        dismissedPlayerId: 'a1',
      ),
    );

    var innings = value.state.activeInnings;
    expect(innings.totalWickets, 1);
    expect(innings.flowState, InningsFlowState.awaitingNextBatter);
    expect(innings.currentBowlerId, isNull);
    expect(innings.activeOverId, isNull);

    value.selectNextBatter(
      newBatterId: 'a3',
      replaceStriker: false,
    );
    innings = value.state.activeInnings;
    expect(innings.flowState, InningsFlowState.awaitingNextBowler);
    expect(innings.currentBowlerId, isNull);
    expect(innings.activeOverId, isNull);
    expect({innings.strikerId, innings.nonStrikerId}, {'a2', 'a3'});
    expect(
      () => value.recordDelivery(
        eventId: 'blocked-before-bowler',
        scorerDeviceId: 'device',
      ),
      throwsA(isA<StateError>()),
    );

    value.selectNextBowler('b2');
    expect(value.state.activeInnings.flowState, InningsFlowState.scoring);
  });

  test('consecutive-over rule still requires explicit confirmation', () {
    final value = engine(allowConsecutive: true);
    completeOver(value);
    expect(value.state.activeInnings.currentBowlerId, isNull);

    value.selectNextBowler('b1');
    expect(value.state.activeInnings.currentBowlerId, 'b1');
    expect(value.state.activeInnings.flowState, InningsFlowState.scoring);
  });

  test('undo final ball restores the active over and previous bowler', () {
    final value = engine();
    completeOver(value);

    value.undoLastDelivery();

    expect(value.state.activeInnings.legalBallsBowled, 5);
    expect(value.state.activeInnings.flowState, InningsFlowState.scoring);
    expect(value.state.activeInnings.currentBowlerId, 'b1');
    expect(value.state.activeInnings.activeOverId, isNotNull);
  });

  test('persisted awaiting state survives serialization', () {
    final value = engine();
    completeOver(value);

    final restored = MatchState.fromJson(value.state.toJson());
    expect(
        restored.activeInnings.flowState, InningsFlowState.awaitingNextBowler);
    expect(restored.activeInnings.currentBowlerId, isNull);
    expect(restored.activeInnings.activeOverId, isNull);
  });

  test('final innings over completes innings without requesting a bowler', () {
    final value = CricketScoringEngine.createMatch(
      matchId: 'final-over',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        ballsPerOver: 6,
        maxOversPerBowler: 1,
      ),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: batting.id,
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

    completeOver(value);

    expect(
        value.state.activeInnings.flowState, InningsFlowState.inningsCompleted);
    expect(value.state.status, MatchStatus.inningsReview);
  });
}
