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

  test('team selection uses neutral labels before the toss', () {
    expect(source, contains("const Text('Select Team A'"));
    expect(source, contains("const Text('Select Team B'"));
    expect(source, isNot(contains('Batting/Bowling')));
    expect(source, isNot(contains('Select Team B (Opponent)')));
  });

  test('draft membership and match roles are persisted and cleared safely', () {
    expect(source, contains("'teamASquad': _selectedASquad.toList()"));
    expect(source, contains("'teamBSquad': _selectedBSquad.toList()"));
    expect(source, contains('_teamACaptainId = null'));
    expect(source, contains('_teamAWicketkeeperId = null'));
    expect(source, contains('_eligibleABowlers : _eligibleBBowlers'));
  });

  test('review step summarizes setup and gates Start Match on readiness', () {
    expect(source, contains("ValueKey('premium-match-review')"));
    expect(source, contains("ValueKey('review-match-banner')"));
    expect(source, contains("ValueKey('review-match-summary')"));
    expect(source, contains("ValueKey('review-squads')"));
    expect(source, contains("ValueKey('review-match-rules')"));
    expect(source, contains("ValueKey('review-ready-status')"));
    expect(source, contains('ExpansionTile('));
    expect(source, contains('_currentStep == 5 && !_reviewIsReady'));
    expect(source, isNot(contains('Ready to begin live scoring session!')));
  });
}
