import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

void main() {
  group('player batting and bowling styles', () {
    test('formats the supported profile categories', () {
      expect(battingStyleAbbreviation(BattingStyle.rightHand), 'RHB');
      expect(battingStyleAbbreviation(BattingStyle.leftHand), 'LHB');
      expect(bowlingStyleLabel(BowlingStyle.rightArmFast), 'Fast');
      expect(bowlingStyleLabel(BowlingStyle.rightArmSpin), 'Spinner');
      expect(bowlingStyleLabel(BowlingStyle.none), 'Does not bowl');
    });

    test('missing legacy values remain explicitly not set', () {
      final player = Player.fromJson(const {'id': 'p1', 'name': 'Player'});
      expect(player.battingStyle, BattingStyle.notSet);
      expect(player.bowlingStyle, BowlingStyle.notSet);
    });

    test('bowling type and match eligibility remain independent', () {
      const spinner = Player(
        id: 'p1',
        name: 'Spinner',
        battingStyle: BattingStyle.leftHand,
        bowlingStyle: BowlingStyle.offSpin,
        isEligibleBowler: false,
      );
      final restored = Player.fromJson(spinner.toJson());
      expect(restored.bowlingStyle, BowlingStyle.offSpin);
      expect(restored.isEligibleBowler, isFalse);
      expect(playerStyleSummary(restored.battingStyle, restored.bowlingStyle),
          'LHB · Spinner');
    });
  });
}
