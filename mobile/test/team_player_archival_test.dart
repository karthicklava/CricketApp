import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/team_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late TeamRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TeamRepository(database);
    await database.createTeam(TeamsTableCompanion.insert(
      id: 'team',
      name: 'Team A',
      shortName: 'TA',
      createdAt: 1,
    ));
  });

  tearDown(() => database.close());

  test('remove from team archives relationship and preserves player record',
      () async {
    final playerId = await repository.addPlayerToTeam(
      teamId: 'team',
      name: 'Karthick',
      role: 'allRounder',
      battingStyle: 'rightHand',
      bowlingStyle: 'rightArmFast',
      isCaptain: true,
    );

    await repository.removePlayerFromTeam('team', playerId);

    expect(await repository.getTeamPlayers('team'), isEmpty);
    expect(
        (await repository.getRemovedTeamPlayers('team')).single.id, playerId);
    expect(await database.getTeamById('team'), isNotNull);
  });

  test('restore reactivates existing identity without duplication', () async {
    final playerId = await repository.addPlayerToTeam(
      teamId: 'team',
      name: 'Karthick',
      role: 'allRounder',
      battingStyle: 'rightHand',
      bowlingStyle: 'rightArmFast',
    );
    await repository.removePlayerFromTeam('team', playerId);
    await repository.restorePlayerToTeam('team', playerId);

    final active = await repository.getTeamPlayers('team');
    expect(active, hasLength(1));
    expect(active.single.id, playerId);
    expect(await repository.getRemovedTeamPlayers('team'), isEmpty);
  });
}
