import '../models/delivery_event.dart';
import '../models/match_config.dart';

class ExtrasHandler {
  /// Evaluates delivery legality, runs attribution, and bowler charges.
  static ({
    bool isLegal,
    int teamExtras,
    int batterRuns,
    int bowlerConcededRuns,
    bool facesBall,
    bool triggersFreeHit,
  }) processExtras({
    required ExtrasType type,
    required int runsBatter,
    required int extrasRuns,
    required MatchConfig config,
    required bool wasPreviousFreeHit,
  }) {
    bool isLegal = true;
    int teamExtras = 0;
    int bRuns = runsBatter;
    int bowlerConceded = 0;
    bool facesBall = true;
    bool triggersFreeHit = false;

    switch (type) {
      case ExtrasType.none:
        isLegal = true;
        teamExtras = 0;
        bowlerConceded = bRuns;
        facesBall = true;
        break;

      case ExtrasType.wide:
        isLegal = !config.reballOnWide;
        teamExtras = config.wideRuns + extrasRuns;
        bRuns = 0; // Batter cannot score off a wide
        bowlerConceded = teamExtras;
        facesBall = false;
        break;

      case ExtrasType.noBall:
        isLegal = !config.reballOnNoBall;
        teamExtras = config.noBallRuns +
            extrasRuns; // extrasRuns if byes/leg-byes off no-ball
        bowlerConceded = config.noBallRuns +
            bRuns; // Bowler charged for no-ball penalty + batter runs
        facesBall = true;
        triggersFreeHit = config.freeHitOnNoBall;
        break;

      case ExtrasType.bye:
        isLegal = true;
        teamExtras = extrasRuns;
        bRuns = 0;
        bowlerConceded = 0; // Byes do not count against bowler's runs
        facesBall = true;
        break;

      case ExtrasType.legBye:
        isLegal = true;
        teamExtras = extrasRuns;
        bRuns = 0;
        bowlerConceded = 0; // Leg byes do not count against bowler's runs
        facesBall = true;
        break;

      case ExtrasType.penalty:
        isLegal = false;
        teamExtras = extrasRuns;
        bRuns = 0;
        bowlerConceded = 0;
        facesBall = false;
        break;
    }

    return (
      isLegal: isLegal,
      teamExtras: teamExtras,
      batterRuns: bRuns,
      bowlerConcededRuns: bowlerConceded,
      facesBall: facesBall,
      triggersFreeHit: triggersFreeHit,
    );
  }
}
