import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:cricket_scorer/data/local/database.dart';

class _TestQueryUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 16;
  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Database Migration & Schema Tests', () {
    test('Scenario 1: Fresh App Installation creates all tables and columns', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      final teams = await db.getAllTeams();
      expect(teams, isEmpty);

      final matches = await db.getAllMatches();
      expect(matches, isEmpty);

      final rows = await db.customSelect('PRAGMA table_info(matches_table)').get();
      final columnNames = rows.map((r) => r.read<String>('name')).toSet();

      expect(columnNames, contains('toss_calling_team_id'));
      expect(columnNames, contains('toss_winner_team_id'));
      expect(columnNames, contains('toss_decision'));
      expect(columnNames, contains('toss_call'));
      expect(columnNames, contains('coin_result'));
      expect(columnNames, contains('updated_at'));

      await db.close();
    });

    test('Scenario 2: Migration from schema version 16 to 18 succeeds and preserves existing data', () async {
      final executor = NativeDatabase.memory();
      await executor.ensureOpen(_TestQueryUser());

      await executor.runCustom('''
        CREATE TABLE teams_table (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          short_name TEXT NOT NULL,
          logo_url TEXT,
          city TEXT,
          color TEXT,
          default_captain_id TEXT,
          created_at INTEGER NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'localOnly'
        );
      ''');

      await executor.runCustom('''
        CREATE TABLE matches_table (
          id TEXT NOT NULL PRIMARY KEY,
          match_name TEXT,
          tournament_id TEXT,
          team_a_id TEXT NOT NULL,
          team_b_id TEXT NOT NULL,
          format TEXT NOT NULL DEFAULT 't20',
          total_overs INTEGER,
          balls_per_over INTEGER,
          max_overs_per_bowler INTEGER,
          allow_consecutive_overs INTEGER,
          max_overs_was_manually_edited INTEGER,
          venue_name TEXT,
          scheduled_at INTEGER NOT NULL,
          started_at INTEGER,
          match_time_zone TEXT,
          toss_winner_team_id TEXT,
          toss_decision TEXT,
          team_a_squad_json TEXT,
          team_b_squad_json TEXT,
          team_a_captain_id TEXT,
          team_b_captain_id TEXT,
          team_a_wicketkeeper_id TEXT,
          team_b_wicketkeeper_id TEXT,
          status TEXT NOT NULL DEFAULT 'draft',
          current_scorer_device_id TEXT NOT NULL,
          version INTEGER NOT NULL DEFAULT 1,
          sync_status TEXT NOT NULL DEFAULT 'localOnly',
          state_json TEXT,
          setup_draft_json TEXT,
          created_at INTEGER NOT NULL,
          end_reason_code TEXT,
          end_reason_text TEXT,
          end_note TEXT,
          ended_manually INTEGER NOT NULL DEFAULT 0,
          ended_at INTEGER,
          ended_by TEXT,
          winner_team_id TEXT,
          loser_team_id TEXT,
          result_type TEXT,
          result_text TEXT
        );
      ''');

      await executor.runCustom('''
        INSERT INTO teams_table (id, name, short_name, created_at)
        VALUES ('team_1', 'Royal Strikers', 'RST', 1600000000);
      ''');

      await executor.runCustom('''
        INSERT INTO matches_table (id, team_a_id, team_b_id, scheduled_at, status, current_scorer_device_id, created_at)
        VALUES ('match_1', 'team_1', 'team_2', 1600000000, 'draft', 'dev_1', 1600000000);
      ''');

      await executor.runCustom('PRAGMA user_version = 16;');

      final db = AppDatabase.forTesting(executor);
      await db.migration.onUpgrade(db.createMigrator(), 16, 18);

      final teams = await db.getAllTeams();
      expect(teams.length, equals(1));
      expect(teams.first.name, equals('Royal Strikers'));

      final matches = await db.getAllMatches();
      expect(matches.length, equals(1));
      expect(matches.first.id, equals('match_1'));

      final rows = await db.customSelect('PRAGMA table_info(matches_table)').get();
      final columnNames = rows.map((r) => r.read<String>('name')).toSet();

      expect(columnNames, contains('toss_calling_team_id'));
      expect(columnNames, contains('toss_call'));
      expect(columnNames, contains('coin_result'));
      expect(columnNames, contains('updated_at'));

      await db.close();
    });

    test('Scenario 3: Development DB with duplicate column toss_calling_team_id handles migration without crash', () async {
      final executor = NativeDatabase.memory();
      await executor.ensureOpen(_TestQueryUser());

      await executor.runCustom('''
        CREATE TABLE matches_table (
          id TEXT NOT NULL PRIMARY KEY,
          team_a_id TEXT NOT NULL,
          team_b_id TEXT NOT NULL,
          scheduled_at INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'draft',
          current_scorer_device_id TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          toss_calling_team_id TEXT
        );
      ''');
      await executor.runCustom('PRAGMA user_version = 16;');

      final db = AppDatabase.forTesting(executor);

      // Must complete migration without throwing duplicate column exception
      await db.migration.onUpgrade(db.createMigrator(), 16, 18);
      await db.getAllMatches();

      final rows = await db.customSelect('PRAGMA table_info(matches_table)').get();
      final columnNames = rows.map((r) => r.read<String>('name')).toSet();

      expect(columnNames, contains('toss_calling_team_id'));
      expect(columnNames, contains('toss_call'));
      expect(columnNames, contains('coin_result'));

      await db.close();
    });

    test('Scenario 4: Queries for Home, Matches, Teams, and Draft Matches resolve immediately', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      final activeTeams = await db.getAllTeams();
      final activeMatch = await db.getActiveMatch();
      final recentMatches = await db.getRecentMatches();
      final draftMatches = await db.getDraftMatches();

      expect(activeTeams, isNotNull);
      expect(activeMatch, isNull);
      expect(recentMatches, isEmpty);
      expect(draftMatches, isEmpty);

      await db.close();
    });
  });
}
