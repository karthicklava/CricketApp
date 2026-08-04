import '../models/match_config.dart';

class OverCalculator {
  /// Determines if an over is completed based on legal deliveries.
  static bool isOverComplete({
    required int legalBallsInOver,
    required MatchConfig config,
  }) {
    return legalBallsInOver >= config.ballsPerOver;
  }

  /// Validates if a bowler is eligible to bowl the next over.
  static bool canBowlerBowlNextOver({
    required String candidateBowlerId,
    required String? lastBowlerId,
    required int bowlerLegalBallsBowled,
    required MatchConfig config,
    required bool allowConsecutiveOvers,
  }) {
    // 1. Cannot bowl consecutive overs unless explicit rule allows (e.g. street cricket)
    if (!allowConsecutiveOvers && candidateBowlerId == lastBowlerId) {
      return false;
    }

    // 2. Check max overs per bowler limit
    if (!config.isBowlerConfigured(candidateBowlerId)) return false;
    final maximumLegalBalls = config.maximumLegalBallsFor(candidateBowlerId);
    if (maximumLegalBalls != null &&
        bowlerLegalBallsBowled >= maximumLegalBalls) {
      return false;
    }

    return true;
  }
}
