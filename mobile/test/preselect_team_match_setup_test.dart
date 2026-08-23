import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/presentation/matches/match_setup_wizard.dart',
  ).readAsStringSync();

  test('preselectTeamId invokes _selectTeam to load squad players for Team A', () {
    expect(source, contains('if (widget.preselectTeamId != null &&'));
    expect(source, contains('final preselected ='));
    expect(source, contains('await _selectTeam(preselected, isTeamA: true);'));
  });
}
