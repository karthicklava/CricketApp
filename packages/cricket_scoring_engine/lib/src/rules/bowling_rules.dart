import '../models/match_config.dart';

class BowlingRulesValidation {
  final bool isValid;
  final int capacityOvers;
  final int suggestedMaxOvers;
  final String? message;

  const BowlingRulesValidation({
    required this.isValid,
    required this.capacityOvers,
    required this.suggestedMaxOvers,
    this.message,
  });
}

/// Shared calculations used by match setup and live bowler selection.
class BowlingRules {
  static int suggestedMaxOvers({
    required int totalOvers,
    required int eligibleBowlerCount,
  }) {
    if (eligibleBowlerCount <= 0) {
      throw StateError('At least one eligible bowler is required.');
    }
    return (totalOvers / eligibleBowlerCount).ceil();
  }

  static int maximumLegalBalls({
    required int maxOvers,
    required int ballsPerOver,
  }) =>
      maxOvers * ballsPerOver;

  static bool hasReachedBowlingLimit({
    required int legalBallsBowled,
    required int maximumLegalBalls,
  }) =>
      legalBallsBowled >= maximumLegalBalls;

  static BowlingRulesValidation validate({
    required int totalOvers,
    required int eligibleBowlerCount,
    required BowlerLimitMode mode,
    required int equalMaxOvers,
    required bool allowConsecutiveOvers,
    Map<String, int> perBowlerMaxOvers = const {},
  }) {
    if (eligibleBowlerCount <= 0) {
      return const BowlingRulesValidation(
        isValid: false,
        capacityOvers: 0,
        suggestedMaxOvers: 0,
        message: 'Mark at least one squad member eligible to bowl.',
      );
    }
    final suggested = suggestedMaxOvers(
      totalOvers: totalOvers,
      eligibleBowlerCount: eligibleBowlerCount,
    );
    if (!allowConsecutiveOvers && totalOvers > 1 && eligibleBowlerCount < 2) {
      return BowlingRulesValidation(
        isValid: false,
        capacityOvers:
            mode == BowlerLimitMode.unlimited ? totalOvers : equalMaxOvers,
        suggestedMaxOvers: suggested,
        message:
            'At least two eligible bowlers are required when consecutive overs are not allowed.',
      );
    }
    final capacity = mode == BowlerLimitMode.unlimited
        ? totalOvers
        : mode == BowlerLimitMode.customPerBowler
            ? perBowlerMaxOvers.values.fold<int>(0, (sum, value) => sum + value)
            : eligibleBowlerCount * equalMaxOvers;
    if (capacity < totalOvers) {
      return BowlingRulesValidation(
        isValid: false,
        capacityOvers: capacity,
        suggestedMaxOvers: suggested,
        message:
            'The current bowling limits support only $capacity of $totalOvers overs. Set the maximum to $suggested overs or add eligible bowlers.',
      );
    }
    return BowlingRulesValidation(
      isValid: true,
      capacityOvers: capacity,
      suggestedMaxOvers: suggested,
    );
  }
}
