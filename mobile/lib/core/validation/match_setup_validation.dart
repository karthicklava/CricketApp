enum MatchSetupIssueType {
  teamNotSelected,
  teamHasNoPlayers,
  insufficientPlayers,
  noCaptainSelected,
  noEligibleBowler,
  duplicateTeamSelection,
}

enum MatchSetupRecoveryAction { addPlayers, chooseAnotherTeam, selectCaptain }

class MatchSetupIssue {
  final MatchSetupIssueType type;
  final String? teamId;
  final String teamName;
  final int requiredCount;
  final int currentCount;
  final String message;
  final MatchSetupRecoveryAction recoveryAction;

  const MatchSetupIssue({
    required this.type,
    this.teamId,
    required this.teamName,
    this.requiredCount = 0,
    this.currentCount = 0,
    required this.message,
    required this.recoveryAction,
  });
}

class MatchSetupValidation {
  final List<MatchSetupIssue> issues;

  const MatchSetupValidation(this.issues);

  bool get isValid => issues.isEmpty;

  MatchSetupIssue? issueForTeam(String? teamId) {
    if (teamId == null) return null;
    for (final issue in issues) {
      if (issue.teamId == teamId) return issue;
    }
    return null;
  }
}

class MatchSetupValidator {
  const MatchSetupValidator._();

  static MatchSetupValidation validateTeams({
    required String? teamAId,
    required String? teamAName,
    required int teamAPlayerCount,
    required String? teamBId,
    required String? teamBName,
    required int teamBPlayerCount,
    required int minimumPlayersRequired,
    bool requireBothTeams = true,
  }) {
    final issues = <MatchSetupIssue>[];

    void validateTeam(String? id, String? name, int count) {
      if (id == null) {
        if (requireBothTeams) {
          issues.add(
            const MatchSetupIssue(
              type: MatchSetupIssueType.teamNotSelected,
              teamName: 'Team',
              message: 'Select both teams before continuing.',
              recoveryAction: MatchSetupRecoveryAction.chooseAnotherTeam,
            ),
          );
        }
        return;
      }
      final displayName = name ?? 'Selected team';
      if (count == 0) {
        issues.add(
          MatchSetupIssue(
            type: MatchSetupIssueType.teamHasNoPlayers,
            teamId: id,
            teamName: displayName,
            requiredCount: minimumPlayersRequired,
            currentCount: 0,
            message:
                '$displayName has no players. Add at least one player before continuing.',
            recoveryAction: MatchSetupRecoveryAction.addPlayers,
          ),
        );
      } else if (count < minimumPlayersRequired) {
        issues.add(
          MatchSetupIssue(
            type: MatchSetupIssueType.insufficientPlayers,
            teamId: id,
            teamName: displayName,
            requiredCount: minimumPlayersRequired,
            currentCount: count,
            message:
                '$displayName needs at least $minimumPlayersRequired players for this match. Currently, it has $count.',
            recoveryAction: MatchSetupRecoveryAction.addPlayers,
          ),
        );
      }
    }

    validateTeam(teamAId, teamAName, teamAPlayerCount);
    validateTeam(teamBId, teamBName, teamBPlayerCount);
    if (teamAId != null && teamAId == teamBId) {
      issues.add(
        MatchSetupIssue(
          type: MatchSetupIssueType.duplicateTeamSelection,
          teamId: teamAId,
          teamName: teamAName ?? 'Selected team',
          message: 'Choose two different teams.',
          recoveryAction: MatchSetupRecoveryAction.chooseAnotherTeam,
        ),
      );
    }
    return MatchSetupValidation(issues);
  }
}

class MatchSetupValidationException implements Exception {
  final String message;
  const MatchSetupValidationException(this.message);

  @override
  String toString() => message;
}
