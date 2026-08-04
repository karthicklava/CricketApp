import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

void main() {
  group('dynamic bowling rules', () {
    test('local automatic suggestion scales with overs and bowlers', () {
      expect(
          BowlingRules.suggestedMaxOvers(totalOvers: 3, eligibleBowlerCount: 3),
          1);
      expect(
          BowlingRules.suggestedMaxOvers(totalOvers: 5, eligibleBowlerCount: 3),
          2);
      expect(
          BowlingRules.suggestedMaxOvers(totalOvers: 5, eligibleBowlerCount: 2),
          3);
      expect(
          BowlingRules.suggestedMaxOvers(
              totalOvers: 10, eligibleBowlerCount: 5),
          2);
    });

    test('impossible equal capacity is rejected with correction', () {
      final result = BowlingRules.validate(
        totalOvers: 5,
        eligibleBowlerCount: 3,
        mode: BowlerLimitMode.customEqualLimit,
        equalMaxOvers: 1,
        allowConsecutiveOvers: false,
      );
      expect(result.isValid, isFalse);
      expect(result.capacityOvers, 3);
      expect(result.suggestedMaxOvers, 2);
    });

    test('one bowler requires consecutive overs for multi-over innings', () {
      final result = BowlingRules.validate(
        totalOvers: 5,
        eligibleBowlerCount: 1,
        mode: BowlerLimitMode.localAutomatic,
        equalMaxOvers: 5,
        allowConsecutiveOvers: false,
      );
      expect(result.isValid, isFalse);
      expect(result.message, contains('At least two'));
    });

    test('custom balls per over and per-player limits use legal balls', () {
      const config = MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 4,
        ballsPerOver: 5,
        maxOversPerBowler: 2,
        bowlerLimitMode: BowlerLimitMode.customPerBowler,
        perBowlerMaxOvers: {'p1': 2},
      );
      expect(config.maximumLegalBallsFor('p1'), 10);
      expect(
          BowlingRules.hasReachedBowlingLimit(
              legalBallsBowled: 9, maximumLegalBalls: 10),
          isFalse);
      expect(
          BowlingRules.hasReachedBowlingLimit(
              legalBallsBowled: 10, maximumLegalBalls: 10),
          isTrue);
    });

    test('unlimited mode has no legal-ball ceiling', () {
      const config = MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 5,
        maxOversPerBowler: 1,
        bowlerLimitMode: BowlerLimitMode.unlimited,
      );
      expect(config.maximumLegalBallsFor('p1'), isNull);
    });

    test('persisted configuration restores limits and consecutive rule', () {
      final original = MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 5,
        maxOversPerBowler: 2,
        bowlerLimitMode: BowlerLimitMode.customPerBowler,
        eligibleBowlerIds: const ['p1', 'p2'],
        perBowlerMaximumLegalBalls: const {'p1': 12, 'p2': 6},
        allowConsecutiveOvers: true,
        bowlingRulesConfirmedAt: 123,
      );
      final restored = MatchConfig.fromJson(original.toJson());
      expect(restored.bowlerLimitMode, BowlerLimitMode.customPerBowler);
      expect(restored.maximumLegalBallsFor('p1'), 12);
      expect(restored.maximumLegalBallsFor('p2'), 6);
      expect(restored.allowConsecutiveOvers, isTrue);
      expect(restored.bowlingRulesConfirmedAt, 123);
    });
  });
}
