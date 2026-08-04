import 'package:cricket_scorer/core/validation/match_setup_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchSetupValidator', () {
    test('empty Team A reports its name immediately', () {
      final result = MatchSetupValidator.validateTeams(
        teamAId: 'a',
        teamAName: 'Team 1',
        teamAPlayerCount: 0,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 5,
        minimumPlayersRequired: 1,
      );

      expect(result.isValid, isFalse);
      expect(
          result.issueForTeam('a')!.type, MatchSetupIssueType.teamHasNoPlayers);
      expect(result.issueForTeam('a')!.message, contains('Team 1'));
    });

    test('empty Team B and two empty teams are invalid', () {
      final oneEmpty = MatchSetupValidator.validateTeams(
        teamAId: 'a',
        teamAName: 'Team 1',
        teamAPlayerCount: 2,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 0,
        minimumPlayersRequired: 1,
      );
      final bothEmpty = MatchSetupValidator.validateTeams(
        teamAId: 'a',
        teamAName: 'Team 1',
        teamAPlayerCount: 0,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 0,
        minimumPlayersRequired: 1,
      );

      expect(oneEmpty.issueForTeam('b'), isNotNull);
      expect(bothEmpty.issues, hasLength(2));
    });

    test('small custom teams pass when configured minimum is met', () {
      final result = MatchSetupValidator.validateTeams(
        teamAId: 'a',
        teamAName: 'Team 1',
        teamAPlayerCount: 1,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 1,
        minimumPlayersRequired: 1,
      );

      expect(result.isValid, isTrue);
    });

    test('larger configured minimum reports required and current counts', () {
      final result = MatchSetupValidator.validateTeams(
        teamAId: 'a',
        teamAName: 'Team 1',
        teamAPlayerCount: 1,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 3,
        minimumPlayersRequired: 3,
      );
      final issue = result.issueForTeam('a')!;

      expect(issue.type, MatchSetupIssueType.insufficientPlayers);
      expect(issue.requiredCount, 3);
      expect(issue.currentCount, 1);
      expect(issue.message, contains('Currently, it has 1'));
    });

    test('duplicate teams and unselected teams are rejected', () {
      final duplicate = MatchSetupValidator.validateTeams(
        teamAId: 'same',
        teamAName: 'Team',
        teamAPlayerCount: 2,
        teamBId: 'same',
        teamBName: 'Team',
        teamBPlayerCount: 2,
        minimumPlayersRequired: 1,
      );
      final missing = MatchSetupValidator.validateTeams(
        teamAId: null,
        teamAName: null,
        teamAPlayerCount: 0,
        teamBId: 'b',
        teamBName: 'Team 2',
        teamBPlayerCount: 2,
        minimumPlayersRequired: 1,
      );

      expect(
        duplicate.issues.any((issue) =>
            issue.type == MatchSetupIssueType.duplicateTeamSelection),
        isTrue,
      );
      expect(
        missing.issues
            .any((issue) => issue.type == MatchSetupIssueType.teamNotSelected),
        isTrue,
      );
    });
  });
}
