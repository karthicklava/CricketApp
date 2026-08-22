import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/match_repository.dart';

void main() {
  late AppDatabase db;
  late MatchRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MatchRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Draft Match Management Tests', () {
    test('saving draft records createdAt on creation and updates updatedAt on modification', () async {
      const draftId = 'draft_101';
      final initialTime = DateTime(2026, 8, 9, 10, 0).millisecondsSinceEpoch;

      // First save (creation)
      await repo.saveMatch(
        id: draftId,
        matchName: 'Team A vs Team B',
        teamAId: 'team_a',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Ground 1',
        scheduledAt: initialTime,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      final draft1 = await repo.getMatchRecord(draftId);
      expect(draft1, isNotNull);
      final firstCreatedAt = draft1!.createdAt;
      final firstUpdatedAt = draft1.updatedAt;
      expect(firstCreatedAt, isNotNull);
      expect(firstUpdatedAt, isNotNull);

      // Brief delay before updating draft
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Second save (update draft)
      await repo.saveMatch(
        id: draftId,
        matchName: 'Team A vs Team B Updated',
        teamAId: 'team_a',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Ground 1 Updated',
        scheduledAt: initialTime,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      final draft2 = await repo.getMatchRecord(draftId);
      expect(draft2, isNotNull);
      // Original createdAt must NOT change
      expect(draft2!.createdAt, equals(firstCreatedAt));
      // updatedAt MUST be updated
      expect(draft2.updatedAt, greaterThanOrEqualTo(firstUpdatedAt!));
    });

    test('starting a draft match sets and locks startedAt', () async {
      const draftId = 'draft_102';

      // Create draft
      await repo.saveMatch(
        id: draftId,
        matchName: 'Team A vs Team B',
        teamAId: 'team_a',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Ground 2',
        scheduledAt: DateTime(2026, 8, 9).millisecondsSinceEpoch,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      final initialRecord = await repo.getMatchRecord(draftId);
      expect(initialRecord!.startedAt, isNull);

      final startTimestamp = DateTime(2026, 8, 21, 18, 45).millisecondsSinceEpoch;

      // Update match to live
      await repo.saveMatch(
        id: draftId,
        matchName: 'Team A vs Team B',
        teamAId: 'team_a',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Ground 2',
        scheduledAt: startTimestamp,
        startedAt: startTimestamp,
        status: 'draft', // Testing startedAt handling in saveMatch
        currentScorerDeviceId: 'device_1',
      );

      final updatedRecord = await repo.getMatchRecord(draftId);
      expect(updatedRecord!.startedAt, equals(startTimestamp));

      // Subsequent draft save preserves startedAt
      await repo.saveMatch(
        id: draftId,
        matchName: 'Team A vs Team B Updated',
        teamAId: 'team_a',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Ground 2',
        scheduledAt: startTimestamp,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      final finalRecord = await repo.getMatchRecord(draftId);
      expect(finalRecord!.startedAt, equals(startTimestamp));
    });

    test('deleting a draft match removes match and squad records while preserving teams & completed matches', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Create a Team
      await db.createTeam(TeamsTableCompanion(
        id: const Value('team_alpha'),
        name: const Value('Alpha XI'),
        shortName: const Value('AXI'),
        createdAt: Value(now),
      ));

      // 2. Create Completed Match
      await repo.saveMatch(
        id: 'completed_1',
        matchName: 'Completed Match',
        teamAId: 'team_alpha',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Stadium',
        scheduledAt: now,
        startedAt: now,
        status: 'completed',
        currentScorerDeviceId: 'device_1',
      );

      // 3. Create Draft Matches
      await repo.saveMatch(
        id: 'draft_del_1',
        matchName: 'Draft To Delete',
        teamAId: 'team_alpha',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Turf',
        scheduledAt: now,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      await repo.saveMatch(
        id: 'draft_keep_2',
        matchName: 'Draft To Keep',
        teamAId: 'team_alpha',
        teamBId: 'team_b',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Turf',
        scheduledAt: now,
        status: 'draft',
        currentScorerDeviceId: 'device_1',
      );

      // Verify drafts before deletion
      var drafts = await repo.getDraftMatches();
      expect(drafts.length, equals(2));

      // Delete draft_del_1
      await repo.deleteDraftMatch('draft_del_1');

      // Verify draft_del_1 is gone, draft_keep_2 remains
      drafts = await repo.getDraftMatches();
      expect(drafts.length, equals(1));
      expect(drafts.single.id, equals('draft_keep_2'));

      // Verify completed match is untouched
      final completedMatch = await repo.getMatchRecord('completed_1');
      expect(completedMatch, isNotNull);
      expect(completedMatch!.status, equals('completed'));

      // Verify team is untouched
      final teams = await db.getAllTeams();
      expect(teams.any((t) => t.id == 'team_alpha'), isTrue);
    });

    test('deleting a completed match via deleteDraftMatch throws StateError', () async {
      await repo.saveMatch(
        id: 'completed_2',
        matchName: 'Completed Game',
        teamAId: 't1',
        teamBId: 't2',
        format: 't20',
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4,
        allowConsecutiveOvers: false,
        maxOversWasManuallyEdited: false,
        venueName: 'Stadium',
        scheduledAt: DateTime.now().millisecondsSinceEpoch,
        startedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        currentScorerDeviceId: 'device_1',
      );

      expect(
        () => repo.deleteDraftMatch('completed_2'),
        throwsStateError,
      );
    });
  });
}
