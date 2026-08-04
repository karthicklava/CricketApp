import 'package:test/test.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

void main() {
  late Team teamA;
  late Team teamB;
  late MatchConfig config;

  setUp(() {
    teamA = const Team(
      id: 'team_a',
      name: 'India',
      shortName: 'IND',
      players: [
        Player(id: 'p1', name: 'Rohit Sharma'),
        Player(id: 'p2', name: 'Virat Kohli'),
        Player(id: 'p3', name: 'Suryakumar Yadav'),
        Player(id: 'p4', name: 'Rishabh Pant'),
        Player(id: 'p5', name: 'Hardik Pandya'),
      ],
    );

    teamB = const Team(
      id: 'team_b',
      name: 'Australia',
      shortName: 'AUS',
      players: [
        Player(id: 'p6', name: 'Pat Cummins'),
        Player(id: 'p7', name: 'Mitchell Starc'),
        Player(id: 'p8', name: 'Josh Hazlewood'),
        Player(id: 'p9', name: 'Travis Head'),
        Player(id: 'p10', name: 'David Warner'),
      ],
    );

    config = MatchConfig.t20();
  });

  group('CricketScoringEngine - Basic Scoring & Strike Rotation', () {
    test('Dot ball does not change strike or team score', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        runsBatter: 0,
      );

      expect(engine.state.activeInnings.totalRuns, equals(0));
      expect(engine.state.activeInnings.legalBallsBowled, equals(1));
      expect(engine.state.activeInnings.strikerId, equals('p1'));
      expect(engine.state.activeInnings.nonStrikerId, equals('p2'));
    });

    test('Single run updates score and switches strike', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        runsBatter: 1,
      );

      expect(engine.state.activeInnings.totalRuns, equals(1));
      expect(engine.state.activeInnings.strikerId, equals('p2'));
      expect(engine.state.activeInnings.nonStrikerId, equals('p1'));
    });

    test('Boundary 4 updates score and keeps striker', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        runsBatter: 4,
        isBoundaryFour: true,
      );

      expect(engine.state.activeInnings.totalRuns, equals(4));
      expect(engine.state.activeInnings.strikerId, equals('p1'));
      expect(engine.state.activeInnings.nonStrikerId, equals('p2'));
    });
  });

  group('CricketScoringEngine - Extras', () {
    test('Wide ball adds extra run and does not count as legal ball', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.wide,
        extrasRuns: 0, // Default 1 wide run from config
      );

      expect(engine.state.activeInnings.totalRuns, equals(1));
      expect(engine.state.activeInnings.legalBallsBowled, equals(0));
      expect(engine.state.activeInnings.strikerId, equals('p1'));
    });

    test('No ball plus 2 batter runs adds 3 total runs and charges bowler 3',
        () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        runsBatter: 2,
        extrasType: ExtrasType.noBall,
      );

      expect(engine.state.activeInnings.totalRuns, equals(3));
      expect(engine.state.activeInnings.legalBallsBowled, equals(0));
      expect(engine.state.activeInnings.strikerId, equals('p1'));

      final bowlers = engine.getBowlerScorecards(teamB);
      expect(bowlers.first.runsConceded, equals(3));
      expect(bowlers.first.noBalls, equals(1));
    });

    test('Byes do not charge bowler runs', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.bye,
        extrasRuns: 2,
      );

      expect(engine.state.activeInnings.totalRuns, equals(2));
      final bowlers = engine.getBowlerScorecards(teamB);
      expect(bowlers.first.runsConceded, equals(0));
    });

    test('Wide is labelled, sequenced, and keeps the pending legal ball', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'dot',
        scorerDeviceId: 'dev1',
      );
      final wide = engine.recordDelivery(
        eventId: 'wide',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.wide,
        additionalWideRuns: 1,
      );

      expect(wide.displayLabel, equals('Wd+1'));
      expect(wide.additionalWideRuns, 1);
      expect(wide.ballReference, equals('1.2'));
      expect(wide.isLegal, isFalse);
      expect(engine.state.activeInnings.legalBallsBowled, equals(1));
      expect(engine.state.activeInnings.totalRuns, equals(2));
    });

    test('zero additional Wide runs adds mandatory penalty only', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'wide-zero-additional',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      final wide = engine.recordDelivery(
        eventId: 'wide',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.wide,
        additionalWideRuns: 0,
      );

      expect(wide.wideRuns, 1);
      expect(wide.additionalWideRuns, 0);
      expect(wide.totalRuns, 1);
      expect(wide.displayLabel, 'Wd');
      expect(wide.isLegal, isFalse);
    });

    test('explicit zero-run Wide is rejected without changing state', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      expect(
        () => engine.recordDelivery(
          eventId: 'invalid-wide',
          scorerDeviceId: 'dev1',
          extrasType: ExtrasType.wide,
          wideRuns: 0,
        ),
        throwsArgumentError,
      );
      expect(engine.state.activeInnings.totalRuns, 0);
      expect(engine.state.activeInnings.legalBallsBowled, 0);
      expect(engine.state.events, isEmpty);
    });

    test('serialized resume preserves a multiple Wide as source of truth', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'wide-three',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.wide,
        additionalWideRuns: 2,
      );
      final resumed = CricketScoringEngine(
        MatchState.fromJson(engine.state.toJson()),
      );

      expect(resumed.state.activeInnings.totalRuns, 3);
      expect(resumed.state.activeInnings.legalBallsBowled, 0);
      expect(resumed.state.events.single.wideRuns, 3);
      expect(resumed.state.events.single.additionalWideRuns, 2);
      expect(resumed.state.events.single.displayLabel, 'Wd+2');
      expect(resumed.getBowlerScorecards(teamB).first.runsConceded, 3);
    });

    test('No ball plus boundary retains the no-ball label and batter runs', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      final event = engine.recordDelivery(
        eventId: 'nb4',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.noBall,
        noBallRuns: 1,
        runsBatter: 4,
        isBoundaryFour: true,
      );

      expect(event.displayLabel, equals('Nb+4'));
      expect(event.totalRuns, equals(5));
      expect(engine.state.activeInnings.legalBallsBowled, equals(0));
      expect(engine.getBatterScorecards(teamA).first.runs, equals(4));
    });

    test('Odd bye and leg bye runs rotate strike and do not charge bowler', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      final bye = engine.recordDelivery(
        eventId: 'bye',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.bye,
        byeRuns: 1,
      );
      expect(bye.displayLabel, equals('B1'));
      expect(engine.state.activeInnings.strikerId, equals('p2'));

      final legBye = engine.recordDelivery(
        eventId: 'leg-bye',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.legBye,
        legByeRuns: 3,
      );
      expect(legBye.displayLabel, equals('LB3'));
      expect(engine.state.activeInnings.strikerId, equals('p1'));
      expect(engine.state.activeInnings.legalBallsBowled, equals(2));
      expect(engine.getBowlerScorecards(teamB).first.runsConceded, equals(0));
    });

    test('Undo removes an illegal extra and restores its ball reference', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'wide',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.wide,
        wideRuns: 1,
      );
      engine.undoLastDelivery();
      final dot = engine.recordDelivery(
        eventId: 'dot',
        scorerDeviceId: 'dev1',
      );

      expect(engine.state.activeInnings.totalRuns, equals(0));
      expect(dot.ballReference, equals('1.1'));
      expect(engine.state.events.map((event) => event.displayLabel), ['0']);
    });

    test('manual extras scenario preserves labels, totals, and legal balls',
        () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'manual-a',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(eventId: 'e1', scorerDeviceId: 'dev');
      engine.recordDelivery(
          eventId: 'e2', scorerDeviceId: 'dev', runsBatter: 1);
      engine.recordDelivery(
        eventId: 'e3',
        scorerDeviceId: 'dev',
        extrasType: ExtrasType.wide,
        wideRuns: 1,
      );
      engine.recordDelivery(
        eventId: 'e4',
        scorerDeviceId: 'dev',
        extrasType: ExtrasType.noBall,
        noBallRuns: 1,
      );
      engine.recordDelivery(
        eventId: 'e5',
        scorerDeviceId: 'dev',
        extrasType: ExtrasType.noBall,
        noBallRuns: 1,
        runsBatter: 4,
      );
      engine.recordDelivery(
        eventId: 'e6',
        scorerDeviceId: 'dev',
        extrasType: ExtrasType.bye,
        byeRuns: 1,
      );
      engine.recordDelivery(
        eventId: 'e7',
        scorerDeviceId: 'dev',
        extrasType: ExtrasType.legBye,
        legByeRuns: 2,
      );

      expect(
        engine.state.events.map((event) => event.displayLabel),
        ['0', '1', 'Wd', 'Nb', 'Nb+4', 'B1', 'LB2'],
      );
      expect(engine.state.activeInnings.totalRuns, 11);
      expect(engine.state.activeInnings.legalBallsBowled, 4);
      expect(engine.getBowlerScorecards(teamB).first.runsConceded, 8);
    });
  });

  group('CricketScoringEngine - Wickets & Over Completion', () {
    test(
        'Bowled wicket updates wickets count and replaces striker with new batter',
        () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        wicket: const WicketDetail(
          type: WicketType.bowled,
          dismissedPlayerId: 'p1',
        ),
        newBatterId: 'p3',
      );

      expect(engine.state.activeInnings.totalWickets, equals(1));
      expect(engine.state.activeInnings.strikerId, equals('p3'));
      expect(engine.state.activeInnings.nonStrikerId, equals('p2'));
    });

    test('End of over rotates strike automatically', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      // Bowl 6 dots
      for (int i = 1; i <= 6; i++) {
        engine.recordDelivery(
          eventId: 'e$i',
          scorerDeviceId: 'dev1',
          runsBatter: 0,
        );
      }

      expect(engine.state.activeInnings.legalBallsBowled, equals(6));
      expect(engine.state.activeInnings.oversFormatted, equals('1.0'));
      // Strike should rotate at end of over from p1 to p2
      expect(engine.state.activeInnings.strikerId, equals('p2'));
      expect(engine.state.activeInnings.nonStrikerId, equals('p1'));
      expect(engine.state.activeInnings.currentBowlerId, isNull);
      expect(engine.state.activeInnings.flowState,
          InningsFlowState.awaitingNextBowler);
      engine.selectNextBowler('p7');
      expect(engine.state.activeInnings.currentBowlerId, equals('p7'));
    });

    test('Undo last delivery restores score and state', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );

      engine.recordDelivery(
        eventId: 'e1',
        scorerDeviceId: 'dev1',
        runsBatter: 6,
        isBoundarySix: true,
      );

      expect(engine.state.activeInnings.totalRuns, equals(6));

      engine.undoLastDelivery();

      expect(engine.state.activeInnings.totalRuns, equals(0));
      expect(engine.state.activeInnings.legalBallsBowled, equals(0));
      expect(engine.state.events, isEmpty);
    });

    test('Complete match state round-trips with categorized delivery data', () {
      final engine = CricketScoringEngine.createMatch(
        matchId: 'm1',
        config: config,
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: teamA.id,
        tossDecision: 'BAT',
        openingStrikerId: 'p1',
        openingNonStrikerId: 'p2',
        openingBowlerId: 'p6',
      );
      engine.recordDelivery(
        eventId: 'nb4',
        scorerDeviceId: 'dev1',
        extrasType: ExtrasType.noBall,
        noBallRuns: 1,
        runsBatter: 4,
      );

      final restored = MatchState.fromJson(engine.state.toJson());

      expect(restored.matchId, equals('m1'));
      expect(restored.events.single.displayLabel, equals('Nb+4'));
      expect(restored.events.single.sequenceInOver, equals(1));
      expect(restored.activeInnings.totalRuns, equals(5));
    });
  });
}
