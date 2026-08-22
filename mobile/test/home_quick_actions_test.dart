import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File('lib/main.dart').readAsStringSync();

  test('Home quick actions use meaningful match and team icons', () {
    expect(
        source,
        contains(
            "title: 'Create Match',\n                      icon: Icons.stadium_rounded"));
    expect(
        source,
        contains(
            "title: 'Create Team',\n                      icon: Icons.groups_3_rounded"));
  });

  test('quick actions share one icon container and semantic component', () {
    expect(source, contains('Widget _buildActionCard'));
    expect(source, contains('radius: 20'));
    expect(source, contains('Icon(icon, color: color, size: 22)'));
    expect(source, contains('Semantics('));
    expect(source, contains('label: title'));
  });
}
