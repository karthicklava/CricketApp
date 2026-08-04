import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/match_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late MatchRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(database);
    await database.createMatch(MatchesTableCompanion.insert(
      id: 'match',
      teamAId: 'a',
      teamBId: 'b',
      scheduledAt: 1,
      status: const Value('live'),
      currentScorerDeviceId: 'device',
      createdAt: 1,
    ));
  });

  tearDown(() => database.close());

  CricketScoringEngine scoring() => CricketScoringEngine.createMatch(
        matchId: 'match',
        config: const MatchConfig(
          format: MatchFormat.custom,
          totalOvers: 2,
          maxOversPerBowler: 2,
        ),
        teamA: const Team(
          id: 'a',
          name: 'Alpha',
          shortName: 'A',
          players: [
            Player(id: 'a1', name: 'A1'),
            Player(id: 'a2', name: 'A2'),
          ],
        ),
        teamB: const Team(
          id: 'b',
          name: 'Beta',
          shortName: 'B',
          players: [
            Player(id: 'b1', name: 'B1'),
            Player(id: 'b2', name: 'B2'),
          ],
        ),
        tossWinnerTeamId: 'a',
        tossDecision: 'BAT',
        openingStrikerId: 'a1',
        openingNonStrikerId: 'a2',
        openingBowlerId: 'b1',
      );

  test('offline abandonment is atomic, historical and releases lock', () async {
    final engine = scoring();
    engine.recordDelivery(
      eventId: 'ball',
      scorerDeviceId: 'device',
      runsBatter: 3,
    );
    engine.endMatchManually(
      outcome: MatchEndOutcome.abandoned,
      reason: MatchEndReason.rain,
      reasonText: 'Rain',
      endedBy: 'device',
    );
    await repository.persistManualEnd(engine.state);

    final record = await database.getMatchById('match');
    expect(record!.status, 'abandoned');
    expect(record.endReasonCode, 'rain');
    expect(await database.hasActiveMatch(), isFalse);
    expect(await database.getRecentMatches(), hasLength(1));
    expect(
        (await repository.getMatchState('match'))!.activeInnings.totalRuns, 3);
    expect(await database.getPendingSyncItems(), hasLength(1));
    final audits = await database.select(database.scoringAuditTable).get();
    expect(audits.single.action, 'MATCH_ENDED_MANUALLY');
  });

  test('duplicate terminal persistence does not duplicate sync event',
      () async {
    final engine = scoring();
    engine.endMatchManually(
      outcome: MatchEndOutcome.noResult,
      reason: MatchEndReason.rain,
      reasonText: 'Rain',
      endedBy: 'device',
    );
    await repository.persistManualEnd(engine.state);
    await repository.persistManualEnd(engine.state);
    expect(await database.getPendingSyncItems(), hasLength(1));
    expect(
        await database.select(database.scoringAuditTable).get(), hasLength(1));
  });
}
