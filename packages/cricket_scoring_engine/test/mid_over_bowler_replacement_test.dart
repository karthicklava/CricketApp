import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine createEngine({
  bool allowConsecutive = false,
  bool allowTactical = false,
}) =>
    CricketScoringEngine.createMatch(
      matchId: 'replacement',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 5,
        ballsPerOver: 6,
        maxOversPerBowler: 1,
        allowConsecutiveOvers: allowConsecutive,
        allowTacticalMidOverReplacement: allowTactical,
      ),
      teamA: const Team(
        id: 'bat',
        name: 'Batting',
        shortName: 'BAT',
        players: [
          Player(id: 'a1', name: 'A1'),
          Player(id: 'a2', name: 'A2'),
        ],
      ),
      teamB: const Team(
        id: 'bowl',
        name: 'Bowling',
        shortName: 'BWL',
        players: [
          Player(id: 'b1', name: 'Bowler A'),
          Player(id: 'b2', name: 'Bowler B'),
          Player(id: 'b3', name: 'Bowler C'),
          Player(id: 'b4', name: 'Bowler D'),
        ],
      ),
      tossWinnerTeamId: 'bat',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

void legalBall(CricketScoringEngine engine, String id, {int runs = 0}) {
  engine.recordDelivery(
    eventId: id,
    scorerDeviceId: 'test',
    runsBatter: runs,
  );
}

void main() {
  test('replacement completes the same over with split figures and quota', () {
    final engine = createEngine();
    legalBall(engine, 'a1');
    engine.recordDelivery(
      eventId: 'a-wide',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    legalBall(engine, 'a2', runs: 2);
    final before = engine.state.activeInnings;

    final replacement = engine.replaceCurrentBowler(
      newBowlerId: 'b2',
      reason: BowlerChangeReason.injury,
      changedBy: 'scorer',
    );

    expect(engine.state.activeInnings.activeOverId, before.activeOverId);
    expect(engine.state.activeInnings.legalBallsBowled, 2);
    expect(engine.state.activeInnings.totalRuns, before.totalRuns);
    expect(replacement.legalBallsCompleted, 2);
    expect(replacement.remainingLegalBalls, 4);
    expect(engine.state.bowlingSegments, hasLength(2));
    expect(engine.state.bowlingSegments.first.legalBallsBowled, 2);
    expect(engine.state.bowlingSegments.first.endReason,
        BowlerChangeReason.injury);

    engine.recordDelivery(
      eventId: 'b-nb',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.noBall,
      noBallRuns: 1,
    );
    for (var i = 0; i < 4; i++) {
      legalBall(engine, 'b$i');
    }

    expect(engine.state.activeInnings.legalBallsBowled, 6);
    expect(engine.state.activeInnings.flowState,
        InningsFlowState.awaitingNextBowler);
    expect(engine.state.events.map((event) => event.overNumber).toSet(), {0});
    final figures = engine.getBowlerScorecards(engine.state.teamB);
    final a = figures.firstWhere((row) => row.playerId == 'b1');
    final b = figures.firstWhere((row) => row.playerId == 'b2');
    expect(a.legalBallsBowled, 2);
    expect(a.wides, 1);
    expect(b.legalBallsBowled, 4);
    expect(b.noBalls, 1);
    expect(a.maidens, 0);
    expect(b.maidens, 0);
    expect(engine.state.bowlingSegments.last.legalBallsBowled, 4);
    expect(engine.state.bowlingSegments.last.isOpen, isFalse);

    expect(() => engine.selectNextBowler('b1'), throwsArgumentError);
    expect(() => engine.selectNextBowler('b2'), throwsArgumentError);
    engine.selectNextBowler('b3');
  });

  test('previous-over participant cannot replace a bowler mid-over', () {
    final engine = createEngine();
    for (var i = 0; i < 6; i++) {
      legalBall(engine, 'first-$i');
    }
    engine.selectNextBowler('b2');
    legalBall(engine, 'second-1');
    expect(
      () => engine.replaceCurrentBowler(
        newBowlerId: 'b1',
        reason: BowlerChangeReason.injury,
        changedBy: 'scorer',
      ),
      throwsArgumentError,
    );
  });

  test('suspension persists on resume and prevents a return', () {
    final engine = createEngine();
    legalBall(engine, 'one');
    engine.replaceCurrentBowler(
      newBowlerId: 'b2',
      reason: BowlerChangeReason.suspended,
      changedBy: 'scorer',
    );
    final resumed = CricketScoringEngine(
      MatchState.fromJson(engine.state.toJson()),
    );

    expect(resumed.state.activeInnings.currentBowlerId, 'b2');
    expect(resumed.state.activeInnings.legalBallsBowled, 1);
    expect(resumed.state.bowlerReplacementEvents.single.reason,
        BowlerChangeReason.suspended);
    expect(resumed.state.suspendedBowlerIds, contains('b1'));
    expect(
      () => resumed.replaceCurrentBowler(
        newBowlerId: 'b1',
        reason: BowlerChangeReason.injury,
        changedBy: 'scorer',
      ),
      throwsArgumentError,
    );
  });

  test('replacement undo is separate and blocked after a new delivery', () {
    final engine = createEngine();
    legalBall(engine, 'one');
    engine.replaceCurrentBowler(
      newBowlerId: 'b2',
      reason: BowlerChangeReason.injury,
      changedBy: 'scorer',
    );
    engine.undoBowlerReplacement();
    expect(engine.state.activeInnings.currentBowlerId, 'b1');
    expect(engine.state.activeInnings.legalBallsBowled, 1);
    expect(engine.state.bowlerReplacementEvents, isEmpty);

    engine.replaceCurrentBowler(
      newBowlerId: 'b2',
      reason: BowlerChangeReason.injury,
      changedBy: 'scorer',
    );
    legalBall(engine, 'two');
    expect(engine.undoBowlerReplacement, throwsStateError);
    engine.undoLastDelivery();
    expect(engine.state.activeInnings.currentBowlerId, 'b2');
    expect(engine.state.activeInnings.legalBallsBowled, 1);
  });

  test('tactical replacement requires the local match rule', () {
    final engine = createEngine();
    legalBall(engine, 'one');
    expect(
      () => engine.replaceCurrentBowler(
        newBowlerId: 'b2',
        reason: BowlerChangeReason.tacticalLocalRule,
        changedBy: 'scorer',
      ),
      throwsStateError,
    );

    final localEngine = createEngine(allowTactical: true);
    legalBall(localEngine, 'local-one');
    expect(
      () => localEngine.replaceCurrentBowler(
        newBowlerId: 'b2',
        reason: BowlerChangeReason.tacticalLocalRule,
        changedBy: 'scorer',
      ),
      returnsNormally,
    );
  });
}
