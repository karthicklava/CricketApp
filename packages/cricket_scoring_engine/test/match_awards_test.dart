import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

const teamA = Team(
  id: 'a',
  name: 'Alpha',
  shortName: 'A',
  players: [
    Player(id: 'a1', name: 'Alpha One'),
    Player(id: 'a2', name: 'Alpha Two'),
  ],
);
const teamB = Team(
  id: 'b',
  name: 'Beta',
  shortName: 'B',
  players: [
    Player(id: 'b1', name: 'Beta One'),
    Player(id: 'b2', name: 'Beta Two'),
  ],
);

DeliveryEvent ball({
  required String id,
  required String innings,
  required String striker,
  required String nonStriker,
  required String bowler,
  int runs = 0,
  int sequence = 1,
  WicketType? wicket,
  String? dismissed,
}) =>
    DeliveryEvent(
      eventId: id,
      matchId: 'm',
      inningsId: innings,
      overNumber: 0,
      legalBallNumber: sequence,
      eventSequence: sequence,
      sequenceInOver: sequence,
      scorerDeviceId: 'test',
      strikerId: striker,
      nonStrikerId: nonStriker,
      bowlerId: bowler,
      runsBatter: runs,
      isBoundaryFour: runs == 4,
      isBoundarySix: runs == 6,
      wicket: wicket == null
          ? null
          : WicketDetail(
              type: wicket,
              dismissedPlayerId: dismissed ?? striker,
            ),
      previousEventHash: 'x',
      clientTimestamp: sequence,
    );

MatchState completed(List<DeliveryEvent> events,
        {String winner = 'a', bool tied = false}) =>
    MatchState(
      matchId: 'm',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      status: MatchStatus.completed,
      innings: const [
        InningsState(
          inningsId: 'i1',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
        ),
        InningsState(
          inningsId: 'i2',
          battingTeamId: 'b',
          bowlingTeamId: 'a',
          inningsNumber: 2,
          strikerId: 'b1',
          nonStrikerId: 'b2',
          currentBowlerId: 'a1',
        ),
      ],
      events: events,
      result: MatchResult(
        winnerTeamId: tied ? '' : winner,
        resultString: tied ? 'Match Tied' : 'Alpha won',
        isTie: tied,
      ),
    );

void main() {
  const service = MatchAwardsService();

  test('runs dominate a tiny high-strike-rate batting cameo', () {
    final state = completed([
      ball(
          id: '1',
          innings: 'i1',
          striker: 'a1',
          nonStriker: 'a2',
          bowler: 'b1',
          runs: 4),
      ...List.generate(
        4,
        (i) => ball(
            id: 'a$i',
            innings: 'i1',
            striker: 'a2',
            nonStriker: 'a1',
            bowler: 'b1',
            runs: 3,
            sequence: i + 2),
      ),
      ball(
          id: '2',
          innings: 'i2',
          striker: 'b1',
          nonStriker: 'b2',
          bowler: 'a1'),
    ]);
    expect(service.calculateAwards(state).bestBatter!.playerId, 'a2');
  });

  test('DNB player is excluded and a late batter is eligible after batting', () {
    final lateTeam = Team(
      id: teamA.id,
      name: teamA.name,
      shortName: teamA.shortName,
      players: const [
        Player(id: 'a1', name: 'Alpha One'),
        Player(id: 'a2', name: 'Alpha Two'),
        Player(id: 'late', name: 'Late', isLateAddition: true),
      ],
    );
    final state = completed([
      ball(
          id: '1',
          innings: 'i1',
          striker: 'late',
          nonStriker: 'a1',
          bowler: 'b1',
          runs: 6),
      ball(
          id: '2',
          innings: 'i2',
          striker: 'b1',
          nonStriker: 'b2',
          bowler: 'a1'),
    ]).copyWith(teamA: lateTeam);
    expect(service.calculateAwards(state).bestBatter!.playerId, 'late');
  });

  test('bowler-credit wicket counts but run out does not', () {
    final state = completed([
      ball(
          id: '1',
          innings: 'i1',
          striker: 'a1',
          nonStriker: 'a2',
          bowler: 'b1',
          wicket: WicketType.runOut),
      ball(
          id: '2',
          innings: 'i1',
          striker: 'a2',
          nonStriker: 'a1',
          bowler: 'b2',
          sequence: 2,
          wicket: WicketType.caught),
      ball(
          id: '3',
          innings: 'i2',
          striker: 'b1',
          nonStriker: 'b2',
          bowler: 'a1'),
    ]);
    expect(service.calculateAwards(state).bestBowler!.playerId, 'b2');
  });

  test('no-wicket match selects the lower-economy eligible bowler', () {
    final state = completed([
      ball(
          id: '1',
          innings: 'i1',
          striker: 'a1',
          nonStriker: 'a2',
          bowler: 'b1',
          runs: 4),
      ball(
          id: '2',
          innings: 'i1',
          striker: 'a1',
          nonStriker: 'a2',
          bowler: 'b2',
          sequence: 2),
      ball(
          id: '3',
          innings: 'i2',
          striker: 'b1',
          nonStriker: 'b2',
          bowler: 'a1',
          runs: 2),
    ], winner: 'b');
    expect(service.calculateAwards(state).bestBowler!.playerId, 'b2');
  });

  test('abandoned or active matches do not generate awards', () {
    final state = completed([
      ball(
          id: '1',
          innings: 'i1',
          striker: 'a1',
          nonStriker: 'a2',
          bowler: 'b1')
    ]).copyWith(status: MatchStatus.abandoned);
    expect(service.calculateAwards(state).awards, isEmpty);
  });
}
