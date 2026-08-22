import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class TeamsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get defaultCaptainId => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PlayersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get jerseyNumber => text().nullable()();
  TextColumn get role => text().withDefault(const Constant(
      'allRounder'))(); // batter, bowler, allRounder, wicketKeeper, wicketKeeperBatter
  TextColumn get battingStyle => text().withDefault(const Constant('notSet'))();
  TextColumn get bowlingStyle => text().withDefault(const Constant('notSet'))();
  BoolColumn get isCaptain => boolean().withDefault(const Constant(false))();
  BoolColumn get isWicketKeeper =>
      boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {id};
}

class TeamMembersTable extends Table {
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get joinedAt => integer().withDefault(const Constant(0))();
  IntColumn get removedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {teamId, playerId};
}

class MatchesTable extends Table {
  TextColumn get id => text()();
  TextColumn get matchName => text().nullable()();
  TextColumn get tournamentId => text().nullable()();
  TextColumn get teamAId => text()();
  TextColumn get teamBId => text()();
  TextColumn get format => text().withDefault(const Constant('t20'))();
  IntColumn get totalOvers => integer().nullable()();
  IntColumn get ballsPerOver => integer().nullable()();
  IntColumn get maxOversPerBowler => integer().nullable()();
  BoolColumn get allowConsecutiveOvers => boolean().nullable()();
  BoolColumn get maxOversWasManuallyEdited => boolean().nullable()();
  TextColumn get venueName => text().nullable()();
  IntColumn get scheduledAt => integer()();
  IntColumn get startedAt => integer().nullable()();
  TextColumn get matchTimeZone => text().nullable()();
  TextColumn get tossWinnerTeamId => text().nullable()();
  TextColumn get tossDecision => text().nullable()(); // BAT, BOWL
  TextColumn get tossCallingTeamId => text().nullable()();
  TextColumn get tossCall => text().nullable()(); // HEADS, TAILS
  TextColumn get coinResult => text().nullable()(); // HEADS, TAILS
  TextColumn get teamASquadJson => text().nullable()(); // List of player IDs
  TextColumn get teamBSquadJson => text().nullable()(); // List of player IDs
  TextColumn get teamACaptainId => text().nullable()();
  TextColumn get teamBCaptainId => text().nullable()();
  TextColumn get teamAWicketkeeperId => text().nullable()();
  TextColumn get teamBWicketkeeperId => text().nullable()();
  TextColumn get status => text().withDefault(
      const Constant('draft'))(); // draft, live, completed, abandoned
  TextColumn get currentScorerDeviceId => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('localOnly'))();
  TextColumn get stateJson => text().nullable()();
  TextColumn get setupDraftJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer().nullable()();
  TextColumn get endReasonCode => text().nullable()();
  TextColumn get endReasonText => text().nullable()();
  TextColumn get endNote => text().nullable()();
  BoolColumn get endedManually =>
      boolean().withDefault(const Constant(false))();
  IntColumn get endedAt => integer().nullable()();
  TextColumn get endedBy => text().nullable()();
  TextColumn get winnerTeamId => text().nullable()();
  TextColumn get loserTeamId => text().nullable()();
  TextColumn get resultType => text().nullable()();
  TextColumn get resultText => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeliveriesTable extends Table {
  TextColumn get eventId => text()();
  TextColumn get matchId => text()();
  TextColumn get inningsId => text()();
  IntColumn get overNumber => integer()();
  IntColumn get legalBallNumber => integer()();
  IntColumn get eventSequence => integer()();
  IntColumn get sequenceInOver => integer().withDefault(const Constant(1))();
  TextColumn get scorerDeviceId => text()();
  TextColumn get strikerId => text()();
  TextColumn get nonStrikerId => text()();
  TextColumn get bowlerId => text()();
  IntColumn get runsBatter => integer().withDefault(const Constant(0))();
  TextColumn get extrasType => text().withDefault(const Constant('none'))();
  IntColumn get extrasRuns => integer().withDefault(const Constant(0))();
  IntColumn get wideRuns => integer().withDefault(const Constant(0))();
  IntColumn get additionalWideRuns =>
      integer().withDefault(const Constant(0))();
  IntColumn get noBallRuns => integer().withDefault(const Constant(0))();
  IntColumn get byeRuns => integer().withDefault(const Constant(0))();
  IntColumn get legByeRuns => integer().withDefault(const Constant(0))();
  IntColumn get penaltyRuns => integer().withDefault(const Constant(0))();
  BoolColumn get isLegal => boolean().withDefault(const Constant(true))();
  BoolColumn get isBoundaryFour =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isBoundarySix =>
      boolean().withDefault(const Constant(false))();
  TextColumn get wicketType => text().nullable()();
  TextColumn get dismissedPlayerId => text().nullable()();
  TextColumn get fielderId => text().nullable()();
  BoolColumn get isReversed => boolean().withDefault(const Constant(false))();
  TextColumn get previousEventHash => text()();
  IntColumn get clientTimestamp => integer()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column> get primaryKey => {eventId};
}

class ScoringAuditTable extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  TextColumn get inningsId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class MatchSquadMembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  TextColumn get playerNameSnapshot => text()();
  BoolColumn get addedAfterMatchStart =>
      boolean().withDefault(const Constant(false))();
  IntColumn get joinedAt => integer()();
  TextColumn get joinedInningsId => text().nullable()();
  IntColumn get joinedOverNumber => integer().nullable()();
  IntColumn get joinedDeliverySequence => integer().nullable()();
  BoolColumn get isEligibleBowler =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  BoolColumn get addedToPermanentTeam =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get removedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {matchId, playerId};
}

class MatchAwardsTable extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  TextColumn get type => text()();
  TextColumn get playerId => text()();
  TextColumn get teamId => text()();
  TextColumn get playerNameSnapshot => text()();
  TextColumn get teamNameSnapshot => text()();
  TextColumn get summary => text()();
  TextColumn get secondarySummary => text().withDefault(const Constant(''))();
  RealColumn get rankingScore => real()();
  IntColumn get createdAt => integer()();
  BoolColumn get isManualOverride =>
      boolean().withDefault(const Constant(false))();
  TextColumn get overrideReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {matchId, type},
      ];
}

class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventId => text().unique()();
  TextColumn get matchId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // pending, syncing, synced, failed
  TextColumn get errorMessage => text().nullable()();
}

@DriftDatabase(tables: [
  TeamsTable,
  PlayersTable,
  TeamMembersTable,
  MatchesTable,
  DeliveriesTable,
  SyncQueueTable,
  ScoringAuditTable,
  MatchSquadMembersTable,
  MatchAwardsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(_singleActiveMatchIndexSql);
        },
        onUpgrade: (m, from, to) async {
          Future<bool> tableExists(String tableName) async {
            final rows = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
              variables: [Variable.withString(tableName)],
            ).get();
            return rows.isNotEmpty;
          }

          Future<bool> columnExists(String tableName, String columnName) async {
            final rows =
                await customSelect('PRAGMA table_info($tableName)').get();
            return rows.any((row) => row.read<String>('name') == columnName);
          }

          Future<void> safeCreateTable(TableInfo table) async {
            final exists = await tableExists(table.actualTableName);
            if (!exists) {
              await m.createTable(table);
            }
          }

          Future<void> safeAddColumn(
              TableInfo table, GeneratedColumn column) async {
            final exists =
                await columnExists(table.actualTableName, column.name);
            if (!exists) {
              try {
                await m.addColumn(table, column);
              } catch (e) {
                if (!e.toString().contains('duplicate column name')) {
                  rethrow;
                }
              }
            }
          }

          if (from < 2) {
            await safeAddColumn(teamsTable, teamsTable.city);
            await safeAddColumn(teamsTable, teamsTable.color);
            await safeAddColumn(playersTable, playersTable.jerseyNumber);
            await safeAddColumn(playersTable, playersTable.role);
            await safeAddColumn(playersTable, playersTable.isCaptain);
            await safeAddColumn(playersTable, playersTable.isWicketKeeper);
            await safeCreateTable(teamMembersTable);
            await safeAddColumn(matchesTable, matchesTable.matchName);
            await safeAddColumn(matchesTable, matchesTable.teamASquadJson);
            await safeAddColumn(matchesTable, matchesTable.teamBSquadJson);
          }
          if (from < 3) {
            await safeAddColumn(matchesTable, matchesTable.stateJson);
            await safeAddColumn(deliveriesTable, deliveriesTable.wideRuns);
            await safeAddColumn(deliveriesTable, deliveriesTable.noBallRuns);
            await safeAddColumn(deliveriesTable, deliveriesTable.byeRuns);
            await safeAddColumn(deliveriesTable, deliveriesTable.legByeRuns);
            await safeAddColumn(deliveriesTable, deliveriesTable.penaltyRuns);
            await safeAddColumn(
                deliveriesTable, deliveriesTable.sequenceInOver);
            await safeCreateTable(scoringAuditTable);
          }
          if (from < 4) {
            await safeAddColumn(teamsTable, teamsTable.defaultCaptainId);
            await safeAddColumn(matchesTable, matchesTable.teamACaptainId);
            await safeAddColumn(matchesTable, matchesTable.teamBCaptainId);
            await customStatement('''
              UPDATE teams_table
              SET default_captain_id = (
                SELECT p.id
                FROM players_table p
                INNER JOIN team_members_table tm ON tm.player_id = p.id
                WHERE tm.team_id = teams_table.id AND p.is_captain = 1
                ORDER BY p.created_at ASC
                LIMIT 1
              )
            ''');
            await customStatement('''
              UPDATE players_table
              SET is_captain = 0
              WHERE is_captain = 1
                AND EXISTS (
                  SELECT 1
                  FROM team_members_table tm
                  INNER JOIN teams_table t ON t.id = tm.team_id
                  WHERE tm.player_id = players_table.id
                    AND t.default_captain_id IS NOT players_table.id
                )
            ''');
          }
          if (from < 5) {
            await safeAddColumn(matchesTable, matchesTable.setupDraftJson);
          }
          if (from < 6) {
            await safeCreateTable(matchSquadMembersTable);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_match_squad_team '
              'ON match_squad_members_table(match_id, team_id)',
            );
          }
          if (from < 7) {
            await safeCreateTable(matchAwardsTable);
          }
          if (from < 8) {
            await safeAddColumn(teamMembersTable, teamMembersTable.isActive);
            await safeAddColumn(teamMembersTable, teamMembersTable.joinedAt);
            await safeAddColumn(teamMembersTable, teamMembersTable.removedAt);
            await safeAddColumn(
                matchSquadMembersTable, matchSquadMembersTable.isActive);
            await safeAddColumn(
                matchSquadMembersTable, matchSquadMembersTable.removedAt);
          }
          if (from < 9) {
            await customStatement('''
              UPDATE matches_table
              SET status = 'abandoned'
              WHERE status IN ($_activeStatusSqlList)
                AND id NOT IN (
                  SELECT id FROM matches_table
                  WHERE status IN ($_activeStatusSqlList)
                  ORDER BY created_at DESC
                  LIMIT 1
                )
            ''');
            await customStatement(_singleActiveMatchIndexSql);
          }
          if (from < 10) {
            await safeAddColumn(matchesTable, matchesTable.endReasonCode);
            await safeAddColumn(matchesTable, matchesTable.endReasonText);
            await safeAddColumn(matchesTable, matchesTable.endNote);
            await safeAddColumn(matchesTable, matchesTable.endedManually);
            await safeAddColumn(matchesTable, matchesTable.endedAt);
            await safeAddColumn(matchesTable, matchesTable.endedBy);
            await safeAddColumn(matchesTable, matchesTable.winnerTeamId);
            await safeAddColumn(matchesTable, matchesTable.loserTeamId);
            await safeAddColumn(matchesTable, matchesTable.resultType);
            await safeAddColumn(matchesTable, matchesTable.resultText);
          }
          if (from < 11) {
            await safeAddColumn(matchesTable, matchesTable.teamAWicketkeeperId);
            await safeAddColumn(matchesTable, matchesTable.teamBWicketkeeperId);
          }
          if (from < 12) {
            await safeAddColumn(matchesTable, matchesTable.totalOvers);
            await safeAddColumn(matchesTable, matchesTable.ballsPerOver);
            await safeAddColumn(matchesTable, matchesTable.maxOversPerBowler);
            await safeAddColumn(matchesTable, matchesTable.allowConsecutiveOvers);
            await safeAddColumn(
                matchesTable, matchesTable.maxOversWasManuallyEdited);
          }
          if (from < 13) {
            await safeAddColumn(
                deliveriesTable, deliveriesTable.additionalWideRuns);
            await customStatement('''
              UPDATE deliveries_table
              SET additional_wide_runs = CASE
                WHEN extras_type = 'wide' AND wide_runs > 1
                  THEN wide_runs - 1
                ELSE 0
              END
            ''');
          }
          if (from < 14) {
            await safeAddColumn(matchesTable, matchesTable.startedAt);
            await safeAddColumn(matchesTable, matchesTable.matchTimeZone);
          }
          if (from < 15) {
            await customStatement('''
              UPDATE players_table
              SET batting_style = 'notSet'
              WHERE batting_style IS NULL OR TRIM(batting_style) = ''
            ''');
            await customStatement('''
              UPDATE players_table
              SET bowling_style = 'notSet'
              WHERE bowling_style IS NULL OR TRIM(bowling_style) = ''
            ''');
          }
          if (from < 16) {
            await customStatement(
                'DROP INDEX IF EXISTS idx_single_active_match');
            await customStatement(_singleActiveMatchIndexSql);
          }
          if (from < 17) {
            await safeAddColumn(matchesTable, matchesTable.tossWinnerTeamId);
            await safeAddColumn(matchesTable, matchesTable.tossDecision);
            await safeAddColumn(matchesTable, matchesTable.tossCallingTeamId);
            await safeAddColumn(matchesTable, matchesTable.tossCall);
            await safeAddColumn(matchesTable, matchesTable.coinResult);
          }
          if (from < 18) {
            await safeAddColumn(matchesTable, matchesTable.updatedAt);
          }
        },
      );

  // --- Teams & Players ---
  Future<int> createTeam(TeamsTableCompanion team) =>
      into(teamsTable).insert(team);

  Future<List<TeamsTableData>> getAllTeams() =>
      (select(teamsTable)..where((t) => t.syncStatus.equals('archived').not()))
          .get();

  Stream<List<TeamsTableData>> watchActiveTeams() =>
      (select(teamsTable)..where((t) => t.syncStatus.equals('archived').not()))
          .watch();

  Future<List<TeamsTableData>> searchTeams(String query) => (select(teamsTable)
        ..where((t) =>
            t.syncStatus.equals('archived').not() &
            (t.name.contains(query) | t.shortName.contains(query))))
      .get();

  Future<TeamsTableData?> getTeamById(String id) =>
      (select(teamsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateTeam(TeamsTableCompanion team) =>
      update(teamsTable).replace(team);

  Future<int> archiveTeam(String id) =>
      (update(teamsTable)..where((t) => t.id.equals(id)))
          .write(const TeamsTableCompanion(syncStatus: Value('archived')));

  Future<int> deleteTeam(String id) =>
      (delete(teamsTable)..where((t) => t.id.equals(id))).go();

  Future<int> createPlayer(PlayersTableCompanion player) =>
      into(playersTable).insert(player);

  Future<bool> updatePlayer(PlayersTableCompanion player) =>
      update(playersTable).replace(player);

  Future<void> archivePlayerFromTeam(String teamId, String playerId) async {
    await transaction(() async {
      await (update(teamMembersTable)
            ..where((tm) =>
                tm.teamId.equals(teamId) & tm.playerId.equals(playerId)))
          .write(TeamMembersTableCompanion(
        isActive: const Value(false),
        removedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
      await (update(teamsTable)
            ..where((team) =>
                team.id.equals(teamId) &
                team.defaultCaptainId.equals(playerId)))
          .write(const TeamsTableCompanion(defaultCaptainId: Value(null)));
      await (update(playersTable)..where((p) => p.id.equals(playerId))).write(
        const PlayersTableCompanion(isCaptain: Value(false)),
      );
    });
  }

  Future<void> restorePlayerToTeam(String teamId, String playerId) =>
      (update(teamMembersTable)
            ..where((tm) =>
                tm.teamId.equals(teamId) & tm.playerId.equals(playerId)))
          .write(const TeamMembersTableCompanion(
        isActive: Value(true),
        removedAt: Value(null),
      ));

  Future<void> addPlayerToTeam(String teamId, String playerId) =>
      into(teamMembersTable).insert(
          TeamMembersTableCompanion(
            teamId: Value(teamId),
            playerId: Value(playerId),
            joinedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrReplace);

  Future<List<PlayersTableData>> getTeamPlayers(String teamId) async {
    final query = select(playersTable).join([
      innerJoin(teamMembersTable,
          teamMembersTable.playerId.equalsExp(playersTable.id)),
    ])
      ..where(teamMembersTable.teamId.equals(teamId) &
          teamMembersTable.isActive.equals(true));

    return query.map((row) => row.readTable(playersTable)).get();
  }

  Future<List<PlayersTableData>> getRemovedTeamPlayers(String teamId) {
    final query = select(playersTable).join([
      innerJoin(teamMembersTable,
          teamMembersTable.playerId.equalsExp(playersTable.id)),
    ])
      ..where(teamMembersTable.teamId.equals(teamId) &
          teamMembersTable.isActive.equals(false));
    return query.map((row) => row.readTable(playersTable)).get();
  }

  Future<void> setDefaultCaptain(String teamId, String playerId) async {
    await transaction(() async {
      final members = await getTeamPlayers(teamId);
      if (!members.any((player) => player.id == playerId)) {
        throw ArgumentError('Captain must belong to the selected team.');
      }
      for (final player in members) {
        final shouldBeCaptain = player.id == playerId;
        if (player.isCaptain != shouldBeCaptain) {
          await (update(playersTable)..where((row) => row.id.equals(player.id)))
              .write(
            PlayersTableCompanion(isCaptain: Value(shouldBeCaptain)),
          );
        }
      }
      await (update(teamsTable)..where((team) => team.id.equals(teamId)))
          .write(TeamsTableCompanion(defaultCaptainId: Value(playerId)));
    });
  }

  Stream<List<PlayersTableData>> watchTeamPlayers(String teamId) {
    final query = select(playersTable).join([
      innerJoin(teamMembersTable,
          teamMembersTable.playerId.equalsExp(playersTable.id)),
    ])
      ..where(teamMembersTable.teamId.equals(teamId) &
          teamMembersTable.isActive.equals(true));

    return query.map((row) => row.readTable(playersTable)).watch();
  }

  // --- Matches ---
  Expression<bool> _isActiveMatch(MatchesTable match) =>
      match.status.isIn(const [
        'setupCompleted',
        'ready',
        'tossCompleted',
        'live',
        'inningsReview',
        'inProgress',
        'inningsBreak',
        'matchReview',
        'awaitingNextBatter',
        'awaitingNextBowler',
        'paused',
        'secondInnings',
        'secondInningsSetup',
        'resultPending',
      ]);

  Future<int> createMatch(MatchesTableCompanion match) async {
    return transaction(() async {
      final status = match.status.present ? match.status.value : 'draft';
      final matchId = match.id.present ? match.id.value : null;
      if (_activeStatusValues.contains(status)) {
        final active = await (select(matchesTable)
              ..where((row) =>
                  _isActiveMatch(row) &
                  (matchId == null
                      ? const Constant(true)
                      : row.id.equals(matchId).not()))
              ..limit(1))
            .getSingleOrNull();
        if (active != null) {
          throw StateError(
            'Only one match can be active at a time. Finish the current match before starting another.',
          );
        }
      }
      return into(matchesTable).insertOnConflictUpdate(match);
    });
  }

  static const Set<String> _activeStatusValues = {
    'setupCompleted',
    'ready',
    'tossCompleted',
    'live',
    'inningsReview',
    'inProgress',
    'inningsBreak',
    'matchReview',
    'awaitingNextBatter',
    'awaitingNextBowler',
    'paused',
    'secondInnings',
    'secondInningsSetup',
    'resultPending',
  };

  static const String _activeStatusSqlList =
      "'setupCompleted','ready','tossCompleted','live','inProgress',"
      "'inningsReview','inningsBreak','matchReview',"
      "'awaitingNextBatter','awaitingNextBowler','paused',"
      "'secondInnings','secondInningsSetup','resultPending'";
  static const String _singleActiveMatchIndexSql =
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_single_active_match '
      'ON matches_table ((1)) WHERE status IN ($_activeStatusSqlList)';

  Future<List<MatchesTableData>> getAllMatches() => select(matchesTable).get();

  Future<MatchesTableData?> getActiveMatch({String? excludingMatchId}) =>
      (select(matchesTable)
            ..where((m) =>
                _isActiveMatch(m) &
                (excludingMatchId == null
                    ? const Constant(true)
                    : m.id.equals(excludingMatchId).not()))
            ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<bool> hasActiveMatch({String? excludingMatchId}) async =>
      await getActiveMatch(excludingMatchId: excludingMatchId) != null;

  Future<void> _ensureCanSetMatchStatus(String matchId, String status) async {
    if (!_activeStatusValues.contains(status)) return;
    if (await hasActiveMatch(excludingMatchId: matchId)) {
      throw StateError(
        'Only one match can be active at a time. Finish the current match before starting another.',
      );
    }
  }

  Stream<MatchesTableData?> watchActiveMatch() => (select(matchesTable)
        ..where(_isActiveMatch)
        ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
        ..limit(1))
      .watchSingleOrNull();

  Future<List<MatchesTableData>> getDraftMatches() =>
      (select(matchesTable)..where((m) => m.status.equals('draft'))).get();

  Stream<List<MatchesTableData>> watchDraftMatches() =>
      (select(matchesTable)..where((m) => m.status.equals('draft'))).watch();

  Future<void> deleteDraftMatch(String matchId) async {
    await transaction(() async {
      final match = await (select(matchesTable)..where((m) => m.id.equals(matchId))).getSingleOrNull();
      if (match == null) return;
      if (match.status != 'draft' && match.status != 'setupInProgress') {
        throw StateError('Only draft matches can be deleted.');
      }

      await (delete(matchSquadMembersTable)..where((s) => s.matchId.equals(matchId))).go();
      await (delete(deliveriesTable)..where((d) => d.matchId.equals(matchId))).go();
      await (delete(scoringAuditTable)..where((a) => a.matchId.equals(matchId))).go();
      await (delete(matchAwardsTable)..where((a) => a.matchId.equals(matchId))).go();
      await (delete(syncQueueTable)..where((sq) => sq.matchId.equals(matchId))).go();

      await (delete(matchesTable)..where((m) => m.id.equals(matchId))).go();
    });
  }

  Future<List<MatchesTableData>> getRecentMatches() => (select(matchesTable)
        ..where((m) => m.status
            .isIn(const ['completed', 'abandoned', 'noResult', 'cancelled']))
        ..orderBy([
          (m) => OrderingTerm(expression: m.endedAt, mode: OrderingMode.desc),
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .get();

  Stream<List<MatchesTableData>> watchRecentMatches() => (select(matchesTable)
        ..where((m) => m.status
            .isIn(const ['completed', 'abandoned', 'noResult', 'cancelled']))
        ..orderBy([
          (m) => OrderingTerm(expression: m.endedAt, mode: OrderingMode.desc),
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();

  Future<void> endMatchTransaction({
    required String matchId,
    required MatchesTableCompanion terminalFields,
    required String stateJson,
    required ScoringAuditTableCompanion audit,
    required SyncQueueTableCompanion syncItem,
  }) async {
    await transaction(() async {
      await (update(matchesTable)..where((match) => match.id.equals(matchId)))
          .write(terminalFields.copyWith(stateJson: Value(stateJson)));
      await into(scoringAuditTable)
          .insert(audit, mode: InsertMode.insertOrIgnore);
      await into(syncQueueTable)
          .insert(syncItem, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<MatchesTableData?> getMatchById(String id) =>
      (select(matchesTable)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> updateMatchStatus(String matchId, String status) async {
    return transaction(() async {
      await _ensureCanSetMatchStatus(matchId, status);
      return (update(matchesTable)..where((m) => m.id.equals(matchId)))
          .write(MatchesTableCompanion(status: Value(status)));
    });
  }

  Future<int> updateMatchSnapshot(
    String matchId,
    String status,
    String stateJson,
  ) async {
    return transaction(() async {
      await _ensureCanSetMatchStatus(matchId, status);
      return (update(matchesTable)..where((m) => m.id.equals(matchId))).write(
        MatchesTableCompanion(
          status: Value(status),
          stateJson: Value(stateJson),
        ),
      );
    });
  }

  Future<List<DeliveriesTableData>> getMatchDeliveries(String matchId) =>
      (select(deliveriesTable)
            ..where((d) => d.matchId.equals(matchId))
            ..orderBy([(d) => OrderingTerm.asc(d.eventSequence)]))
          .get();

  // --- Scoring Actions ---
  Future<void> saveDeliveryTransaction(
    DeliveriesTableCompanion delivery,
    SyncQueueTableCompanion syncItem,
    String matchId,
    String matchStatus,
    String stateJson,
  ) async {
    await transaction(() async {
      await into(deliveriesTable).insert(delivery);
      await into(syncQueueTable).insert(syncItem);
      await (update(matchesTable)..where((match) => match.id.equals(matchId)))
          .write(MatchesTableCompanion(
        status: Value(matchStatus),
        stateJson: Value(stateJson),
      ));
    });
  }

  Future<void> undoDeliveryTransaction(String eventId) async {
    await transaction(() async {
      await (delete(syncQueueTable)
            ..where((item) => item.eventId.equals(eventId)))
          .go();
      await (delete(deliveriesTable)
            ..where((delivery) => delivery.eventId.equals(eventId)))
          .go();
    });
  }

  Future<int> saveScoringAudit(ScoringAuditTableCompanion audit) =>
      into(scoringAuditTable).insert(audit);

  Future<void> saveLateSquadMemberTransaction(
    MatchSquadMembersTableCompanion member,
    ScoringAuditTableCompanion audit,
    SyncQueueTableCompanion syncItem,
  ) async {
    await transaction(() async {
      await into(matchSquadMembersTable).insert(member);
      await into(scoringAuditTable).insert(audit);
      await into(syncQueueTable).insert(syncItem);
    });
  }

  Future<List<MatchSquadMembersTableData>> getMatchSquadMembers(
    String matchId,
  ) =>
      (select(matchSquadMembersTable)
            ..where((member) => member.matchId.equals(matchId))
            ..orderBy([(member) => OrderingTerm.asc(member.joinedAt)]))
          .get();

  Future<void> saveSquadMemberStateTransaction({
    required String matchId,
    required String playerId,
    required bool isActive,
    required bool isAvailable,
    required int? removedAt,
    required ScoringAuditTableCompanion audit,
    required SyncQueueTableCompanion syncItem,
    required String matchStatus,
    required String stateJson,
  }) async {
    await transaction(() async {
      await (update(matchSquadMembersTable)
            ..where((member) =>
                member.matchId.equals(matchId) &
                member.playerId.equals(playerId)))
          .write(MatchSquadMembersTableCompanion(
        isActive: Value(isActive),
        isAvailable: Value(isAvailable),
        removedAt: Value(removedAt),
      ));
      await into(scoringAuditTable).insert(audit);
      await into(syncQueueTable).insert(syncItem);
      await (update(matchesTable)..where((match) => match.id.equals(matchId)))
          .write(MatchesTableCompanion(
        status: Value(matchStatus),
        stateJson: Value(stateJson),
      ));
    });
  }

  Future<void> replaceMatchAwards(
    String matchId,
    List<MatchAwardsTableCompanion> awards,
  ) async {
    await transaction(() async {
      await (delete(matchAwardsTable)
            ..where((award) => award.matchId.equals(matchId)))
          .go();
      for (final award in awards) {
        await into(matchAwardsTable).insert(award);
      }
    });
  }

  Future<void> saveCompletedSnapshotAndAwards(
    String matchId,
    String stateJson,
    int? endedAt,
    List<MatchAwardsTableCompanion> awards,
    List<SyncQueueTableCompanion> syncItems,
  ) async {
    await transaction(() async {
      await (update(matchesTable)..where((match) => match.id.equals(matchId)))
          .write(MatchesTableCompanion(
        status: const Value('completed'),
        stateJson: Value(stateJson),
        endedAt: Value(endedAt),
      ));
      await (delete(matchAwardsTable)
            ..where((award) => award.matchId.equals(matchId)))
          .go();
      for (final award in awards) {
        await into(matchAwardsTable).insert(award);
      }
      for (final item in syncItems) {
        await into(syncQueueTable)
            .insert(item, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<List<MatchAwardsTableData>> getMatchAwards(String matchId) =>
      (select(matchAwardsTable)
            ..where((award) => award.matchId.equals(matchId))
            ..orderBy([(award) => OrderingTerm.asc(award.type)]))
          .get();

  Future<List<SyncQueueTableData>> getPendingSyncItems() {
    return (select(syncQueueTable)..where((t) => t.status.equals('pending')))
        .get();
  }

  Future<void> updateSyncItemStatus(int id, String status, {String? error}) {
    return (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        status: Value(status),
        errorMessage: Value(error),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cricket_local_scoring.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
