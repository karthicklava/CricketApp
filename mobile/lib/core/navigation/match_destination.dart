import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

enum MatchDestination {
  setup,
  liveScoring,
  inningsBreak,
  completedScorecard,
  archivedScorecard,
}

class MatchDestinationResolver {
  const MatchDestinationResolver._();

  static MatchDestination resolveStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'live':
      case 'ready':
      case 'setupcompleted':
      case 'setup_completed':
      case 'tosscompleted':
      case 'toss_completed':
      case 'inprogress':
      case 'in_progress':
      case 'awaitingnextbatter':
      case 'awaiting_next_batter':
      case 'awaitingnextbowler':
      case 'awaiting_next_bowler':
      case 'secondinningssetup':
      case 'second_innings_setup':
      case 'secondinnings':
      case 'second_innings':
      case 'paused':
      case 'resultpending':
      case 'result_pending':
        return MatchDestination.liveScoring;
      case 'inningsbreak':
      case 'innings_break':
        return MatchDestination.inningsBreak;
      case 'completed':
        return MatchDestination.completedScorecard;
      case 'archived':
      case 'abandoned':
      case 'noresult':
      case 'no_result':
      case 'cancelled':
        return MatchDestination.archivedScorecard;
      case 'draft':
      case 'setupinprogress':
      case 'setup_in_progress':
      default:
        return MatchDestination.setup;
    }
  }

  static String actionLabel(String status) {
    switch (resolveStatus(status)) {
      case MatchDestination.setup:
        return 'Continue Setup';
      case MatchDestination.liveScoring:
        return 'Resume Scoring';
      case MatchDestination.inningsBreak:
        return 'Continue Match';
      case MatchDestination.completedScorecard:
      case MatchDestination.archivedScorecard:
        return 'View Scorecard';
    }
  }

  static String routeFor({
    required String matchId,
    required String status,
  }) {
    switch (resolveStatus(status)) {
      case MatchDestination.setup:
        return '/matches/create?draftId=$matchId';
      case MatchDestination.liveScoring:
      case MatchDestination.inningsBreak:
        return '/matches/$matchId/scoring';
      case MatchDestination.completedScorecard:
      case MatchDestination.archivedScorecard:
        return '/matches/history/$matchId';
    }
  }

  static String? validateLiveState(MatchState? state) {
    if (state == null) return 'The saved live match state could not be found.';
    if (state.status != MatchStatus.live &&
        state.status != MatchStatus.inningsBreak) {
      return 'This match is not in a resumable live state.';
    }
    if (state.innings.isEmpty ||
        state.currentInningsIndex < 0 ||
        state.currentInningsIndex >= state.innings.length) {
      return 'The active innings is missing.';
    }
    final innings = state.activeInnings;
    final battingTeam = innings.battingTeamId == state.teamA.id
        ? state.teamA
        : innings.battingTeamId == state.teamB.id
            ? state.teamB
            : null;
    final bowlingTeam = innings.bowlingTeamId == state.teamA.id
        ? state.teamA
        : innings.bowlingTeamId == state.teamB.id
            ? state.teamB
            : null;
    if (battingTeam == null || bowlingTeam == null) {
      return 'The batting or bowling team is missing.';
    }
    if (!battingTeam.players.any((p) => p.id == innings.strikerId)) {
      return 'The current striker is missing from the batting squad.';
    }
    if (!battingTeam.players.any((p) => p.id == innings.nonStrikerId)) {
      return 'The current non-striker is missing from the batting squad.';
    }
    if (innings.flowState != InningsFlowState.awaitingNextBowler &&
        !bowlingTeam.players.any((p) => p.id == innings.currentBowlerId)) {
      return 'The current bowler is missing from the bowling squad.';
    }
    return null;
  }
}
