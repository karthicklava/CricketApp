import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

void main() {
  test('role formatter supports captain, keeper, and combined roles', () {
    expect(
      formatPlayerDisplayName(
        playerName: 'Captain',
        isCaptain: true,
        isWicketkeeper: false,
      ),
      'Captain (C)',
    );
    expect(
      formatPlayerDisplayName(
        playerName: 'Keeper',
        isCaptain: false,
        isWicketkeeper: true,
      ),
      'Keeper (WK)',
    );
    expect(
      formatPlayerDisplayName(
        playerName: 'Both',
        isCaptain: true,
        isWicketkeeper: true,
      ),
      'Both (C & WK)',
    );
  });

  test('match role snapshot survives serialization independently of roster',
      () {
    const state = MatchState(
      matchId: 'roles',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [Player(id: 'a1', name: 'Historical Name')],
      ),
      teamB: Team(id: 'b', name: 'Beta', shortName: 'B'),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      innings: [
        InningsState(
          inningsId: 'i1',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
        ),
      ],
      teamRoleSnapshots: [
        MatchTeamRoleSnapshot(
          teamId: 'a',
          captainPlayerId: 'a1',
          wicketkeeperPlayerId: 'a1',
        ),
      ],
    );

    final restored = MatchState.fromJson(state.toJson());
    expect(
      restored.displayNameFor('a', 'a1', 'Historical Name'),
      'Historical Name (C & WK)',
    );
  });
}
