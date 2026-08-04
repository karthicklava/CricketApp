import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine _engine() => CricketScoringEngine.createMatch(
      matchId: 'squad-match',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 2,
      ),
      teamA: Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: List.generate(
          4,
          (i) => Player(id: 'a$i', name: 'A$i'),
        ),
      ),
      teamB: Team(
        id: 'b',
        name: 'Beta',
        shortName: 'B',
        players: List.generate(
          4,
          (i) => Player(id: 'b$i', name: 'B$i'),
        ),
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a0',
      openingNonStrikerId: 'a1',
      openingBowlerId: 'b0',
    );

void main() {
  test('unparticipated live player can be removed from match only', () {
    final engine = _engine();
    engine.removeUnparticipatedPlayer(teamId: 'a', playerId: 'a3');

    expect(engine.state.teamA.players.map((p) => p.id), isNot(contains('a3')));
    expect(engine.state.activeInnings.playingMemberCountSnapshot, 3);
    expect(engine.state.activeInnings.maximumWickets, 2);
  });

  test('participating and currently selected players cannot be removed', () {
    final engine = _engine();
    engine.recordDelivery(eventId: 'ball', scorerDeviceId: 'test');

    expect(
      () => engine.removeUnparticipatedPlayer(teamId: 'a', playerId: 'a0'),
      throwsStateError,
    );
    expect(
      () => engine.removeUnparticipatedPlayer(teamId: 'b', playerId: 'b0'),
      throwsStateError,
    );
  });

  test('unavailable player remains in serialized historical squad', () {
    final engine = _engine();
    engine.setPlayerAvailability(
      teamId: 'a',
      playerId: 'a2',
      isAvailable: false,
    );

    final restored = MatchState.fromJson(engine.state.toJson());
    final player = restored.teamA.players.firstWhere((p) => p.id == 'a2');
    expect(player.isAvailable, isFalse);
    expect(restored.teamA.players, hasLength(4));
  });
}
