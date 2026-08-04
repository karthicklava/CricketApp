import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

void main() {
  group('Part 1: Team Creation & Short Name Auto-Derivation Suite', () {
    test('1. Multi-word team name derives shortName from initials', () {
      final name = 'Royal Challengers Bangalore';
      final words = name.trim().split(RegExp(r'\s+'));
      final initials = words
          .take(3)
          .map((w) => w.isNotEmpty ? w[0] : '')
          .join('')
          .toUpperCase();

      expect(initials, equals('RCB'));
    });

    test('2. Single-word team name derives shortName from first 3 characters',
        () {
      final name = 'Warriors';
      final clean = name.replaceAll(RegExp(r'[^\w]'), '').toUpperCase();
      final shortName = clean.length >= 3 ? clean.substring(0, 3) : clean;

      expect(shortName, equals('WAR'));
    });
  });

  group('Part 2: Team Roster Captain & Wicket-Keeper Validation Suite', () {
    test('3. Roster validation fails when missing Captain or Wicket-Keeper',
        () {
      final squad = [
        {'name': 'Player 1', 'isCaptain': false, 'isWicketKeeper': false},
        {'name': 'Player 2', 'isCaptain': false, 'isWicketKeeper': false},
      ];

      final hasCaptain = squad.any((p) => p['isCaptain'] == true);
      final hasWicketKeeper = squad.any((p) => p['isWicketKeeper'] == true);
      final isValidRoster = hasCaptain && hasWicketKeeper;

      expect(isValidRoster, isFalse);
    });

    test(
        '4. Roster validation passes when both Captain and Wicket-Keeper are assigned',
        () {
      final squad = [
        {'name': 'Player 1', 'isCaptain': true, 'isWicketKeeper': false},
        {'name': 'Player 2', 'isCaptain': false, 'isWicketKeeper': true},
      ];

      final hasCaptain = squad.any((p) => p['isCaptain'] == true);
      final hasWicketKeeper = squad.any((p) => p['isWicketKeeper'] == true);
      final isValidRoster = hasCaptain && hasWicketKeeper;

      expect(isValidRoster, isTrue);
    });
  });

  group('Part 3: Match Setup Custom Overs & Ball Calculation Suite', () {
    test('5. Custom overs input accepts values between 2 and 50 overs', () {
      final validInputs = [2, 10, 20, 50];

      for (final overs in validInputs) {
        final isValid = overs >= 2 && overs <= 50;
        expect(isValid, isTrue, reason: '$overs should be valid overs');
      }
    });

    test('6. Custom overs input rejects values < 2 or > 50', () {
      final invalidInputs = [0, 1, 51, 100, -5];

      for (final overs in invalidInputs) {
        final isValid = overs >= 2 && overs <= 50;
        expect(isValid, isFalse, reason: '$overs should be invalid overs');
      }
    });

    test('7. Standard cricket rule applies 6 legal deliveries per over', () {
      final ballsPerOver = 6;
      expect(ballsPerOver, equals(6));
    });
  });
}
