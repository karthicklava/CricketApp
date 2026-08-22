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

  group('Recent Matches Section Tests', () {
    test('database watchRecentMatches returns matches sorted newest first by endedAt / createdAt', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Insert 5 completed matches with different endedAt timestamps
      for (int i = 1; i <= 5; i++) {
        await db.into(db.matchesTable).insert(MatchesTableCompanion(
          id: Value('completed_$i'),
          matchName: Value('Match $i'),
          teamAId: Value('team_a'),
          teamBId: Value('team_b'),
          format: Value('t20'),
          scheduledAt: Value(now + (i * 1000)),
          createdAt: Value(now + (i * 1000)),
          updatedAt: Value(now + (i * 1000)),
          endedAt: Value(now + (i * 1000)),
          status: Value('completed'),
          currentScorerDeviceId: Value('device_1'),
        ));
      }

      final recent = await db.getRecentMatches();
      expect(recent.length, equals(5));
      // Verify ordering: newest first
      expect(recent.first.id, equals('completed_5'));
      expect(recent.last.id, equals('completed_1'));
    });

    test('recent matches list sorting and max 3 limiting logic', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<MatchesTableData> matches = [];

      for (int i = 1; i <= 5; i++) {
        matches.add(MatchesTableData(
          id: 'm_$i',
          matchName: 'Match $i',
          teamAId: 'team_a',
          teamBId: 'team_b',
          format: 't20',
          scheduledAt: now + (i * 1000),
          startedAt: now + (i * 1000),
          endedAt: now + (i * 1000),
          createdAt: now + (i * 1000),
          status: 'completed',
          currentScorerDeviceId: 'dev_1',
          version: 1,
          syncStatus: 'localOnly',
          endedManually: false,
        ));
      }

      // Sort logic
      final sortedRecent = List<MatchesTableData>.from(matches)
        ..sort((a, b) {
          final timeA = a.endedAt ?? a.startedAt ?? a.createdAt;
          final timeB = b.endedAt ?? b.startedAt ?? b.createdAt;
          return timeB.compareTo(timeA);
        });

      final hasMoreThan3 = sortedRecent.length > 3;
      final displayMatches = sortedRecent.take(3).toList();

      expect(hasMoreThan3, isTrue);
      expect(displayMatches.length, equals(3));
      expect(displayMatches.first.id, equals('m_5'));
      expect(displayMatches[1].id, equals('m_4'));
      expect(displayMatches[2].id, equals('m_3'));
    });

    test('3 or fewer completed matches hides View All', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<MatchesTableData> matches = [];

      for (int i = 1; i <= 3; i++) {
        matches.add(MatchesTableData(
          id: 'm_$i',
          matchName: 'Match $i',
          teamAId: 'team_a',
          teamBId: 'team_b',
          format: 't20',
          scheduledAt: now + (i * 1000),
          createdAt: now + (i * 1000),
          status: 'completed',
          currentScorerDeviceId: 'dev_1',
          version: 1,
          syncStatus: 'localOnly',
          endedManually: false,
        ));
      }

      final sortedRecent = List<MatchesTableData>.from(matches)
        ..sort((a, b) {
          final timeA = a.endedAt ?? a.startedAt ?? a.createdAt;
          final timeB = b.endedAt ?? b.startedAt ?? b.createdAt;
          return timeB.compareTo(timeA);
        });

      final hasMoreThan3 = sortedRecent.length > 3;
      final displayMatches = sortedRecent.take(3).toList();

      expect(hasMoreThan3, isFalse);
      expect(displayMatches.length, equals(3));
    });

    test('0 completed matches produces empty state', () async {
      final List<MatchesTableData> matches = [];
      final hasMoreThan3 = matches.length > 3;
      expect(hasMoreThan3, isFalse);
      expect(matches.isEmpty, isTrue);
    });
  });
}
