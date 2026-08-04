import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/presentation/teams/add_players_screen.dart',
  ).readAsStringSync();

  test('player bowling picker exposes only Fast and Spinner', () {
    expect(source, contains("label: Text('Fast')"));
    expect(source, contains("label: Text('Spinner')"));
    expect(source, isNot(contains("label: Text('Does Not Bowl')")));
  });

  test('roster jersey input is numeric and limited to three digits', () {
    expect(source, contains('FilteringTextInputFormatter.digitsOnly'));
    expect(source, contains('LengthLimitingTextInputFormatter(3)'));
    expect(source, contains('up to 3 digits'));
  });
}
