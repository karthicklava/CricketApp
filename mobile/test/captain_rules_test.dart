import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/core/rules/captain_rules.dart';
import 'package:cricket_scorer/data/local/database.dart';

void main() {
  group('CaptainRules', () {
    test('selecting a captain clears every previous captain', () {
      final flags = CaptainRules.selectSingleCaptain(
        teamPlayerIds: const ['a', 'b', 'c'],
        selectedCaptainId: 'b',
      );

      expect(flags, {'a': false, 'b': true, 'c': false});
      expect(flags.values.where((selected) => selected), hasLength(1));
    });

    test('captain must belong to the team', () {
      expect(
        () => CaptainRules.selectSingleCaptain(
          teamPlayerIds: const ['a', 'b'],
          selectedCaptainId: 'other',
        ),
        throwsArgumentError,
      );
    });

    test('legacy multiple captains normalize to first valid captain', () {
      final captain = CaptainRules.normalizeLegacyCaptains(
        squadPlayerIds: const ['a', 'b', 'c'],
        captainIds: const ['outside', 'b', 'c'],
      );

      expect(captain, 'b');
    });

    test('match captain must be in selected squad', () {
      expect(
        CaptainRules.isValidMatchCaptain(
          captainId: 'b',
          playingSquadIds: {'a', 'b'},
        ),
        isTrue,
      );
      expect(
        CaptainRules.isValidMatchCaptain(
          captainId: 'c',
          playingSquadIds: {'a', 'b'},
        ),
        isFalse,
      );
      expect(
        CaptainRules.isValidMatchCaptain(
          captainId: null,
          playingSquadIds: {'a', 'b'},
        ),
        isFalse,
      );
    });
  });

  test('default captain change persists exactly one captain in SQLite',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.createTeam(
      TeamsTableCompanion.insert(
        id: 'team',
        name: 'Team',
        shortName: 'TEM',
        createdAt: 1,
      ),
    );
    for (final id in ['a', 'b']) {
      await database.createPlayer(
        PlayersTableCompanion.insert(
          id: id,
          name: 'Player $id',
          createdAt: 1,
        ),
      );
      await database.addPlayerToTeam('team', id);
    }

    await database.setDefaultCaptain('team', 'a');
    await database.setDefaultCaptain('team', 'b');

    final team = await database.getTeamById('team');
    final players = await database.getTeamPlayers('team');
    expect(team!.defaultCaptainId, 'b');
    expect(players.where((player) => player.isCaptain).single.id, 'b');
  });
}
