import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

Team _team(String id, int count) => Team(
      id: id,
      name: 'Team $id',
      shortName: id.toUpperCase(),
      players: List.generate(
        count,
        (index) => Player(id: '${id}p$index', name: '$id player $index'),
      ),
    );

CricketScoringEngine _engine({int teamACount = 3, int teamBCount = 3}) =>
    CricketScoringEngine.createMatch(
      matchId: 'match',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 5,
        maxOversPerBowler: 5,
        // Deliberately wrong legacy value: innings must use its squad snapshot.
        maxWickets: 10,
      ),
      teamA: _team('a', teamACount),
      teamB: _team('b', teamBCount),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'ap0',
      openingNonStrikerId: 'ap1',
      openingBowlerId: 'bp0',
    );

WicketDetail _wicket(String playerId, WicketType type) => WicketDetail(
      type: type,
      dismissedPlayerId: playerId,
    );

void _dismiss(
  CricketScoringEngine engine,
  String eventId,
  String playerId, {
  String? newBatterId,
  int runs = 0,
  WicketType type = WicketType.bowled,
}) {
  engine.recordDelivery(
    eventId: eventId,
    scorerDeviceId: 'test',
    runsBatter: runs,
    wicket: _wicket(playerId, type),
    newBatterId: newBatterId,
  );
}

void main() {
  group('dynamic wicket limit', () {
    for (final entry in {11: 10, 5: 4, 3: 2, 2: 1}.entries) {
      test('${entry.key} players allow ${entry.value} wickets', () {
        expect(
          InningsCompletionEvaluator.calculateMaximumWickets(
            playingMemberCount: entry.key,
          ),
          entry.value,
        );
      });
    }

    test('selected match squad overrides the legacy configured ten wickets',
        () {
      final engine = _engine();
      expect(engine.state.activeInnings.playingMemberCountSnapshot, 3);
      expect(engine.state.activeInnings.maximumWickets, 2);

      _dismiss(engine, 'w1', 'ap0', newBatterId: 'ap2');
      expect(engine.state.activeInnings.isCompleted, isFalse);
      _dismiss(engine, 'w2', 'ap1');

      expect(engine.state.activeInnings.totalWickets, 2);
      expect(engine.state.activeInnings.isCompleted, isTrue);
      expect(engine.state.activeInnings.completionReason, 'All Out');
      expect(engine.state.status, MatchStatus.inningsBreak);
      expect(
        () => engine.recordDelivery(eventId: 'illegal', scorerDeviceId: 'test'),
        throwsStateError,
      );
    });

    test('retired hurt does not consume a team wicket', () {
      final engine = _engine();
      _dismiss(
        engine,
        'rh',
        'ap0',
        newBatterId: 'ap2',
        type: WicketType.retiredHurt,
      );
      expect(engine.state.activeInnings.totalWickets, 0);
      expect(engine.state.activeInnings.isCompleted, isFalse);
    });

    test('approved late batter increases the active innings wicket limit', () {
      final engine = _engine();
      engine.addLatePlayer(
        teamId: 'a',
        player: const Player(id: 'ap3', name: 'Late batter'),
      );
      expect(engine.state.activeInnings.playingMemberCountSnapshot, 4);
      expect(engine.state.activeInnings.maximumWickets, 3);
    });
  });

  group('second innings results', () {
    CricketScoringEngine firstInningsFor20() {
      final engine = _engine();
      _dismiss(engine, 'a1', 'ap0', newBatterId: 'ap2', runs: 20);
      _dismiss(engine, 'a2', 'ap1');
      engine.startSecondInnings(
        openingStrikerId: 'bp0',
        openingNonStrikerId: 'bp1',
        openingBowlerId: 'ap0',
      );
      return engine;
    }

    test('all out below target awards defending team correct run margin', () {
      final engine = firstInningsFor20();
      _dismiss(engine, 'b1', 'bp0', newBatterId: 'bp2', runs: 15);
      _dismiss(engine, 'b2', 'bp1');

      expect(engine.state.status, MatchStatus.completed);
      expect(engine.state.result!.winnerTeamId, 'a');
      expect(engine.state.result!.winByRuns, 5);
      expect(engine.state.result!.resultString, 'Team a won by 5 runs');
    });

    test('successful chase uses dynamic wicket margin', () {
      final engine = firstInningsFor20();
      _dismiss(engine, 'b1', 'bp0', newBatterId: 'bp2');
      engine.recordDelivery(
        eventId: 'target',
        scorerDeviceId: 'test',
        runsBatter: 21,
      );

      expect(engine.state.status, MatchStatus.completed);
      expect(engine.state.result!.winByWickets, 1);
      expect(engine.state.result!.resultString, 'Team b won by 1 wicket');
    });

    test('a Wide reaching the target completes the chase immediately', () {
      final engine = firstInningsFor20();
      engine.recordDelivery(
        eventId: 'twenty',
        scorerDeviceId: 'test',
        runsBatter: 20,
      );
      final winningWide = engine.recordDelivery(
        eventId: 'winning-wide',
        scorerDeviceId: 'test',
        extrasType: ExtrasType.wide,
        wideRuns: 1,
      );

      expect(winningWide.isLegal, isFalse);
      expect(winningWide.displayLabel, 'Wd');
      expect(engine.state.activeInnings.totalRuns, 21);
      expect(engine.state.activeInnings.legalBallsBowled, 1);
      expect(engine.state.status, MatchStatus.completed);
      expect(engine.state.result!.winnerTeamId, 'b');

      engine.undoLastDelivery();
      expect(engine.state.status, MatchStatus.live);
      expect(engine.state.activeInnings.totalRuns, 20);
      expect(engine.state.activeInnings.legalBallsBowled, 1);
      expect(engine.state.events.last.eventId, 'twenty');
    });

    test('equal scores at all out produce a tie', () {
      final engine = firstInningsFor20();
      _dismiss(engine, 'b1', 'bp0', newBatterId: 'bp2', runs: 20);
      _dismiss(engine, 'b2', 'bp1');
      expect(engine.state.result!.isTie, isTrue);
      expect(engine.state.result!.resultString, 'Match Tied');
    });

    test('undo final wicket reopens innings and reapplying completes it', () {
      final engine = firstInningsFor20();
      _dismiss(engine, 'b1', 'bp0', newBatterId: 'bp2', runs: 15);
      _dismiss(engine, 'b2', 'bp1');
      expect(engine.state.status, MatchStatus.completed);

      engine.undoLastDelivery();
      expect(engine.state.status, MatchStatus.live);
      expect(engine.state.activeInnings.isCompleted, isFalse);
      expect(engine.state.activeInnings.totalWickets, 1);

      _dismiss(engine, 'b2-again', 'bp1');
      expect(engine.state.status, MatchStatus.completed);
      expect(engine.state.result!.winByRuns, 5);
    });

    test('serialized restart preserves completion and rejects scoring', () {
      final engine = firstInningsFor20();
      _dismiss(engine, 'b1', 'bp0', newBatterId: 'bp2', runs: 15);
      _dismiss(engine, 'b2', 'bp1');

      final resumed = CricketScoringEngine(
        MatchState.fromJson(engine.state.toJson()),
      );
      expect(resumed.state.status, MatchStatus.completed);
      expect(resumed.state.activeInnings.completionReason, 'All Out');
      expect(resumed.state.activeInnings.maximumWickets, 2);
      expect(
        () => resumed.recordDelivery(
          eventId: 'after-restart',
          scorerDeviceId: 'test',
        ),
        throwsStateError,
      );
    });
  });
}
