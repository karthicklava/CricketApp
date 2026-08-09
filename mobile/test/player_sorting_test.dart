import 'package:cricket_scorer/core/utils/player_sorting.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class _RosterPlayer {
  const _RosterPlayer(this.id, this.name, this.jersey);

  final String id;
  final String name;
  final String? jersey;
}

void main() {
  group('player selection sorting', () {
    test('sorts names A-Z without mutating the source list', () {
      final source = [
        const Player(id: '5', name: 'Vishnu'),
        const Player(id: '2', name: ' Karthick '),
        const Player(id: '3', name: 'Bala'),
        const Player(id: '1', name: 'arun'),
        const Player(id: '4', name: 'Ragu'),
      ];

      final sorted = sortPlayersByName(source);

      expect(sorted.map((player) => player.name.trim()),
          ['arun', 'Bala', 'Karthick', 'Ragu', 'Vishnu']);
      expect(source.first.name, 'Vishnu');
    });

    test('uses jersey number and ID as deterministic duplicate fallbacks', () {
      final sorted = sortPlayerItemsByName(
        const [
          _RosterPlayer('z', 'Ragu', '18'),
          _RosterPlayer('b', ' ragu ', '7'),
          _RosterPlayer('a', 'RAGU', '7'),
          _RosterPlayer('x', 'Arun', null),
        ],
        nameOf: (player) => player.name,
        idOf: (player) => player.id,
        jerseyNumberOf: (player) => player.jersey,
      );

      expect(sorted.map((player) => player.id), ['x', 'a', 'b', 'z']);
    });

    test('filtered selection results retain alphabetical order', () {
      final sorted = sortPlayersByName(const [
        Player(id: '3', name: 'Rajendran'),
        Player(id: '1', name: 'Ragu'),
        Player(id: '2', name: 'Raghav'),
        Player(id: '4', name: 'Bala'),
      ]);

      final filtered = sorted
          .where((player) => player.name.toLowerCase().contains('ra'))
          .map((player) => player.name);

      expect(filtered, ['Raghav', 'Ragu', 'Rajendran']);
    });
  });
}
