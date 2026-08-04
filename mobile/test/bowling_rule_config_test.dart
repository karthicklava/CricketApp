import 'package:cricket_scorer/core/rules/bowling_rule_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('maximum overs per bowler suggestion', () {
    for (final example
        in {3: 1, 5: 1, 6: 2, 10: 2, 12: 3, 20: 4, 50: 10}.entries) {
      test('${example.key} overs suggests ${example.value}', () {
        expect(BowlingRuleConfig.suggestOfficialMaxOversPerBowler(example.key),
            example.value);
      });
    }
  });

  test('an automatic value follows total overs', () {
    const config = BowlingRuleConfig(
      totalOvers: 10,
      maxOversPerBowler: 2,
      wasManuallyEdited: false,
      allowConsecutiveOvers: false,
    );
    expect(config.withTotalOvers(20).maxOversPerBowler, 4);
  });

  test('a valid manual value is preserved', () {
    const config = BowlingRuleConfig(
      totalOvers: 10,
      maxOversPerBowler: 3,
      wasManuallyEdited: true,
      allowConsecutiveOvers: true,
    );
    final updated = config.withTotalOvers(12);
    expect(updated.maxOversPerBowler, 3);
    expect(updated.wasManuallyEdited, isTrue);
    expect(updated.allowConsecutiveOvers, isTrue);
  });

  test('an invalid manual value is replaced with a suggestion', () {
    const config = BowlingRuleConfig(
      totalOvers: 10,
      maxOversPerBowler: 3,
      wasManuallyEdited: true,
      allowConsecutiveOvers: false,
    );
    final updated = config.withTotalOvers(2);
    expect(updated.maxOversPerBowler, 1);
    expect(updated.wasManuallyEdited, isFalse);
  });
}
