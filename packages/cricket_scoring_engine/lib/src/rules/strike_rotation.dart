import '../models/delivery_event.dart';

class StrikeRotationRule {
  /// Calculates striker and non-striker positions after a delivery.
  static ({String strikerId, String nonStrikerId}) calculatePositions({
    required String currentStrikerId,
    required String currentNonStrikerId,
    required DeliveryEvent event,
    required bool isEndOfOver,
    String? newBatterId,
  }) {
    String striker = currentStrikerId;
    String nonStriker = currentNonStrikerId;

    // 1. Determine runs that count towards physically running between wickets
    final runningRuns = event.completedRunsForStrike;

    // Boundary runs (4 or 6) do NOT switch strike unless odd (e.g. 5 overthrows)
    bool shouldRotateForRuns = (runningRuns % 2 != 0);

    // Handle wicket scenario
    if (event.wicket != null) {
      final dismissedId = event.wicket!.dismissedPlayerId;
      final runsBeforeWicket = event.wicket!.runsCompletedBeforeDismissal;
      final crossed = event.wicket!.crossed;

      bool runsRotated = (runsBeforeWicket % 2 != 0);
      bool finalRotation = runsRotated ^ crossed;

      if (dismissedId == striker) {
        // Striker dismissed
        if (newBatterId != null) {
          if (finalRotation) {
            // New batter goes to non-striker, survivor goes to striker
            striker = nonStriker;
            nonStriker = newBatterId;
          } else {
            // New batter takes striker
            striker = newBatterId;
          }
        }
      } else if (dismissedId == nonStriker) {
        // Non-striker dismissed (e.g., Run out at bowler end)
        if (newBatterId != null) {
          if (finalRotation) {
            // Survivor goes to non-striker, new batter takes striker
            nonStriker = striker;
            striker = newBatterId;
          } else {
            // New batter takes non-striker
            nonStriker = newBatterId;
          }
        }
      }
    } else {
      // Normal delivery without wicket
      if (shouldRotateForRuns) {
        final temp = striker;
        striker = nonStriker;
        nonStriker = temp;
      }
    }

    // End of over rotation
    if (isEndOfOver && event.isLegal) {
      final temp = striker;
      striker = nonStriker;
      nonStriker = temp;
    }

    return (strikerId: striker, nonStrikerId: nonStriker);
  }
}
