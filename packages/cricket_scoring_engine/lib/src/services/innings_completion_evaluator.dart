import '../models/innings_state.dart';
import '../models/match_config.dart';

enum InningsCompletionReason {
  allOut,
  oversCompleted,
  targetReached,
  declared,
  forfeited,
  manuallyEnded,
}

class InningsCompletionResult {
  final bool isCompleted;
  final bool isAllOut;
  final bool targetReached;
  final bool oversCompleted;
  final InningsCompletionReason? reason;

  const InningsCompletionResult({
    required this.isCompleted,
    required this.isAllOut,
    required this.targetReached,
    required this.oversCompleted,
    this.reason,
  });
}

/// The single source of truth for squad-based wicket limits and innings ends.
class InningsCompletionEvaluator {
  const InningsCompletionEvaluator();

  static int calculateMaximumWickets({required int playingMemberCount}) {
    if (playingMemberCount <= 1) return 0;
    return playingMemberCount - 1;
  }

  InningsCompletionResult evaluate({
    required InningsState innings,
    required MatchConfig rules,
    required int battingSquadSize,
    int? target,
  }) {
    if (battingSquadSize < 2) {
      throw StateError(
        'A standard innings requires at least two playing members.',
      );
    }
    final maximumWickets = calculateMaximumWickets(
      playingMemberCount: battingSquadSize,
    );
    final targetReached = target != null && innings.totalRuns >= target;
    final isAllOut = innings.totalWickets >= maximumWickets;
    final oversCompleted =
        innings.legalBallsBowled >= rules.totalOvers * rules.ballsPerOver;

    // A successful chase ends immediately, even if a wicket was recorded on
    // the target-reaching delivery.
    final reason = targetReached
        ? InningsCompletionReason.targetReached
        : isAllOut
            ? InningsCompletionReason.allOut
            : oversCompleted
                ? InningsCompletionReason.oversCompleted
                : null;
    return InningsCompletionResult(
      isCompleted: reason != null,
      isAllOut: isAllOut,
      targetReached: targetReached,
      oversCompleted: oversCompleted,
      reason: reason,
    );
  }
}
