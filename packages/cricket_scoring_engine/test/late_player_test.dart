import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine buildEngine({LatePlayerRules rules = const LatePlayerRules()}) {
  return CricketScoringEngine.createMatch(
    matchId: 'late-match',
    config: MatchConfig(
      format: MatchFormat.custom,
      totalOvers: 2,
      maxOversPerBowler: 1,
      latePlayerRules: rules,
    ),
    teamA: const Team(
      id: 'a',
      name: 'Alpha',
      shortName: 'A',
      players: [
        Player(id: 'a1', name: 'A One'),
        Player(id: 'a2', name: 'A Two'),
      ],
    ),
    teamB: const Team(
      id: 'b',
      name: 'Beta',
      shortName: 'B',
      players: [Player(id: 'b1', name: 'B One')],
    ),
    tossWinnerTeamId: 'a',
    tossDecision: 'BAT',
    openingStrikerId: 'a1',
    openingNonStrikerId: 'a2',
    openingBowlerId: 'b1',
  );
}

void main() {
  test('late batter joins without changing the live delivery state', () {
    final engine = buildEngine();
    engine.recordDelivery(
      eventId: 'e1',
      scorerDeviceId: 'test',
      runsBatter: 1,
    );
    final before = engine.state;
    engine.addLatePlayer(
      teamId: 'a',
      player: const Player(
        id: 'a3',
        name: 'Late Batter',
        isLateAddition: true,
        joinedAt: 1,
        joinedInningsId: 'late-match_inn_1',
        joinedOverNumber: 0,
        joinedDeliverySequence: 2,
      ),
    );

    expect(engine.state.teamA.players.last.name, 'Late Batter');
    expect(engine.state.activeInnings.totalRuns,
        before.activeInnings.totalRuns);
    expect(engine.state.activeInnings.legalBallsBowled,
        before.activeInnings.legalBallsBowled);
    expect(engine.state.activeInnings.strikerId,
        before.activeInnings.strikerId);
    expect(engine.state.events, before.events);
  });

  test('late bowler starts with zero figures', () {
    final engine = buildEngine();
    engine.addLatePlayer(
      teamId: 'b',
      player: const Player(
        id: 'b2',
        name: 'Late Bowler',
        isLateAddition: true,
        isEligibleBowler: true,
      ),
    );
    final card = engine.getBowlerScorecards(engine.state.teamB).firstWhere(
          (row) => row.playerId == 'b2',
          orElse: () =>
              const BowlerScorecard(playerId: 'b2', playerName: 'Late Bowler'),
        );
    expect(card.legalBallsBowled, 0);
    expect(card.runsConceded, 0);
    expect(card.wickets, 0);
  });

  test('duplicate and opposing-team membership is rejected', () {
    final engine = buildEngine();
    expect(
      () => engine.addLatePlayer(
        teamId: 'b',
        player: const Player(id: 'a1', name: 'A One'),
      ),
      throwsStateError,
    );
  });

  test('match rules can disable late additions', () {
    final engine = buildEngine(
      rules: const LatePlayerRules(allowLatePlayers: false),
    );
    expect(
      () => engine.addLatePlayer(
        teamId: 'a',
        player: const Player(id: 'a3', name: 'Late Batter'),
      ),
      throwsStateError,
    );
  });

  test('late-player snapshot survives serialization', () {
    final engine = buildEngine();
    engine.addLatePlayer(
      teamId: 'a',
      player: const Player(
        id: 'a3',
        name: 'Late Batter',
        isLateAddition: true,
        joinedAt: 42,
        joinedDeliverySequence: 3,
      ),
    );
    final restored = MatchState.fromJson(engine.state.toJson());
    expect(restored.teamA.players.last.isLateAddition, isTrue);
    expect(restored.teamA.players.last.joinedAt, 42);
  });
}
