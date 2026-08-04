import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/data/local/database.dart';
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
      id: 'm',
      teamAId: 'a',
      teamBId: 'b',
      scheduledAt: 1,
      currentScorerDeviceId: 'device',
      createdAt: 1,
    ));
  });

  tearDown(() => database.close());

  test('late squad membership, snapshot, audit and sync persist together',
      () async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'm',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: const Team(
        id: 'a',
        name: 'A',
        shortName: 'A',
        players: [
          Player(id: 'a1', name: 'A1'),
          Player(id: 'a2', name: 'A2'),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'B',
        shortName: 'B',
        players: [Player(id: 'b1', name: 'B1')],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    const player = Player(
      id: 'late',
      name: 'Ravi',
      isLateAddition: true,
      joinedAt: 10,
      joinedInningsId: 'm_inn_1',
      joinedOverNumber: 0,
      joinedDeliverySequence: 1,
    );
    engine.addLatePlayer(teamId: 'a', player: player);
    await repository.persistLatePlayer(
      state: engine.state,
      teamId: 'a',
      player: player,
      mode: LatePlayerAddMode.currentMatchOnly,
      addedBy: 'device',
    );

    expect(await repository.getLiveSquadChanges('m'), hasLength(1));
    expect((await repository.getMatchState('m'))!.teamA.players.last.name,
        'Ravi');
    expect(await database.getPendingSyncItems(), hasLength(1));
  });

  test('database uniqueness prevents duplicate squad identity', () async {
    final member = MatchSquadMembersTableCompanion.insert(
      id: 'one',
      matchId: 'm',
      teamId: 'a',
      playerId: 'late',
      playerNameSnapshot: 'Ravi',
      joinedAt: 1,
    );
    await database.into(database.matchSquadMembersTable).insert(member);
    await expectLater(
      database.into(database.matchSquadMembersTable).insert(member),
      throwsA(anything),
    );
  });
}
