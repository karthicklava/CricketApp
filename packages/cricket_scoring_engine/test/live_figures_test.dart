import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine engineFor({
  int ballsPerOver = 6,
  int totalOvers = 5,
}) =>
    CricketScoringEngine.createMatch(
      matchId: 'live',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: totalOvers,
        ballsPerOver: ballsPerOver,
        maxOversPerBowler: totalOvers,
        allowConsecutiveOvers: true,
      ),
      teamA: const Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [
          Player(id: 'a1', name: 'Karthick'),
          Player(id: 'a2', name: 'Ragu'),
          Player(id: 'a3', name: 'Saravana'),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'Beta',
        shortName: 'B',
        players: [
          Player(id: 'b1', name: 'Arjun'),
          Player(id: 'b2', name: 'Ravi'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

void main() {
  const service = LiveFiguresService();

  test('normal runs, boundaries and strike rotation stay with each batter', () {
    final engine = engineFor();
    engine.recordDelivery(
        eventId: '1', scorerDeviceId: 't', runsBatter: 4);
    engine.recordDelivery(
        eventId: '2', scorerDeviceId: 't', runsBatter: 1);
    final figures = service.calculate(engine.state);

    expect(figures.striker.playerId, 'a2');
    expect(figures.striker.runs, 0);
    expect(figures.striker.ballsFaced, 0);
    expect(figures.nonStriker.playerId, 'a1');
    expect(figures.nonStriker.runs, 5);
    expect(figures.nonStriker.ballsFaced, 2);
  });

  test('wide and no ball do not add a ball faced', () {
    final engine = engineFor();
    engine.recordDelivery(
      eventId: 'wide',
      scorerDeviceId: 't',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    engine.recordDelivery(
      eventId: 'no-ball',
      scorerDeviceId: 't',
      extrasType: ExtrasType.noBall,
      noBallRuns: 1,
      runsBatter: 4,
    );
    final figures = service.calculate(engine.state);
    expect(figures.striker.runs, 4);
    expect(figures.striker.ballsFaced, 0);
    expect(figures.bowler.legalBalls, 0);
    expect(figures.bowler.runsConceded, 6);
  });

  test('byes and leg byes add balls but not batter or bowler runs', () {
    final engine = engineFor();
    engine.recordDelivery(
      eventId: 'bye',
      scorerDeviceId: 't',
      extrasType: ExtrasType.bye,
      byeRuns: 2,
    );
    engine.recordDelivery(
      eventId: 'leg-bye',
      scorerDeviceId: 't',
      extrasType: ExtrasType.legBye,
      legByeRuns: 2,
    );
    final figures = service.calculate(engine.state);
    expect(figures.striker.runs, 0);
    expect(figures.striker.ballsFaced, 2);
    expect(figures.bowler.legalBalls, 2);
    expect(figures.bowler.runsConceded, 0);
  });

  test('bowler wicket uses centralized credit and run out is excluded', () {
    final engine = engineFor();
    engine.recordDelivery(
      eventId: 'run-out',
      scorerDeviceId: 't',
      wicket: const WicketDetail(
        type: WicketType.runOut,
        dismissedPlayerId: 'a1',
      ),
      newBatterId: 'a3',
    );
    engine.recordDelivery(
      eventId: 'caught',
      scorerDeviceId: 't',
      wicket: const WicketDetail(
        type: WicketType.caught,
        dismissedPlayerId: 'a3',
      ),
      newBatterId: 'a1',
    );
    expect(service.calculate(engine.state).bowler.wickets, 1);
  });

  test('maiden counts only after a complete zero-conceded over', () {
    final engine = engineFor();
    for (var i = 0; i < 5; i++) {
      engine.recordDelivery(eventId: '$i', scorerDeviceId: 't');
    }
    expect(service.calculate(engine.state).bowler.maidens, 0);
    engine.recordDelivery(eventId: '6', scorerDeviceId: 't');
    expect(service.calculate(engine.state).bowler.maidens, 1);
  });

  test('fourteen legal balls use 2.2 notation and legal-ball economy', () {
    final engine = engineFor(totalOvers: 5);
    for (var i = 0; i < 14; i++) {
      if (engine.state.activeInnings.flowState ==
          InningsFlowState.awaitingNextBowler) {
        engine.selectNextBowler('b1');
      }
      engine.recordDelivery(
        eventId: '$i',
        scorerDeviceId: 't',
        runsBatter: i < 12 ? 1 : 0,
      );
    }
    final bowler = service.calculate(engine.state).bowler;
    expect(bowler.oversDisplay, '2.2');
    expect(bowler.runsConceded, 12);
    expect(bowler.economy.toStringAsFixed(2), '5.14');
  });

  test('custom balls per over are used for notation and economy', () {
    final engine = engineFor(ballsPerOver: 4);
    for (var i = 0; i < 6; i++) {
      if (engine.state.activeInnings.flowState ==
          InningsFlowState.awaitingNextBowler) {
        engine.selectNextBowler('b1');
      }
      engine.recordDelivery(
        eventId: '$i',
        scorerDeviceId: 't',
        runsBatter: 1,
      );
    }
    final bowler = service.calculate(engine.state).bowler;
    expect(bowler.oversDisplay, '1.2');
    expect(bowler.economy.toStringAsFixed(2), '4.00');
  });

  test('new and returning bowlers load their event-derived figures', () {
    final engine = engineFor();
    engine.recordDelivery(
        eventId: '1', scorerDeviceId: 't', runsBatter: 2);
    engine.changeBowler('b2');
    expect(service.calculate(engine.state).bowler.runsConceded, 0);
    engine.recordDelivery(
        eventId: '2', scorerDeviceId: 't', runsBatter: 1);
    engine.changeBowler('b1');
    final returned = service.calculate(engine.state).bowler;
    expect(returned.runsConceded, 2);
    expect(returned.legalBalls, 1);
  });

  test('undo and serialized resume restore exact live figures', () {
    final engine = engineFor();
    engine.recordDelivery(
        eventId: '1', scorerDeviceId: 't', runsBatter: 4);
    engine.recordDelivery(
        eventId: '2', scorerDeviceId: 't', runsBatter: 1);
    engine.undoLastDelivery();
    final before = service.calculate(engine.state);
    final restored =
        service.calculate(MatchState.fromJson(engine.state.toJson()));

    expect(before.striker.runs, 4);
    expect(before.striker.ballsFaced, 1);
    expect(before.bowler.runsConceded, 4);
    expect(restored.striker.runs, before.striker.runs);
    expect(restored.bowler.legalBalls, before.bowler.legalBalls);
  });
}
