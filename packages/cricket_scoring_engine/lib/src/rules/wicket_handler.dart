import '../models/delivery_event.dart';

class WicketHandler {
  static bool countsAsTeamWicket(WicketType type) =>
      type != WicketType.retiredHurt &&
      type != WicketType.retiredNotOut &&
      type != WicketType.absentHurt;

  /// Validates dismissal type compatibility with delivery properties.
  static void validateWicket({
    required WicketType type,
    required ExtrasType extrasType,
    required bool isFreeHit,
  }) {
    if (isFreeHit) {
      // On a free hit, a batter can only be dismissed run out, hit ball twice, or obstructing field
      if (type != WicketType.runOut &&
          type != WicketType.hitBallTwice &&
          type != WicketType.obstructingField &&
          type != WicketType.retiredHurt &&
          type != WicketType.retiredOut) {
        throw ArgumentError(
          'On a free hit, batter cannot be dismissed by $type. Only Run Out / Obstructing Field allowed.',
        );
      }
    }

    if (extrasType == ExtrasType.wide) {
      // On a wide, batter cannot be bowled, lbw, or caught
      if (type == WicketType.bowled ||
          type == WicketType.lbw ||
          type == WicketType.caught) {
        throw ArgumentError('Batter cannot be $type on a Wide ball.');
      }
    }
  }

  /// Formats human-readable dismissal summary string.
  static String formatDismissal({
    required WicketType type,
    required String bowlerName,
    String? fielderName,
  }) {
    switch (type) {
      case WicketType.bowled:
        return 'b $bowlerName';
      case WicketType.caught:
        return fielderName != null
            ? 'c $fielderName b $bowlerName'
            : 'c & b $bowlerName';
      case WicketType.lbw:
        return 'lbw b $bowlerName';
      case WicketType.stumped:
        return fielderName != null
            ? 'st $fielderName b $bowlerName'
            : 'st b $bowlerName';
      case WicketType.runOut:
        return fielderName != null ? 'run out ($fielderName)' : 'run out';
      case WicketType.hitWicket:
        return 'hit wicket b $bowlerName';
      case WicketType.retiredHurt:
        return 'retired hurt';
      case WicketType.retiredOut:
        return 'retired out';
      case WicketType.retiredNotOut:
        return 'retired not out';
      case WicketType.obstructingField:
        return 'obstructing field';
      case WicketType.hitBallTwice:
        return 'hit ball twice';
      case WicketType.timedOut:
        return 'timed out';
      case WicketType.absentHurt:
        return 'absent hurt';
    }
  }
}
