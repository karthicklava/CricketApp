import 'package:flutter/foundation.dart';
import '../../data/local/database.dart';

enum HomeStage {
  noTeams, // 0 active valid teams
  oneTeam, // 1 active valid team
  incompleteTeam, // 2+ teams, but 1 has 0 players
  readyForMatch, // 2+ active valid teams with players
  matchInProgress, // active unfinished live match
}

@immutable
class HomeDashboardState {
  final HomeStage stage;
  final List<TeamsTableData> teams;
  final Map<String, List<PlayersTableData>> teamPlayersMap;
  final MatchesTableData? activeMatch;
  final List<MatchesTableData> drafts;
  final List<MatchesTableData> recentMatches;
  final bool isLoading;
  final String? errorMessage;
  final TeamsTableData? incompleteTeam;

  const HomeDashboardState({
    required this.stage,
    required this.teams,
    required this.teamPlayersMap,
    this.activeMatch,
    this.drafts = const [],
    this.recentMatches = const [],
    this.isLoading = false,
    this.errorMessage,
    this.incompleteTeam,
  });

  factory HomeDashboardState.loading() => const HomeDashboardState(
        stage: HomeStage.noTeams,
        teams: [],
        teamPlayersMap: {},
        isLoading: true,
      );
}
