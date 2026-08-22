import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../local/database.dart';
import '../../main.dart';
import '../../core/validation/match_setup_validation.dart';

enum LatePlayerAddMode { currentMatchOnly, teamAndCurrentMatch }

final matchRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return MatchRepository(db);
});

final activeMatchStreamProvider = StreamProvider<MatchesTableData?>((ref) {
  final repo = ref.watch(matchRepositoryProvider);
  return repo.watchActiveMatch();
});

final draftMatchesStreamProvider =
    StreamProvider<List<MatchesTableData>>((ref) {
  final repo = ref.watch(matchRepositoryProvider);
  return repo.watchDraftMatches();
});

final recentMatchesStreamProvider =
    StreamProvider<List<MatchesTableData>>((ref) {
  final repo = ref.watch(matchRepositoryProvider);
  return repo.watchRecentMatches();
});

final matchAwardsProvider =
    FutureProvider.family<List<MatchAward>, String>((ref, matchId) {
  return ref.read(matchRepositoryProvider).loadMatchAwards(matchId);
});

class MatchRepository {
  final AppDatabase _db;

  MatchRepository(this._db);

  Stream<MatchesTableData?> watchActiveMatch() => _db.watchActiveMatch();

  Stream<List<MatchesTableData>> watchDraftMatches() => _db.watchDraftMatches();

  Stream<List<MatchesTableData>> watchRecentMatches() =>
      _db.watchRecentMatches();

  Future<void> saveMatch({
    required String id,
    String? matchName,
    required String teamAId,
    required String teamBId,
    required String format,
    int? totalOvers,
    int? ballsPerOver,
    int? maxOversPerBowler,
    bool? allowConsecutiveOvers,
    bool? maxOversWasManuallyEdited,
    String? venueName,
    required int scheduledAt,
    int? startedAt,
    String? matchTimeZone,
    String? tossWinnerTeamId,
    String? tossDecision,
    String? tossCallingTeamId,
    String? tossCall,
    String? coinResult,
    String? teamASquadJson,
    String? teamBSquadJson,
    String? teamACaptainId,
    String? teamBCaptainId,
    String? teamAWicketkeeperId,
    String? teamBWicketkeeperId,
    String? setupDraftJson,
    String status = 'draft',
    required String currentScorerDeviceId,
  }) async {
    if (status == 'live') {
      final teamAPlayers = await _db.getTeamPlayers(teamAId);
      final teamBPlayers = await _db.getTeamPlayers(teamBId);
      final selectedA = teamASquadJson == null
          ? teamAPlayers.map((player) => player.id).toSet()
          : (jsonDecode(teamASquadJson) as List<dynamic>)
              .map((id) => id as String)
              .toSet();
      final selectedB = teamBSquadJson == null
          ? teamBPlayers.map((player) => player.id).toSet()
          : (jsonDecode(teamBSquadJson) as List<dynamic>)
              .map((id) => id as String)
              .toSet();
      final validA = teamAPlayers
          .where((player) => selectedA.contains(player.id))
          .toList();
      final validB = teamBPlayers
          .where((player) => selectedB.contains(player.id))
          .toList();
      if (validA.length < 2 || validB.length < 2) {
        throw const MatchSetupValidationException(
          'Both selected teams need at least two playing members.',
        );
      }
      if (teamACaptainId == null ||
          teamBCaptainId == null ||
          !selectedA.contains(teamACaptainId) ||
          !selectedB.contains(teamBCaptainId)) {
        throw const MatchSetupValidationException(
          'Select exactly one captain for each team before starting the match.',
        );
      }
    }
    final existing = await _db.getMatchById(id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final createdAtValue = existing?.createdAt ?? now;
    final startedAtValue = startedAt ??
        (status == 'live' ? (existing?.startedAt ?? now) : existing?.startedAt);

    await _db.createMatch(MatchesTableCompanion(
      id: Value(id),
      matchName: Value(matchName),
      teamAId: Value(teamAId),
      teamBId: Value(teamBId),
      format: Value(format),
      totalOvers: Value(totalOvers),
      ballsPerOver: Value(ballsPerOver),
      maxOversPerBowler: Value(maxOversPerBowler),
      allowConsecutiveOvers: Value(allowConsecutiveOvers),
      maxOversWasManuallyEdited: Value(maxOversWasManuallyEdited),
      venueName: Value(venueName),
      scheduledAt: Value(scheduledAt),
      startedAt: Value(startedAtValue),
      matchTimeZone: Value(matchTimeZone ?? DateTime.now().timeZoneName),
      tossWinnerTeamId: Value(tossWinnerTeamId),
      tossDecision: Value(tossDecision),
      tossCallingTeamId: Value(tossCallingTeamId),
      tossCall: Value(tossCall),
      coinResult: Value(coinResult),
      teamASquadJson: Value(teamASquadJson),
      teamBSquadJson: Value(teamBSquadJson),
      teamACaptainId: Value(teamACaptainId),
      teamBCaptainId: Value(teamBCaptainId),
      teamAWicketkeeperId: Value(teamAWicketkeeperId),
      teamBWicketkeeperId: Value(teamBWicketkeeperId),
      setupDraftJson: Value(setupDraftJson),
      status: Value(status),
      currentScorerDeviceId: Value(currentScorerDeviceId),
      createdAt: Value(createdAtValue),
      updatedAt: Value(now),
    ));
  }

  Future<MatchesTableData?> getActiveMatch() => _db.getActiveMatch();

  Future<bool> hasActiveMatch({String? excludingMatchId}) =>
      _db.hasActiveMatch(excludingMatchId: excludingMatchId);

  Future<List<MatchesTableData>> getDraftMatches() => _db.getDraftMatches();

  Future<void> deleteDraftMatch(String matchId) => _db.deleteDraftMatch(matchId);

  Future<List<MatchesTableData>> getRecentMatches() => _db.getRecentMatches();

  Future<List<MatchesTableData>> getAllMatches() => _db.getAllMatches();

  Future<MatchesTableData?> getMatchRecord(String matchId) =>
      _db.getMatchById(matchId);

  Future<void> validateCanRecordDelivery(String matchId) async {
    final record = await _db.getMatchById(matchId);
    if (record == null || record.stateJson == null) {
      throw StateError('No active scoring state exists for this match.');
    }
    final state = MatchState.fromJson(
      jsonDecode(record.stateJson!) as Map<String, dynamic>,
    );
    CricketScoringEngine(state).validateCanRecordDelivery();
  }

  Future<int> updateMatchStatus(String matchId, String status) =>
      _db.updateMatchStatus(matchId, status);

  Future<void> persistState(MatchState state) async {
    if (state.status == MatchStatus.completed) {
      var completedState = state;
      if (!completedState.endedManually && completedState.awards.isEmpty) {
        final calculated =
            const MatchAwardsService().calculateAwards(completedState);
        completedState = completedState.copyWith(awards: calculated.awards);
      }
      await _db.saveCompletedSnapshotAndAwards(
        completedState.matchId,
        jsonEncode(completedState.toJson()),
        completedState.endedAt,
        completedState.awards.map(_awardCompanion).toList(),
        completedState.awards.map(_awardSyncCompanion).toList(),
      );
      return;
    }
    await _db.updateMatchSnapshot(
      state.matchId,
      state.status.name,
      jsonEncode(state.toJson()),
    );
  }

  Future<void> persistManualEnd(MatchState state) async {
    if (!state.endedManually || state.endedAt == null) {
      throw ArgumentError('The match does not contain a manual end outcome.');
    }
    final eventId = 'manual_end_${state.matchId}_${state.endedAt}';
    final payload = {
      'type': 'MATCH_ENDED_MANUALLY',
      'eventId': eventId,
      'matchId': state.matchId,
      'outcome': state.manualEndOutcome?.name,
      'reason': state.endReasonCode?.name,
      'reasonText': state.endReasonText,
      'note': state.endNote,
      'score': state.activeInnings.totalRuns,
      'wickets': state.activeInnings.totalWickets,
      'innings': state.activeInnings.inningsNumber,
      'legalBalls': state.activeInnings.legalBallsBowled,
      'endedBy': state.endedBy,
      'endedAt': state.endedAt,
    };
    await _db.endMatchTransaction(
      matchId: state.matchId,
      terminalFields: MatchesTableCompanion(
        status: Value(state.status.name),
        endReasonCode: Value(state.endReasonCode?.name),
        endReasonText: Value(state.endReasonText),
        endNote: Value(state.endNote),
        endedManually: const Value(true),
        endedAt: Value(state.endedAt),
        endedBy: Value(state.endedBy),
        winnerTeamId: Value(state.result?.winnerTeamId),
        loserTeamId: Value(state.loserTeamId),
        resultType: Value(state.resultType),
        resultText: Value(state.manualResultText),
      ),
      stateJson: jsonEncode(state.toJson()),
      audit: ScoringAuditTableCompanion.insert(
        id: 'audit_$eventId',
        matchId: state.matchId,
        inningsId: state.activeInnings.inningsId,
        action: 'MATCH_ENDED_MANUALLY',
        payloadJson: jsonEncode(payload),
        createdAt: state.endedAt!,
      ),
      syncItem: SyncQueueTableCompanion.insert(
        eventId: eventId,
        matchId: state.matchId,
        payloadJson: jsonEncode(payload),
      ),
    );
  }

  Future<void> persistManualReopen({
    required MatchState state,
    required String reason,
    required String reopenedBy,
  }) async {
    if (await hasActiveMatch(excludingMatchId: state.matchId)) {
      throw StateError('Another match is already active.');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final eventId = 'manual_reopen_${state.matchId}_$now';
    final payload = {
      'type': 'MATCH_REOPENED',
      'eventId': eventId,
      'matchId': state.matchId,
      'reason': reason,
      'reopenedBy': reopenedBy,
      'reopenedAt': now,
    };
    await _db.endMatchTransaction(
      matchId: state.matchId,
      terminalFields: MatchesTableCompanion(
        status: Value(state.status.name),
        endReasonCode: const Value(null),
        endReasonText: const Value(null),
        endNote: const Value(null),
        endedManually: const Value(false),
        endedAt: const Value(null),
        endedBy: const Value(null),
        winnerTeamId: const Value(null),
        loserTeamId: const Value(null),
        resultType: const Value(null),
        resultText: const Value(null),
      ),
      stateJson: jsonEncode(state.toJson()),
      audit: ScoringAuditTableCompanion.insert(
        id: 'audit_$eventId',
        matchId: state.matchId,
        inningsId: state.activeInnings.inningsId,
        action: 'MATCH_REOPENED',
        payloadJson: jsonEncode(payload),
        createdAt: now,
      ),
      syncItem: SyncQueueTableCompanion.insert(
        eventId: eventId,
        matchId: state.matchId,
        payloadJson: jsonEncode(payload),
      ),
    );
  }

  MatchAwardsTableCompanion _awardCompanion(MatchAward award) =>
      MatchAwardsTableCompanion.insert(
        id: award.id,
        matchId: award.matchId,
        type: award.type.name,
        playerId: award.playerId,
        teamId: award.teamId,
        playerNameSnapshot: award.playerNameSnapshot,
        teamNameSnapshot: award.teamNameSnapshot,
        summary: award.summary,
        secondarySummary: Value(award.secondarySummary),
        rankingScore: award.rankingScore,
        createdAt: award.createdAt,
        isManualOverride: Value(award.isManualOverride),
        overrideReason: Value(award.overrideReason),
      );

  SyncQueueTableCompanion _awardSyncCompanion(MatchAward award) =>
      SyncQueueTableCompanion.insert(
        eventId: award.id,
        matchId: award.matchId,
        payloadJson: jsonEncode({
          'type': 'MATCH_AWARD_UPSERTED',
          'award': award.toJson(),
        }),
      );

  Future<List<MatchAward>> loadMatchAwards(String matchId) async {
    final rows = await _db.getMatchAwards(matchId);
    return rows
        .map((row) => MatchAward(
              id: row.id,
              matchId: row.matchId,
              type: MatchAwardType.values.firstWhere(
                (type) => type.name == row.type,
              ),
              playerId: row.playerId,
              teamId: row.teamId,
              playerNameSnapshot: row.playerNameSnapshot,
              teamNameSnapshot: row.teamNameSnapshot,
              summary: row.summary,
              secondarySummary: row.secondarySummary,
              rankingScore: row.rankingScore,
              createdAt: row.createdAt,
              isManualOverride: row.isManualOverride,
              overrideReason: row.overrideReason,
            ))
        .toList();
  }

  Future<MatchAwardsResult> recalculateMatchAwards(String matchId) async {
    final state = await getMatchState(matchId);
    if (state == null || state.status != MatchStatus.completed) {
      return const MatchAwardsResult();
    }
    final result = const MatchAwardsService().calculateAwards(state);
    final updated = state.copyWith(awards: result.awards);
    await _db.saveCompletedSnapshotAndAwards(
      matchId,
      jsonEncode(updated.toJson()),
      updated.endedAt,
      result.awards.map(_awardCompanion).toList(),
      result.awards.map(_awardSyncCompanion).toList(),
    );
    return result;
  }

  Future<void> persistDelivery(
    DeliveryEvent event,
    MatchState state,
  ) async {
    final payload = jsonEncode(event.toJson());
    await _db.saveDeliveryTransaction(
      DeliveriesTableCompanion.insert(
        eventId: event.eventId,
        matchId: event.matchId,
        inningsId: event.inningsId,
        overNumber: event.overNumber,
        legalBallNumber: event.legalBallNumber,
        eventSequence: event.eventSequence,
        sequenceInOver: Value(event.sequenceInOver),
        scorerDeviceId: event.scorerDeviceId,
        strikerId: event.strikerId,
        nonStrikerId: event.nonStrikerId,
        bowlerId: event.bowlerId,
        runsBatter: Value(event.runsBatter),
        extrasType: Value(event.extrasType.name),
        extrasRuns: Value(event.extrasRuns),
        wideRuns: Value(event.wideRuns),
        additionalWideRuns: Value(event.additionalWideRuns),
        noBallRuns: Value(event.noBallRuns),
        byeRuns: Value(event.byeRuns),
        legByeRuns: Value(event.legByeRuns),
        penaltyRuns: Value(event.penaltyRuns),
        isLegal: Value(event.isLegal),
        isBoundaryFour: Value(event.isBoundaryFour),
        isBoundarySix: Value(event.isBoundarySix),
        wicketType: Value(event.wicket?.type.name),
        dismissedPlayerId: Value(event.wicket?.dismissedPlayerId),
        fielderId: Value(event.wicket?.fielderId),
        previousEventHash: event.previousEventHash,
        clientTimestamp: event.clientTimestamp,
      ),
      SyncQueueTableCompanion.insert(
        eventId: event.eventId,
        matchId: event.matchId,
        payloadJson: payload,
      ),
      state.matchId,
      state.status.name,
      jsonEncode(state.toJson()),
    );
    await persistState(state);
  }

  Future<void> undoDelivery(
    String eventId,
    MatchState state,
  ) async {
    await _db.undoDeliveryTransaction(eventId);
    await persistState(state);
  }

  Future<void> persistAudit({
    required MatchState state,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().microsecondsSinceEpoch;
    await _db.saveScoringAudit(
      ScoringAuditTableCompanion.insert(
        id: 'audit_$now',
        matchId: state.matchId,
        inningsId: state.activeInnings.inningsId,
        action: action,
        payloadJson: jsonEncode(payload),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await persistState(state);
  }

  Future<void> persistLatePlayer({
    required MatchState state,
    required String teamId,
    required Player player,
    required LatePlayerAddMode mode,
    required String addedBy,
    String? reason,
  }) async {
    final active = state.activeInnings;
    final eventId = 'late_player_${state.matchId}_${player.id}';
    final payload = <String, dynamic>{
      'type': 'PLAYER_ADDED_DURING_MATCH',
      'matchId': state.matchId,
      'inningsId': active.inningsId,
      'teamId': teamId,
      'playerId': player.id,
      'playerName': player.name,
      'addedMode': mode.name,
      'addedBy': addedBy,
      'addedAt': player.joinedAt,
      'currentScore': active.totalRuns,
      'currentOver': active.legalBallsBowled ~/ state.config.ballsPerOver,
      'joinedDeliverySequence': player.joinedDeliverySequence,
      'reason': reason,
    };
    await _db.saveLateSquadMemberTransaction(
      MatchSquadMembersTableCompanion.insert(
        id: eventId,
        matchId: state.matchId,
        teamId: teamId,
        playerId: player.id,
        playerNameSnapshot: player.name,
        addedAfterMatchStart: const Value(true),
        joinedAt: player.joinedAt ?? DateTime.now().millisecondsSinceEpoch,
        joinedInningsId: Value(player.joinedInningsId),
        joinedOverNumber: Value(player.joinedOverNumber),
        joinedDeliverySequence: Value(player.joinedDeliverySequence),
        isEligibleBowler: Value(player.isEligibleBowler),
        isAvailable: Value(player.isAvailable),
        addedToPermanentTeam:
            Value(mode == LatePlayerAddMode.teamAndCurrentMatch),
      ),
      ScoringAuditTableCompanion.insert(
        id: 'audit_$eventId',
        matchId: state.matchId,
        inningsId: active.inningsId,
        action: 'PLAYER_ADDED_DURING_MATCH',
        payloadJson: jsonEncode(payload),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      SyncQueueTableCompanion.insert(
        eventId: eventId,
        matchId: state.matchId,
        payloadJson: jsonEncode(payload),
      ),
    );
    await persistState(state);
  }

  Future<List<MatchSquadMembersTableData>> getLiveSquadChanges(
    String matchId,
  ) =>
      _db.getMatchSquadMembers(matchId);

  Future<void> persistSquadPlayerState({
    required MatchState state,
    required String teamId,
    required String playerId,
    required bool isActive,
    required bool isAvailable,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final eventId =
        'squad_state_${state.matchId}_${playerId}_${now.toString()}';
    final action = isActive
        ? (isAvailable ? 'PLAYER_MARKED_AVAILABLE' : 'PLAYER_UNAVAILABLE')
        : 'MATCH_SQUAD_PLAYER_REMOVED';
    final payload = {
      'type': action,
      'matchId': state.matchId,
      'teamId': teamId,
      'playerId': playerId,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'changedAt': now,
    };
    await _db.saveSquadMemberStateTransaction(
      matchId: state.matchId,
      playerId: playerId,
      isActive: isActive,
      isAvailable: isAvailable,
      removedAt: isActive ? null : now,
      audit: ScoringAuditTableCompanion.insert(
        id: 'audit_$eventId',
        matchId: state.matchId,
        inningsId: state.activeInnings.inningsId,
        action: action,
        payloadJson: jsonEncode(payload),
        createdAt: now,
      ),
      syncItem: SyncQueueTableCompanion.insert(
        eventId: eventId,
        matchId: state.matchId,
        payloadJson: jsonEncode(payload),
      ),
      matchStatus: state.status.name,
      stateJson: jsonEncode(state.toJson()),
    );
  }

  Future<MatchState?> getMatchState(String matchId) async {
    final m = await _db.getMatchById(matchId);
    if (m == null) return null;

    if (m.stateJson != null && m.stateJson!.isNotEmpty) {
      try {
        final restored = MatchState.fromJson(
          jsonDecode(m.stateJson!) as Map<String, dynamic>,
        );
        return restored.copyWith(
          scheduledAt: restored.scheduledAt ?? m.scheduledAt,
          startedAt: restored.startedAt ?? m.startedAt,
          createdAt: restored.createdAt ?? m.createdAt,
          venueName: restored.venueName ?? m.venueName,
          matchTimeZone: restored.matchTimeZone ?? m.matchTimeZone,
          endedAt: restored.endedAt ?? m.endedAt,
        );
      } catch (_) {
        // Older/corrupt snapshots fall back to delivery reconstruction below.
      }
    }

    final teamAData = await _db.getTeamById(m.teamAId);
    final teamBData = await _db.getTeamById(m.teamBId);
    if (teamAData == null || teamBData == null) return null;

    final playersAData = await _db.getTeamPlayers(m.teamAId);
    final playersBData = await _db.getTeamPlayers(m.teamBId);

    final selectedA = m.teamASquadJson == null
        ? playersAData.map((player) => player.id).toSet()
        : (jsonDecode(m.teamASquadJson!) as List<dynamic>)
            .map((id) => id as String)
            .toSet();
    final selectedB = m.teamBSquadJson == null
        ? playersBData.map((player) => player.id).toSet()
        : (jsonDecode(m.teamBSquadJson!) as List<dynamic>)
            .map((id) => id as String)
            .toSet();
    final playersA = playersAData
        .where((player) => selectedA.contains(player.id))
        .map((p) => Player(id: p.id, name: p.name))
        .toList();
    final playersB = playersBData
        .where((player) => selectedB.contains(player.id))
        .map((p) => Player(id: p.id, name: p.name))
        .toList();

    final teamA = Team(
        id: teamAData.id,
        name: teamAData.name,
        shortName: teamAData.shortName,
        players: playersA);
    final teamB = Team(
        id: teamBData.id,
        name: teamBData.name,
        shortName: teamBData.shortName,
        players: playersB);

    final config = const MatchConfig(
        format: MatchFormat.t20,
        totalOvers: 20,
        ballsPerOver: 6,
        maxOversPerBowler: 4);
    final tossWinner = m.tossWinnerTeamId ?? teamA.id;
    final tossDecision = m.tossDecision ?? 'BAT';

    final deliveries = await _db.getMatchDeliveries(matchId);

    String p1 = playersA.isNotEmpty ? playersA[0].id : 'p1';
    String p2 = playersA.length > 1 ? playersA[1].id : 'p2';
    String b1 = playersB.isNotEmpty ? playersB[0].id : 'b1';

    if (deliveries.isNotEmpty) {
      p1 = deliveries.first.strikerId;
      p2 = deliveries.first.nonStrikerId;
      b1 = deliveries.first.bowlerId;
    }

    final engine = CricketScoringEngine.createMatch(
      matchId: m.id,
      config: config,
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: tossWinner,
      tossDecision: tossDecision,
      tossCallingTeamId: m.tossCallingTeamId,
      tossCall: m.tossCall,
      coinResult: m.coinResult,
      openingStrikerId: p1,
      openingNonStrikerId: p2,
      openingBowlerId: b1,
      teamRoleSnapshots: [
        if (m.teamACaptainId != null)
          MatchTeamRoleSnapshot(
            teamId: teamA.id,
            captainPlayerId: m.teamACaptainId!,
            wicketkeeperPlayerId: m.teamAWicketkeeperId,
          ),
        if (m.teamBCaptainId != null)
          MatchTeamRoleSnapshot(
            teamId: teamB.id,
            captainPlayerId: m.teamBCaptainId!,
            wicketkeeperPlayerId: m.teamBWicketkeeperId,
          ),
      ],
      scheduledAt: m.scheduledAt,
      startedAt: m.startedAt,
      createdAt: m.createdAt,
      venueName: m.venueName,
      matchTimeZone: m.matchTimeZone,
    );

    for (final d in deliveries) {
      if (engine.state.status == MatchStatus.completed) break;

      ExtrasType extras = ExtrasType.none;
      if (d.extrasType == 'wide') extras = ExtrasType.wide;
      if (d.extrasType == 'noBall') extras = ExtrasType.noBall;
      if (d.extrasType == 'bye') extras = ExtrasType.bye;
      if (d.extrasType == 'legBye') extras = ExtrasType.legBye;
      if (d.extrasType == 'penalty') extras = ExtrasType.penalty;

      WicketDetail? wicket;
      if (d.wicketType != null) {
        WicketType wt = WicketType.bowled;
        try {
          wt = WicketType.values.firstWhere((e) => e.name == d.wicketType);
        } catch (_) {}

        wicket = WicketDetail(
          type: wt,
          dismissedPlayerId:
              d.dismissedPlayerId ?? engine.state.activeInnings.strikerId,
          fielderId: d.fielderId,
        );
      }

      try {
        engine.recordDelivery(
          eventId: d.eventId,
          scorerDeviceId: d.scorerDeviceId,
          runsBatter: d.runsBatter,
          extrasType: extras,
          extrasRuns: d.extrasRuns,
          wideRuns: d.wideRuns > 0
              ? d.wideRuns
              : (extras == ExtrasType.wide
                  ? (d.extrasRuns > 0 ? d.extrasRuns : 1)
                  : 0),
          additionalWideRuns: d.additionalWideRuns,
          noBallRuns: d.noBallRuns > 0
              ? d.noBallRuns
              : (extras == ExtrasType.noBall ? 1 : 0),
          byeRuns: d.byeRuns > 0
              ? d.byeRuns
              : (extras == ExtrasType.bye ? d.extrasRuns : 0),
          legByeRuns: d.legByeRuns > 0
              ? d.legByeRuns
              : (extras == ExtrasType.legBye ? d.extrasRuns : 0),
          penaltyRuns: d.penaltyRuns > 0
              ? d.penaltyRuns
              : (extras == ExtrasType.penalty ? d.extrasRuns : 0),
          isBoundaryFour: d.isBoundaryFour,
          isBoundarySix: d.isBoundarySix,
          wicket: wicket,
        );
      } catch (_) {}
    }

    MatchStatus status = MatchStatus.live;
    if (m.status == 'inningsReview' ||
        engine.state.status == MatchStatus.inningsReview) {
      status = MatchStatus.inningsReview;
    }
    if (m.status == 'inningsBreak') status = MatchStatus.inningsBreak;
    if (m.status == 'matchReview' ||
        engine.state.status == MatchStatus.matchReview) {
      status = MatchStatus.matchReview;
    }
    if (m.status == 'completed' || engine.state.status == MatchStatus.completed)
      status = MatchStatus.completed;

    return engine.state.copyWith(status: status);
  }
}
