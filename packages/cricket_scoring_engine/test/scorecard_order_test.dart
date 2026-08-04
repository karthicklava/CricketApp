import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine engineForOrder() => CricketScoringEngine.createMatch(
      matchId: 'order',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 5,
        maxOversPerBowler: 5,
        allowConsecutiveOvers: true,
      ),
      teamA: const Team(
        id: 'a',
        name: 'Batting',
        shortName: 'BAT',
        players: [
          Player(id: 'dnb1', name: 'Vishnu'),
          Player(id: 'dnb2', name: 'Kanagaraj'),
          Player(id: 'opener1', name: 'Karthick'),
          Player(id: 'opener2', name: 'Ragu'),
          Player(id: 'incoming', name: 'JP'),
          Player(id: 'late', name: 'Late Batter', isLateAddition: true),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'Bowling',
        shortName: 'BWL',
        players: [
          Player(id: 'unused', name: 'Unused'),
          Player(id: 'bowler3', name: 'Third Bowler'),
          Player(id: 'bowler1', name: 'Opening Bowler'),
          Player(id: 'bowler2', name: 'Replacement Bowler'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'opener1',
      openingNonStrikerId: 'opener2',
      openingBowlerId: 'bowler1',
    );

void main() {
  test('batting rows use entry order and put roster-first DNB players last',
      () {
    final engine = engineForOrder();
    engine.recordDelivery(
      eventId: 'wicket',
      scorerDeviceId: 'test',
      wicket: const WicketDetail(
        type: WicketType.bowled,
        dismissedPlayerId: 'opener1',
      ),
      newBatterId: 'incoming',
    );
    engine.recordDelivery(eventId: 'jp-ball', scorerDeviceId: 'test');

    final rows = engine.getBatterScorecards(engine.state.teamA);
    expect(rows.map((row) => row.playerId), [
      'opener1',
      'opener2',
      'incoming',
      'dnb1',
      'dnb2',
      'late',
    ]);
    expect(rows.take(3).map((row) => row.battingPosition), [1, 2, 3]);
    expect(rows.skip(3).every((row) => !row.hasBatted), isTrue);
    expect(
        rows.skip(3).every((row) => row.dismissalInfo == 'yet to bat'), isTrue);
  });

  test('completed innings labels non-participants Did not bat', () {
    final engine = engineForOrder();
    engine.recordDelivery(eventId: 'ball', scorerDeviceId: 'test');
    final active = engine.state.activeInnings.copyWith(
      isCompleted: true,
      flowState: InningsFlowState.inningsCompleted,
    );
    final completed = CricketScoringEngine(engine.state.copyWith(
      innings: [active],
    ));

    final rows = completed.getBatterScorecards(completed.state.teamA);
    expect(rows.where((row) => !row.hasBatted), isNotEmpty);
    expect(
        rows
            .where((row) => !row.hasBatted)
            .every((row) => row.dismissalInfo == 'Did not bat'),
        isTrue);
  });

  test('returning retired-hurt batter keeps one original position', () {
    final engine = engineForOrder();
    engine.recordDelivery(
      eventId: 'retire',
      scorerDeviceId: 'test',
      wicket: const WicketDetail(
        type: WicketType.retiredHurt,
        dismissedPlayerId: 'opener1',
      ),
      newBatterId: 'incoming',
    );
    engine.changeBatter(newBatterId: 'opener1', replaceStriker: true);

    final rows = engine.getBatterScorecards(engine.state.teamA);
    expect(rows.where((row) => row.playerId == 'opener1'), hasLength(1));
    expect(
        rows.firstWhere((row) => row.playerId == 'opener1').battingPosition, 1);
    expect(engine.state.activeInnings.battingOrder,
        ['opener1', 'opener2', 'incoming']);
  });

  test('late batter gets a position only when selected to bat', () {
    final engine = engineForOrder();
    expect(
      engine
          .getBatterScorecards(engine.state.teamA)
          .firstWhere((row) => row.playerId == 'late')
          .battingPosition,
      isNull,
    );
    engine.changeBatter(newBatterId: 'late', replaceStriker: true);
    expect(
      engine
          .getBatterScorecards(engine.state.teamA)
          .firstWhere((row) => row.playerId == 'late')
          .battingPosition,
      3,
    );
  });

  test('bowling rows use first-delivery order including mid-over replacement',
      () {
    final engine = engineForOrder();
    engine.recordDelivery(eventId: 'one', scorerDeviceId: 'test');
    engine.replaceCurrentBowler(
      newBowlerId: 'bowler2',
      reason: BowlerChangeReason.injury,
      changedBy: 'test',
    );
    engine.recordDelivery(eventId: 'two', scorerDeviceId: 'test');
    engine.changeBowler('bowler1');
    engine.recordDelivery(eventId: 'three', scorerDeviceId: 'test');

    final rows = engine.getBowlerScorecards(engine.state.teamB);
    expect(rows.map((row) => row.playerId), ['bowler1', 'bowler2']);
    expect(rows.map((row) => row.bowlingPosition), [1, 2]);
    expect(rows.where((row) => row.playerId == 'bowler1'), hasLength(1));
    expect(rows.any((row) => row.playerId == 'unused'), isFalse);
  });

  test('serialization preserves order and legacy snapshots reconstruct it', () {
    final engine = engineForOrder();
    engine.recordDelivery(
      eventId: 'wicket',
      scorerDeviceId: 'test',
      wicket: const WicketDetail(
        type: WicketType.bowled,
        dismissedPlayerId: 'opener1',
      ),
      newBatterId: 'incoming',
    );
    engine.recordDelivery(eventId: 'incoming-ball', scorerDeviceId: 'test');

    final resumed = CricketScoringEngine(
      MatchState.fromJson(engine.state.toJson()),
    );
    expect(resumed.state.activeInnings.battingOrder,
        ['opener1', 'opener2', 'incoming']);

    final legacyJson = engine.state.toJson();
    final legacyInnings =
        Map<String, dynamic>.from((legacyJson['innings'] as List).first as Map)
          ..remove('battingOrder');
    legacyJson['innings'] = [legacyInnings];
    final reconstructed = CricketScoringEngine(MatchState.fromJson(legacyJson));
    expect(reconstructed.state.activeInnings.battingOrder,
        ['opener1', 'opener2', 'incoming']);
    expect(
      reconstructed
          .getBowlerScorecards(reconstructed.state.teamB)
          .map((row) => row.playerId),
      ['bowler1'],
    );
  });
}
