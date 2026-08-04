import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/presentation/matches/match_setup_wizard.dart',
  ).readAsStringSync();

  test('squad rows expose one shared row and checkbox toggle', () {
    expect(source, contains('Checkbox('));
    expect(source, contains('_toggleSquadPlayer(player, isTeamA: isTeamA)'));
    expect(source, contains('selected.remove(player.id)'));
    expect(source, contains('selected.add(player.id)'));
  });

  test('bulk selection controls are available', () {
    expect(source, contains("const Text('Select All')"));
    expect(source, contains("const Text('Clear Selection')"));
    expect(source, contains('_selectAllSquadPlayers'));
    expect(source, contains('_clearSquadSelection'));
  });

  test('draft membership and match roles are persisted and cleared safely', () {
    expect(source, contains("'teamASquad': _selectedASquad.toList()"));
    expect(source, contains("'teamBSquad': _selectedBSquad.toList()"));
    expect(source, contains('_teamACaptainId = null'));
    expect(source, contains('_teamAWicketkeeperId = null'));
    expect(source, contains('_eligibleABowlers : _eligibleBBowlers'));
  });
}
