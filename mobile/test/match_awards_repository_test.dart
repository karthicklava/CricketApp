import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/completed_scorecard_repository.dart';
import 'package:cricket_scorer/data/repositories/match_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late MatchRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(database);
    await database.createMatch(MatchesTableCompanion.insert(
      id: 'awards',
      teamAId: 'a',
      teamBId: 'b',
      scheduledAt: 1,
      currentScorerDeviceId: 'test',
      createdAt: 1,
    ));
  });

  tearDown(() => database.close());

  CricketScoringEngine completedEngine() {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'awards',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
        maxWickets: 1,
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
        players: [
          Player(id: 'b1', name: 'B One'),
          Player(id: 'b2', name: 'B Two'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(
      eventId: 'first',
      scorerDeviceId: 'test',
      runsBatter: 4,
      wicket: const WicketDetail(
        type: WicketType.caught,
        dismissedPlayerId: 'a1',
      ),
    );
    engine.confirmInningsEnd();
    engine.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    engine.recordDelivery(
      eventId: 'second',
      scorerDeviceId: 'test',
      runsBatter: 5,
    );
    engine.confirmMatchEnd();
    return engine;
  }

  test('completed state persists one award of each type and restores them',
      () async {
    final engine = completedEngine();
    await repository.persistState(engine.state);

    final awards = await repository.loadMatchAwards('awards');
    expect(awards, hasLength(2));
    expect(
      awards.map((award) => award.type).toSet(),
      {MatchAwardType.bestBatter, MatchAwardType.bestBowler},
    );
    final loaded =
        await CompletedScorecardRepository(repository).loadCompletedScorecard(
      'awards',
    );
    expect(loaded.bestBatter, isNotNull);
    expect(loaded.bestBowler, isNotNull);
    expect(loaded.matchState.awards, hasLength(2));
    expect(await database.getPendingSyncItems(), hasLength(2));
  });

  test('recalculation replaces awards without duplicate rows', () async {
    final engine = completedEngine();
    await repository.persistState(engine.state);
    await repository.recalculateMatchAwards('awards');
    await repository.recalculateMatchAwards('awards');

    expect(await repository.loadMatchAwards('awards'), hasLength(2));
  });

  test('stored player and team names remain historical snapshots', () async {
    final engine = completedEngine();
    await repository.persistState(engine.state);
    final before = await repository.loadMatchAwards('awards');

    expect(before.first.playerNameSnapshot, isNotEmpty);
    expect(before.first.teamNameSnapshot, isNotEmpty);
  });
}
