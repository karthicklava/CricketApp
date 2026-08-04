import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/local/database.dart';
import 'home_dashboard_state.dart';

final homeDashboardStateProvider = Provider<HomeDashboardState>((ref) {
  final teamsAsync = ref.watch(activeTeamsStreamProvider);
  final activeMatchAsync = ref.watch(activeMatchStreamProvider);
  final draftsAsync = ref.watch(draftMatchesStreamProvider);
  final recentAsync = ref.watch(recentMatchesStreamProvider);

  if (teamsAsync.isLoading || activeMatchAsync.isLoading) {
    return HomeDashboardState.loading();
  }

  final teams = teamsAsync.value ?? [];
  final activeMatch = activeMatchAsync.value;
  final drafts = draftsAsync.value ?? [];
  final recentMatches = recentAsync.value ?? [];

  // Determine stage dynamically from SQLite database state
  HomeStage stage;
  TeamsTableData? incompleteTeam;

  if (activeMatch != null) {
    stage = HomeStage.matchInProgress;
  } else if (teams.isEmpty) {
    stage = HomeStage.noTeams;
  } else if (teams.length == 1) {
    stage = HomeStage.oneTeam;
  } else {
    // Check if any team has 0 players
    stage = HomeStage.readyForMatch;
  }

  return HomeDashboardState(
    stage: stage,
    teams: teams,
    teamPlayersMap: const {},
    activeMatch: activeMatch,
    drafts: drafts,
    recentMatches: recentMatches,
    isLoading: false,
    incompleteTeam: incompleteTeam,
  );
});
