import 'dart:convert';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/match_repository.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

void main() {
  late AppDatabase db;
  late MatchRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(db);

    // Insert dummy teams and players in DB for saveMatch validation
    await db.into(db.teamsTable).insert(const TeamsTableCompanion(
      id: drift.Value('team_a'),
      name: drift.Value('Team A'),
      shortName: drift.Value('TMA'),
      createdAt: drift.Value(1000),
      syncStatus: drift.Value('synced'),
    ));
    await db.into(db.teamsTable).insert(const TeamsTableCompanion(
      id: drift.Value('team_b'),
      name: drift.Value('Team B'),
      shortName: drift.Value('TMB'),
      createdAt: drift.Value(1000),
      syncStatus: drift.Value('synced'),
    ));

    for (final p in [
      ('p1', 'team_a', 'Player 1'),
      ('p2', 'team_a', 'Player 2'),
      ('p3', 'team_b', 'Player 3'),
      ('p4', 'team_b', 'Player 4'),
    ]) {
      await db.createPlayer(PlayersTableCompanion.insert(
        id: p.$1,
        name: p.$3,
        createdAt: 1000,
      ));
      await db.addPlayerToTeam(p.$2, p.$1);
    }
  });

  tearDown(() async {
    await db.close();
  });

  test('Draft match transitions to live and completed without leaving orphaned draft records', () async {
    const matchId = 'draft_1700000000000';

    // 1. Persist draft match during wizard setup
    await repository.saveMatch(
      id: matchId,
      matchName: 'Team A vs Team B',
      teamAId: 'team_a',
      teamBId: 'team_b',
      format: 'custom',
      totalOvers: 5,
      ballsPerOver: 6,
      maxOversPerBowler: 2,
      allowConsecutiveOvers: false,
      maxOversWasManuallyEdited: false,
      venueName: 'Ground 1',
      scheduledAt: DateTime.now().millisecondsSinceEpoch,
      status: 'draft',
      currentScorerDeviceId: 'device_local',
    );

    // Verify 1 draft match exists
    var drafts = await repository.getDraftMatches();
    expect(drafts.length, equals(1));
    expect(drafts.first.id, equals(matchId));
    expect(drafts.first.status, equals('draft'));

    // 2. User starts the match using the SAME matchId
    await repository.saveMatch(
      id: matchId,
      matchName: 'Team A vs Team B',
      teamAId: 'team_a',
      teamBId: 'team_b',
      format: 'custom',
      totalOvers: 5,
      ballsPerOver: 6,
      maxOversPerBowler: 2,
      allowConsecutiveOvers: false,
      maxOversWasManuallyEdited: false,
      venueName: 'Ground 1',
      scheduledAt: DateTime.now().millisecondsSinceEpoch,
      teamASquadJson: jsonEncode(['p1', 'p2']),
      teamBSquadJson: jsonEncode(['p3', 'p4']),
      teamACaptainId: 'p1',
      teamBCaptainId: 'p3',
      status: 'live',
      currentScorerDeviceId: 'device_local',
    );

    // Verify 0 draft matches exist and active match is live
    drafts = await repository.getDraftMatches();
    expect(drafts.isEmpty, isTrue);

    final active = await repository.getActiveMatch();
    expect(active, isNotNull);
    expect(active!.id, equals(matchId));
    expect(active.status, equals('live'));

    // 3. Complete the match
    final config = MatchConfig(
      format: MatchFormat.custom,
      totalOvers: 5,
      ballsPerOver: 6,
      maxOversPerBowler: 2,
      bowlingRulesConfirmedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: matchId,
      config: config,
      teamA: const Team(id: 'team_a', name: 'Team A', shortName: 'TMA', players: [
        Player(id: 'p1', name: 'P1'),
        Player(id: 'p2', name: 'P2'),
      ]),
      teamB: const Team(id: 'team_b', name: 'Team B', shortName: 'TMB', players: [
        Player(id: 'p3', name: 'P3'),
        Player(id: 'p4', name: 'P4'),
      ]),
      tossWinnerTeamId: 'team_a',
      tossDecision: 'BAT',
      openingStrikerId: 'p1',
      openingNonStrikerId: 'p2',
      openingBowlerId: 'p3',
    );

    final completedState = engine.state.copyWith(
      status: MatchStatus.completed,
      endedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await repository.persistState(completedState);

    // Verify 0 draft matches exist after completion
    drafts = await repository.getDraftMatches();
    expect(drafts.isEmpty, isTrue);

    // Verify completed match is in recent matches list
    final recent = await repository.getRecentMatches();
    expect(recent.length, equals(1));
    expect(recent.first.id, equals(matchId));
    expect(recent.first.status, equals('completed'));
  });
}
