import 'models/match_config.dart';
import 'models/player.dart';
import 'models/team.dart';
import 'models/delivery_event.dart';
import 'models/innings_state.dart';
import 'models/match_state.dart';
import 'models/scorecard.dart';
import 'models/match_award.dart';
import 'models/bowling_segment.dart';
import 'models/match_team_role_snapshot.dart';
import 'rules/strike_rotation.dart';
import 'rules/extras_handler.dart';
import 'rules/wicket_handler.dart';
import 'services/innings_completion_evaluator.dart';

class CricketScoringEngine {
  MatchState _state;
  final List<DeliveryEvent> _undoStack = [];
  final List<MatchState> _stateHistory = [];

  CricketScoringEngine(MatchState state) : _state = state {
    // Upgrade snapshots written before squad-based wicket limits existed.
    final innings = state.innings.map((item) {
      final restoredBattingOrder = item.battingOrder.isNotEmpty
          ? item.battingOrder
          : _reconstructBattingOrder(state, item);
      if (item.playingMemberCountSnapshot > 0 && item.maximumWickets > 0) {
        return item.copyWith(battingOrder: restoredBattingOrder);
      }
      final team =
          item.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
      return item.copyWith(
        playingMemberCountSnapshot: team.players.length,
        maximumWickets: InningsCompletionEvaluator.calculateMaximumWickets(
          playingMemberCount: team.players.length,
        ),
        battingOrder: restoredBattingOrder,
      );
    }).toList();
    _state = state.copyWith(innings: innings);
  }

  static List<String> _reconstructBattingOrder(
      MatchState state, InningsState innings) {
    final order = <String>[];
    void add(String id) {
      if (id.isNotEmpty && !order.contains(id)) order.add(id);
    }

    final events = state.events
        .where((event) => event.inningsId == innings.inningsId)
        .toList()
      ..sort((a, b) => a.eventSequence.compareTo(b.eventSequence));
    for (final event in events) {
      add(event.strikerId);
      add(event.nonStrikerId);
      if (event.wicket != null) add(event.wicket!.dismissedPlayerId);
    }
    if (order.isEmpty) {
      add(innings.strikerId);
      add(innings.nonStrikerId);
    } else {
      add(innings.strikerId);
      add(innings.nonStrikerId);
    }
    return order;
  }

  MatchState get state => _state;

  void restoreState(MatchState state) => _state = state;

  void setAwards(List<MatchAward> awards) {
    if (_state.status != MatchStatus.completed) {
      throw StateError('Awards can only be attached to a completed match.');
    }
    _state = _state.copyWith(awards: List.unmodifiable(awards));
  }

  void endMatchManually({
    required MatchEndOutcome outcome,
    required MatchEndReason reason,
    required String reasonText,
    required String endedBy,
    String? note,
    String? winnerTeamId,
    String? forfeitingTeamId,
    String? resultType,
    String? resultText,
    bool isTie = false,
  }) {
    if (_state.status != MatchStatus.live &&
        _state.status != MatchStatus.inningsBreak &&
        _state.status != MatchStatus.paused) {
      throw StateError('Only an active match can be ended manually.');
    }
    if (reason == MatchEndReason.other &&
        (note == null || note.trim().isEmpty)) {
      throw ArgumentError('A note is required for Other.');
    }
    if (outcome == MatchEndOutcome.teamForfeit &&
        (forfeitingTeamId == null || winnerTeamId == null)) {
      throw ArgumentError('Forfeit requires forfeiting and winning teams.');
    }
    if (outcome == MatchEndOutcome.manuallyCompleted &&
        !isTie &&
        winnerTeamId == null) {
      throw ArgumentError('A manual result requires a winner or tie.');
    }

    final status = switch (outcome) {
      MatchEndOutcome.abandoned => MatchStatus.abandoned,
      MatchEndOutcome.noResult => MatchStatus.noResult,
      MatchEndOutcome.cancelled => MatchStatus.cancelled,
      MatchEndOutcome.teamForfeit ||
      MatchEndOutcome.manuallyCompleted =>
        MatchStatus.completed,
    };
    final winnerName = winnerTeamId == _state.teamA.id
        ? _state.teamA.name
        : winnerTeamId == _state.teamB.id
            ? _state.teamB.name
            : null;
    final forfeitingName = forfeitingTeamId == _state.teamA.id
        ? _state.teamA.name
        : forfeitingTeamId == _state.teamB.id
            ? _state.teamB.name
            : null;
    final text = resultText ??
        switch (outcome) {
          MatchEndOutcome.abandoned =>
            'Match abandoned due to ${reasonText.toLowerCase()}.',
          MatchEndOutcome.noResult =>
            'Match ended with no result due to ${reasonText.toLowerCase()}.',
          MatchEndOutcome.cancelled =>
            'Match cancelled due to ${reasonText.toLowerCase()}.',
          MatchEndOutcome.teamForfeit =>
            '$forfeitingName forfeited the match. $winnerName won by forfeit.',
          MatchEndOutcome.manuallyCompleted =>
            isTie ? 'Match tied.' : '$winnerName won. ${note ?? ''}'.trim(),
        };
    final matchResult = outcome == MatchEndOutcome.abandoned ||
            outcome == MatchEndOutcome.noResult ||
            outcome == MatchEndOutcome.cancelled
        ? null
        : MatchResult(
            winnerTeamId: isTie ? '' : winnerTeamId!,
            resultString: text,
            isTie: isTie,
          );
    _state = _state.copyWith(
      status: status,
      result: matchResult,
      manualEndOutcome: outcome,
      endReasonCode: reason,
      endReasonText: reasonText,
      endNote: note,
      endedManually: true,
      endedAt: DateTime.now().millisecondsSinceEpoch,
      endedBy: endedBy,
      loserTeamId: forfeitingTeamId,
      resultType: resultType ?? outcome.name,
      manualResultText: text,
      statusBeforeManualEnd: _state.status,
    );
  }

  void reopenManuallyEndedMatch() {
    if (!_state.endedManually || _state.statusBeforeManualEnd == null) {
      throw StateError('This match was not ended manually.');
    }
    final restoreStatus = _state.statusBeforeManualEnd!;
    if (restoreStatus != MatchStatus.live &&
        restoreStatus != MatchStatus.inningsBreak &&
        restoreStatus != MatchStatus.paused) {
      throw StateError('The saved scoring state cannot be reopened.');
    }
    _state = _state.copyWith(
      status: restoreStatus,
      clearManualEnd: true,
      clearResult: true,
      awards: const [],
    );
  }

  /// Adds a player to one active-match team without changing scoring state.
  void addLatePlayer({required String teamId, required Player player}) {
    if (_state.status != MatchStatus.live &&
        _state.status != MatchStatus.inningsBreak) {
      throw StateError('Players can only join a live match.');
    }
    final rules = _state.config.latePlayerRules;
    if (!rules.allowLatePlayers) {
      throw StateError('Late player additions are disabled for this match.');
    }
    if (teamId != _state.teamA.id && teamId != _state.teamB.id) {
      throw ArgumentError('The selected team does not belong to this match.');
    }
    if (_state.teamA.players.any((p) => p.id == player.id) ||
        _state.teamB.players.any((p) => p.id == player.id)) {
      throw StateError('${player.name} is already part of a match squad.');
    }
    final team = teamId == _state.teamA.id ? _state.teamA : _state.teamB;
    if (rules.maximumSquadSize != null &&
        team.players.length >= rules.maximumSquadSize!) {
      throw StateError(
        '${team.name} has reached the maximum allowed squad size.',
      );
    }
    final isBattingTeam = _state.activeInnings.battingTeamId == teamId;
    if (isBattingTeam && !rules.allowLateBatters) {
      throw StateError('Late batters are disabled for this match.');
    }
    if (!isBattingTeam && !rules.allowLateBowlers && player.isEligibleBowler) {
      throw StateError('Late bowlers are disabled for this match.');
    }
    final updated = Team(
      id: team.id,
      name: team.name,
      shortName: team.shortName,
      logoUrl: team.logoUrl,
      players: [...team.players, player],
    );
    _state = teamId == _state.teamA.id
        ? _state.copyWith(teamA: updated)
        : _state.copyWith(teamB: updated);
    if (isBattingTeam && rules.allowLateBatters) {
      final active = _state.activeInnings.copyWith(
        playingMemberCountSnapshot: updated.players.length,
        maximumWickets: InningsCompletionEvaluator.calculateMaximumWickets(
          playingMemberCount: updated.players.length,
        ),
      );
      final innings = List<InningsState>.from(_state.innings);
      innings[_state.currentInningsIndex] = active;
      _state = _state.copyWith(innings: innings);
    }
  }

  bool hasPlayerParticipated(String playerId) => _state.events.any((event) =>
      event.strikerId == playerId ||
      event.nonStrikerId == playerId ||
      event.bowlerId == playerId ||
      event.wicket?.dismissedPlayerId == playerId ||
      event.wicket?.fielderId == playerId);

  void removeUnparticipatedPlayer({
    required String teamId,
    required String playerId,
  }) {
    if (_state.status != MatchStatus.live &&
        _state.status != MatchStatus.inningsBreak) {
      throw StateError('Players can only be removed from an active match.');
    }
    final active = _state.activeInnings;
    if (hasPlayerParticipated(playerId) ||
        active.strikerId == playerId ||
        active.nonStrikerId == playerId ||
        active.currentBowlerId == playerId) {
      throw StateError(
        'This player has already participated in the match and cannot be removed.',
      );
    }
    final team = teamId == _state.teamA.id ? _state.teamA : _state.teamB;
    if (!team.players.any((player) => player.id == playerId)) {
      throw ArgumentError('Player does not belong to this match squad.');
    }
    if (team.players.length <= 2) {
      throw StateError('A match squad must retain at least two players.');
    }
    final updated = Team(
      id: team.id,
      name: team.name,
      shortName: team.shortName,
      logoUrl: team.logoUrl,
      players: team.players.where((player) => player.id != playerId).toList(),
    );
    _state = teamId == _state.teamA.id
        ? _state.copyWith(teamA: updated)
        : _state.copyWith(teamB: updated);
    if (active.battingTeamId == teamId) {
      final innings = List<InningsState>.from(_state.innings);
      innings[_state.currentInningsIndex] = active.copyWith(
        playingMemberCountSnapshot: updated.players.length,
        maximumWickets: InningsCompletionEvaluator.calculateMaximumWickets(
          playingMemberCount: updated.players.length,
        ),
      );
      _state = _state.copyWith(innings: innings);
    }
  }

  void setPlayerAvailability({
    required String teamId,
    required String playerId,
    required bool isAvailable,
  }) {
    final team = teamId == _state.teamA.id ? _state.teamA : _state.teamB;
    final updated = Team(
      id: team.id,
      name: team.name,
      shortName: team.shortName,
      logoUrl: team.logoUrl,
      players: team.players
          .map((player) => player.id == playerId
              ? player.copyWith(isAvailable: isAvailable)
              : player)
          .toList(),
    );
    _state = teamId == _state.teamA.id
        ? _state.copyWith(teamA: updated)
        : _state.copyWith(teamB: updated);
  }

  /// Factory constructor to initialize a fresh match setup
  factory CricketScoringEngine.createMatch({
    required String matchId,
    required MatchConfig config,
    required Team teamA,
    required Team teamB,
    required String tossWinnerTeamId,
    required String tossDecision, // 'BAT' or 'BOWL'
    required String openingStrikerId,
    required String openingNonStrikerId,
    required String openingBowlerId,
    List<MatchTeamRoleSnapshot> teamRoleSnapshots = const [],
    int? scheduledAt,
    int? startedAt,
    int? createdAt,
    String? venueName,
    String? matchTimeZone,
  }) {
    final battingTeamId = tossDecision == 'BAT'
        ? tossWinnerTeamId
        : (tossWinnerTeamId == teamA.id ? teamB.id : teamA.id);
    final bowlingTeamId = battingTeamId == teamA.id ? teamB.id : teamA.id;

    final initialInnings = InningsState(
      inningsId: '${matchId}_inn_1',
      battingTeamId: battingTeamId,
      bowlingTeamId: bowlingTeamId,
      inningsNumber: 1,
      strikerId: openingStrikerId,
      nonStrikerId: openingNonStrikerId,
      currentBowlerId: openingBowlerId,
      activeOverId: '${matchId}_inn_1_over_0',
      playingMemberCountSnapshot: battingTeamId == teamA.id
          ? teamA.players.length
          : teamB.players.length,
      maximumWickets: InningsCompletionEvaluator.calculateMaximumWickets(
        playingMemberCount: battingTeamId == teamA.id
            ? teamA.players.length
            : teamB.players.length,
      ),
      battingOrder: [openingStrikerId, openingNonStrikerId],
    );

    final matchState = MatchState(
      matchId: matchId,
      config: config,
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: tossWinnerTeamId,
      tossDecision: tossDecision,
      status: MatchStatus.live,
      currentInningsIndex: 0,
      innings: [initialInnings],
      events: const [],
      bowlingSegments: [
        BowlingSegment(
          id: '${matchId}_inn_1_over_0_segment_0',
          inningsId: '${matchId}_inn_1',
          overId: '${matchId}_inn_1_over_0',
          overNumber: 0,
          bowlerId: openingBowlerId,
          startSequence: 1,
          startLegalBall: 1,
        ),
      ],
      teamRoleSnapshots: teamRoleSnapshots,
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      createdAt: createdAt,
      venueName: venueName,
      matchTimeZone: matchTimeZone,
    );

    return CricketScoringEngine(matchState);
  }

  /// Replaces an incapacitated bowler without completing or resetting the over.
  BowlerReplacementEvent replaceCurrentBowler({
    required String newBowlerId,
    required BowlerChangeReason reason,
    required String changedBy,
  }) {
    final active = _state.activeInnings;
    if (!_state.config.allowMidOverBowlerReplacement) {
      throw StateError('Mid-over bowler replacement is disabled.');
    }
    if (active.flowState != InningsFlowState.scoring) {
      throw StateError('The innings is not currently scoring an over.');
    }
    final previousBowlerId = active.currentBowlerId;
    final overId = active.activeOverId;
    if (previousBowlerId == null || overId == null) {
      throw StateError('There is no current bowler to replace.');
    }
    final legalBallsInOver =
        active.legalBallsBowled % _state.config.ballsPerOver;
    if (legalBallsInOver == 0) {
      throw StateError('Use next-bowler selection before an over starts.');
    }
    if (newBowlerId == previousBowlerId) {
      throw ArgumentError('Select a different replacement bowler.');
    }
    if (reason == BowlerChangeReason.tacticalLocalRule &&
        !_state.config.allowTacticalMidOverReplacement) {
      throw StateError('Tactical mid-over replacement is disabled.');
    }
    _validateBowlerEligibility(newBowlerId, enforceConsecutiveRule: false);
    final currentOver = active.legalBallsBowled ~/ _state.config.ballsPerOver;
    final priorOverBowlers = _state.events
        .where((event) =>
            event.inningsId == active.inningsId &&
            event.overNumber == currentOver - 1)
        .map((event) => event.bowlerId)
        .toSet();
    if (!_state.config.allowConsecutiveOvers &&
        priorOverBowlers.contains(newBowlerId)) {
      throw ArgumentError(
          'A bowler from the previous over cannot complete this over.');
    }

    _stateHistory.add(_state);
    final sequence = _state.events.length;
    final segments = List<BowlingSegment>.from(_state.bowlingSegments);
    final openIndex = segments.lastIndexWhere((segment) =>
        segment.inningsId == active.inningsId &&
        segment.overId == overId &&
        segment.isOpen);
    if (openIndex >= 0) {
      segments[openIndex] = segments[openIndex].copyWith(
        endSequence: sequence,
        endReason: reason,
      );
    }
    segments.add(BowlingSegment(
      id: '${overId}_segment_${segments.where((s) => s.overId == overId).length}',
      inningsId: active.inningsId,
      overId: overId,
      overNumber: currentOver,
      bowlerId: newBowlerId,
      startSequence: sequence + 1,
      startLegalBall: legalBallsInOver + 1,
    ));

    final replacement = BowlerReplacementEvent(
      id: 'replacement_${_state.matchId}_${DateTime.now().microsecondsSinceEpoch}',
      matchId: _state.matchId,
      inningsId: active.inningsId,
      overId: overId,
      previousBowlerId: previousBowlerId,
      replacementBowlerId: newBowlerId,
      legalBallsCompleted: legalBallsInOver,
      remainingLegalBalls: _state.config.ballsPerOver - legalBallsInOver,
      reason: reason,
      currentScore: active.totalRuns,
      changedBy: changedBy,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final updated = active.copyWith(
      currentBowlerId: newBowlerId,
      previousBowlerId: previousBowlerId,
    );
    final list = List<InningsState>.from(_state.innings);
    list[_state.currentInningsIndex] = updated;
    _state = _state.copyWith(
      innings: list,
      bowlingSegments: segments,
      bowlerReplacementEvents: [
        ..._state.bowlerReplacementEvents,
        replacement,
      ],
      suspendedBowlerIds: reason == BowlerChangeReason.suspended
          ? {..._state.suspendedBowlerIds, previousBowlerId}.toList()
          : _state.suspendedBowlerIds,
    );
    return replacement;
  }

  @Deprecated('Use replaceCurrentBowler with a structured reason and scorer')
  void changeBowler(String newBowlerId, {String? reason}) {
    replaceCurrentBowler(
      newBowlerId: newBowlerId,
      reason: BowlerChangeReason.other,
      changedBy: 'legacy-scorer',
    );
  }

  /// Reverses only the latest replacement, and only before its bowler delivers.
  BowlerReplacementEvent undoBowlerReplacement() {
    if (_state.bowlerReplacementEvents.isEmpty) {
      throw StateError('There is no bowler replacement to undo.');
    }
    final replacement = _state.bowlerReplacementEvents.last;
    final hasLaterDelivery = _state.events.any((event) =>
        event.inningsId == replacement.inningsId &&
        event.clientTimestamp >= replacement.timestamp &&
        event.bowlerId == replacement.replacementBowlerId &&
        event.overNumber ==
            _state.activeInnings.legalBallsBowled ~/
                _state.config.ballsPerOver);
    if (hasLaterDelivery) {
      throw StateError(
          'Undo replacement before recording a delivery by the new bowler.');
    }
    if (_stateHistory.isEmpty) {
      throw StateError('The replacement can no longer be safely undone.');
    }
    _state = _stateHistory.removeLast();
    return replacement;
  }

  void selectNextBowler(
    String newBowlerId, {
    bool allowConsecutiveOverride = false,
  }) {
    final active = _state.activeInnings;
    if (_state.status != MatchStatus.live ||
        active.isCompleted ||
        active.flowState != InningsFlowState.awaitingNextBowler) {
      throw StateError('The innings is not awaiting a next bowler.');
    }
    _validateBowlerEligibility(newBowlerId,
        enforceConsecutiveRule: !allowConsecutiveOverride);
    final updated = active.copyWith(
      currentBowlerId: newBowlerId,
      activeOverId: '${active.inningsId}_over_${active.nextOverNumber}',
      flowState: InningsFlowState.scoring,
    );
    final list = List<InningsState>.from(_state.innings);
    list[_state.currentInningsIndex] = updated;
    final overId = updated.activeOverId!;
    _state = _state.copyWith(innings: list, bowlingSegments: [
      ..._state.bowlingSegments,
      BowlingSegment(
        id: '${overId}_segment_0',
        inningsId: active.inningsId,
        overId: overId,
        overNumber: active.nextOverNumber,
        bowlerId: newBowlerId,
        startSequence: _state.events.length + 1,
        startLegalBall: 1,
      ),
    ]);
  }

  void _validateBowlerEligibility(
    String bowlerId, {
    required bool enforceConsecutiveRule,
  }) {
    final active = _state.activeInnings;
    final bowlingTeam =
        active.bowlingTeamId == _state.teamA.id ? _state.teamA : _state.teamB;
    final matches = bowlingTeam.players.where((p) => p.id == bowlerId);
    if (matches.isEmpty) {
      throw ArgumentError('The selected player is outside the bowling squad.');
    }
    final player = matches.first;
    if (!player.isAvailable) throw ArgumentError('The bowler is unavailable.');
    if (_state.suspendedBowlerIds.contains(bowlerId)) {
      throw ArgumentError('The bowler is suspended for this innings.');
    }
    if (!player.isEligibleBowler) {
      throw ArgumentError('The player is not eligible to bowl.');
    }
    // Approved late bowlers use the persisted default limit. Their explicit
    // membership is captured in the updated team snapshot.
    if (!player.isLateAddition && !_state.config.isBowlerConfigured(bowlerId)) {
      throw ArgumentError(
          'The player is not configured as an eligible bowler.');
    }
    final previousOverNumber = active.nextOverNumber - 1;
    final participatedInPreviousOver = _state.events.any((event) =>
        event.inningsId == active.inningsId &&
        event.overNumber == previousOverNumber &&
        event.bowlerId == bowlerId);
    if (enforceConsecutiveRule &&
        !_state.config.allowConsecutiveOvers &&
        participatedInPreviousOver) {
      throw ArgumentError('The previous bowler cannot bowl consecutive overs.');
    }
    final legalBalls = _state.events
        .where((event) =>
            event.inningsId == active.inningsId &&
            event.bowlerId == bowlerId &&
            event.isLegal)
        .length;
    final maximumLegalBalls = _state.config.maximumLegalBallsFor(bowlerId);
    if (maximumLegalBalls != null && legalBalls >= maximumLegalBalls) {
      throw ArgumentError('The selected bowler has reached the over limit.');
    }
  }

  /// Records a delivery event, updates local state machine, and returns created event.
  void validateCanRecordDelivery() {
    if (_state.status != MatchStatus.live) {
      throw StateError('Cannot record delivery on an inactive match.');
    }
    final innings = _state.activeInnings;
    if (innings.isCompleted ||
        innings.flowState == InningsFlowState.inningsCompleted) {
      throw StateError('Current innings is completed.');
    }
    if (innings.flowState != InningsFlowState.scoring ||
        innings.currentBowlerId == null ||
        innings.activeOverId == null) {
      throw StateError(
        'Over completed. Select the next bowler before recording another delivery.',
      );
    }
    if (_state.result != null) {
      throw StateError('Cannot record delivery after a match result exists.');
    }
    final bowlerId = innings.currentBowlerId!;
    final maximumLegalBalls = _state.config.maximumLegalBallsFor(bowlerId);
    if (maximumLegalBalls != null) {
      final used = _state.events
          .where((event) =>
              event.inningsId == innings.inningsId &&
              event.bowlerId == bowlerId &&
              event.isLegal)
          .length;
      if (used >= maximumLegalBalls) {
        throw StateError(
            'The current bowler has no legal-ball quota remaining. Replace the bowler.');
      }
    }
  }

  DeliveryEvent recordDelivery({
    required String eventId,
    required String scorerDeviceId,
    int runsBatter = 0,
    ExtrasType extrasType = ExtrasType.none,
    int extrasRuns = 0,
    int? wideRuns,
    int? additionalWideRuns,
    int? noBallRuns,
    int byeRuns = 0,
    int legByeRuns = 0,
    int penaltyRuns = 0,
    bool isBoundaryFour = false,
    bool isBoundarySix = false,
    WicketDetail? wicket,
    String? newBatterId,
    String? nextBowlerId,
  }) {
    validateCanRecordDelivery();
    if (extrasType == ExtrasType.wide && wideRuns != null && wideRuns < 1) {
      throw ArgumentError.value(
        wideRuns,
        'wideRuns',
        'A Wide must add at least one run.',
      );
    }
    if (extrasType == ExtrasType.wide &&
        additionalWideRuns != null &&
        additionalWideRuns < 0) {
      throw ArgumentError.value(
        additionalWideRuns,
        'additionalWideRuns',
        'Additional Wide runs cannot be negative.',
      );
    }
    final activeInnings = _state.activeInnings;
    _stateHistory.add(_state);

    // 1. Calculate previous event hash
    final previousHash =
        _state.events.isEmpty ? 'GENESIS' : _state.events.last.eventId;

    final currentOver =
        activeInnings.legalBallsBowled ~/ _state.config.ballsPerOver;
    final currentLegalBall =
        (activeInnings.legalBallsBowled % _state.config.ballsPerOver) + 1;

    // 2. Process Extras & Legality
    final processed = ExtrasHandler.processExtras(
      type: extrasType,
      runsBatter: runsBatter,
      extrasRuns: extrasRuns,
      config: _state.config,
      wasPreviousFreeHit: false,
    );

    final resolvedWideRuns = extrasType == ExtrasType.wide
        ? (additionalWideRuns == null
            ? (wideRuns ?? (_state.config.wideRuns + extrasRuns))
            : _state.config.wideRuns + additionalWideRuns)
        : 0;
    final resolvedAdditionalWideRuns = extrasType == ExtrasType.wide
        ? (additionalWideRuns ?? (resolvedWideRuns - _state.config.wideRuns))
            .clamp(0, 999) as int
        : 0;
    final resolvedNoBallRuns = extrasType == ExtrasType.noBall
        ? (noBallRuns ?? _state.config.noBallRuns)
        : 0;
    final resolvedByeRuns = extrasType == ExtrasType.bye
        ? (byeRuns > 0 ? byeRuns : extrasRuns)
        : byeRuns;
    final resolvedLegByeRuns = extrasType == ExtrasType.legBye
        ? (legByeRuns > 0 ? legByeRuns : extrasRuns)
        : legByeRuns;
    final resolvedPenaltyRuns = extrasType == ExtrasType.penalty
        ? (penaltyRuns > 0 ? penaltyRuns : extrasRuns)
        : penaltyRuns;
    final totalExtras = resolvedWideRuns +
        resolvedNoBallRuns +
        resolvedByeRuns +
        resolvedLegByeRuns +
        resolvedPenaltyRuns;

    // 3. Construct DeliveryEvent
    final event = DeliveryEvent(
      eventId: eventId,
      matchId: _state.matchId,
      inningsId: activeInnings.inningsId,
      overNumber: currentOver,
      legalBallNumber: currentLegalBall,
      eventSequence: _state.events.length + 1,
      sequenceInOver: _state.events
              .where((event) =>
                  event.inningsId == activeInnings.inningsId &&
                  event.overNumber == currentOver)
              .length +
          1,
      scorerDeviceId: scorerDeviceId,
      strikerId: activeInnings.strikerId,
      nonStrikerId: activeInnings.nonStrikerId,
      bowlerId: activeInnings.currentBowlerId!,
      runsBatter: processed.batterRuns,
      extrasType: extrasType,
      extrasRuns: totalExtras,
      wideRuns: resolvedWideRuns,
      additionalWideRuns: resolvedAdditionalWideRuns,
      noBallRuns: resolvedNoBallRuns,
      byeRuns: resolvedByeRuns,
      legByeRuns: resolvedLegByeRuns,
      penaltyRuns: resolvedPenaltyRuns,
      isLegal: processed.isLegal,
      isBoundaryFour: isBoundaryFour,
      isBoundarySix: isBoundarySix,
      wicket: wicket,
      previousEventHash: previousHash,
      clientTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // 4. Validate Wicket rules if present
    if (wicket != null) {
      WicketHandler.validateWicket(
        type: wicket.type,
        extrasType: extrasType,
        isFreeHit: false,
      );
    }

    // 5. Update Innings State metrics
    final newTotalRuns = activeInnings.totalRuns + event.totalRuns;
    final wicketCounts =
        wicket != null && WicketHandler.countsAsTeamWicket(wicket.type);
    final newWickets = activeInnings.totalWickets + (wicketCounts ? 1 : 0);
    final newLegalBalls =
        activeInnings.legalBallsBowled + (processed.isLegal ? 1 : 0);

    bool isEndOfOver =
        processed.isLegal && (newLegalBalls % _state.config.ballsPerOver == 0);

    // 6. Calculate new Striker / Non-striker positions
    final newPositions = StrikeRotationRule.calculatePositions(
      currentStrikerId: activeInnings.strikerId,
      currentNonStrikerId: activeInnings.nonStrikerId,
      event: event,
      isEndOfOver: isEndOfOver,
      newBatterId: newBatterId,
    );

    var updatedInnings = activeInnings.copyWith(
      totalRuns: newTotalRuns,
      totalWickets: newWickets,
      legalBallsBowled: newLegalBalls,
      strikerId: newPositions.strikerId,
      nonStrikerId: newPositions.nonStrikerId,
      battingOrder: newBatterId != null &&
              !activeInnings.battingOrder.contains(newBatterId)
          ? [...activeInnings.battingOrder, newBatterId]
          : activeInnings.battingOrder,
    );
    final completion = const InningsCompletionEvaluator().evaluate(
      innings: updatedInnings,
      rules: _state.config,
      battingSquadSize: activeInnings.playingMemberCountSnapshot,
      target: activeInnings.targetRuns,
    );
    final isInningsDone = completion.isCompleted;
    final requiresNextBatter =
        wicket != null && newBatterId == null && !isInningsDone;
    final completionReason = switch (completion.reason) {
      InningsCompletionReason.allOut => 'All Out',
      InningsCompletionReason.oversCompleted => 'Overs Completed',
      InningsCompletionReason.targetReached => 'Target Achieved',
      _ => null,
    };
    updatedInnings = updatedInnings.copyWith(
      isCompleted: isInningsDone,
      completionReason: completionReason,
      flowState: isInningsDone
          ? InningsFlowState.inningsCompleted
          : (requiresNextBatter
              ? InningsFlowState.awaitingNextBatter
              : isEndOfOver
                  ? InningsFlowState.awaitingNextBowler
                  : InningsFlowState.scoring),
      previousBowlerId: isEndOfOver ? activeInnings.currentBowlerId : null,
      previousOverBowlerId: isEndOfOver ? activeInnings.currentBowlerId : null,
      clearCurrentBowler: isEndOfOver,
      clearActiveOver: isEndOfOver,
      nextOverNumber: isEndOfOver
          ? newLegalBalls ~/ _state.config.ballsPerOver
          : activeInnings.nextOverNumber,
    );

    final updatedEvents = List<DeliveryEvent>.from(_state.events)..add(event);
    final updatedSegments = List<BowlingSegment>.from(_state.bowlingSegments);
    final segmentIndex = updatedSegments.lastIndexWhere((segment) =>
        segment.inningsId == activeInnings.inningsId &&
        segment.overId == activeInnings.activeOverId &&
        segment.bowlerId == event.bowlerId &&
        segment.isOpen);
    if (segmentIndex >= 0) {
      final segment = updatedSegments[segmentIndex];
      updatedSegments[segmentIndex] = segment.copyWith(
        legalBallsBowled: segment.legalBallsBowled + (event.isLegal ? 1 : 0),
        endSequence: isEndOfOver ? event.eventSequence : null,
      );
    }
    final updatedInningsList = List<InningsState>.from(_state.innings);
    updatedInningsList[_state.currentInningsIndex] = updatedInnings;

    // Transition match status to inningsBreak if 1st innings finishes
    MatchStatus matchStatus = _state.status;
    if (isInningsDone && _state.currentInningsIndex == 0) {
      matchStatus = MatchStatus.inningsBreak;
    }

    _state = _state.copyWith(
      status: matchStatus,
      events: updatedEvents,
      innings: updatedInningsList,
      bowlingSegments: updatedSegments,
    );

    _undoStack.clear();

    // Check Match Completion (if 2nd innings finished or target reached)
    if (_state.currentInningsIndex == 1 && isInningsDone) {
      _checkMatchCompletion();
    }

    return event;
  }

  /// Starts the second innings with target set from 1st innings
  void startSecondInnings({
    required String openingStrikerId,
    required String openingNonStrikerId,
    required String openingBowlerId,
  }) {
    if (_state.innings.isEmpty || !_state.innings[0].isCompleted) {
      throw StateError(
        'Cannot start second innings before first innings completes.',
      );
    }

    final firstInnings = _state.innings[0];
    final target = firstInnings.totalRuns + 1;

    final secondInnings = InningsState(
      inningsId: '${_state.matchId}_inn_2',
      battingTeamId: firstInnings.bowlingTeamId,
      bowlingTeamId: firstInnings.battingTeamId,
      inningsNumber: 2,
      strikerId: openingStrikerId,
      nonStrikerId: openingNonStrikerId,
      currentBowlerId: openingBowlerId,
      activeOverId: '${_state.matchId}_inn_2_over_0',
      targetRuns: target,
      playingMemberCountSnapshot: (firstInnings.bowlingTeamId == _state.teamA.id
              ? _state.teamA
              : _state.teamB)
          .players
          .length,
      maximumWickets: InningsCompletionEvaluator.calculateMaximumWickets(
        playingMemberCount: (firstInnings.bowlingTeamId == _state.teamA.id
                ? _state.teamA
                : _state.teamB)
            .players
            .length,
      ),
      battingOrder: [openingStrikerId, openingNonStrikerId],
    );

    _state = _state.copyWith(
      status: MatchStatus.live,
      currentInningsIndex: 1,
      innings: List<InningsState>.from(_state.innings)..add(secondInnings),
      bowlingSegments: [
        ..._state.bowlingSegments,
        BowlingSegment(
          id: '${secondInnings.activeOverId}_segment_0',
          inningsId: secondInnings.inningsId,
          overId: secondInnings.activeOverId!,
          overNumber: 0,
          bowlerId: openingBowlerId,
          startSequence: _state.events.length + 1,
          startLegalBall: 1,
        ),
      ],
    );
  }

  /// Undo the last delivery action
  DeliveryEvent? undoLastDelivery() {
    if (_state.events.isEmpty) return null;

    final lastEvent = _state.events.last;
    _undoStack.add(lastEvent);
    if (_stateHistory.isNotEmpty) {
      _state = _stateHistory.removeLast();
      return lastEvent;
    }

    final remainingEvents = List<DeliveryEvent>.from(_state.events)
      ..removeLast();

    // Replay all remaining events from initial state
    _rebuildStateFromEvents(remainingEvents);

    return lastEvent;
  }

  /// Swap current striker and non-striker manually
  void swapStrikers() {
    final active = _state.activeInnings;
    final updated = active.copyWith(
      strikerId: active.nonStrikerId,
      nonStrikerId: active.strikerId,
    );
    final list = List<InningsState>.from(_state.innings);
    list[_state.currentInningsIndex] = updated;
    _state = _state.copyWith(innings: list);
  }

  void changeBatter({
    required String newBatterId,
    required bool replaceStriker,
  }) {
    final active = _state.activeInnings;
    if (newBatterId == active.strikerId || newBatterId == active.nonStrikerId) {
      throw ArgumentError('The selected batter is already active.');
    }
    final battingTeam =
        active.battingTeamId == _state.teamA.id ? _state.teamA : _state.teamB;
    if (!battingTeam.players.any((player) => player.id == newBatterId)) {
      throw ArgumentError('The selected player is not in the batting team.');
    }
    final dismissed = _state.events
        .where((event) => event.inningsId == active.inningsId)
        .where((event) =>
            event.wicket != null &&
            WicketHandler.countsAsTeamWicket(event.wicket!.type))
        .map((event) => event.wicket!.dismissedPlayerId)
        .toSet();
    if (dismissed.contains(newBatterId)) {
      throw ArgumentError('A dismissed batter cannot return.');
    }
    final updated = active.copyWith(
      strikerId: replaceStriker ? newBatterId : active.strikerId,
      nonStrikerId: replaceStriker ? active.nonStrikerId : newBatterId,
      battingOrder: active.battingOrder.contains(newBatterId)
          ? active.battingOrder
          : [...active.battingOrder, newBatterId],
    );
    final list = List<InningsState>.from(_state.innings);
    list[_state.currentInningsIndex] = updated;
    _state = _state.copyWith(innings: list);
  }

  /// Resolves the mandatory incoming-batter state after a wicket.
  /// If that wicket also completed the over, bowler selection remains locked
  /// and becomes the next required transition.
  void selectNextBatter({
    required String newBatterId,
    required bool replaceStriker,
  }) {
    final active = _state.activeInnings;
    if (active.flowState != InningsFlowState.awaitingNextBatter) {
      throw StateError('The innings is not awaiting a next batter.');
    }
    changeBatter(
      newBatterId: newBatterId,
      replaceStriker: replaceStriker,
    );
    final changed = _state.activeInnings;
    final overWasCompleted =
        changed.currentBowlerId == null && changed.activeOverId == null;
    final updated = changed.copyWith(
      flowState: overWasCompleted
          ? InningsFlowState.awaitingNextBowler
          : InningsFlowState.scoring,
    );
    final innings = List<InningsState>.from(_state.innings);
    innings[_state.currentInningsIndex] = updated;
    _state = _state.copyWith(innings: innings);
  }

  /// Rebuilds match state by replaying an event sequence
  void _rebuildStateFromEvents(List<DeliveryEvent> events) {
    if (events.isEmpty) {
      final initialInnings = _state.innings.first.copyWith(
        totalRuns: 0,
        totalWickets: 0,
        legalBallsBowled: 0,
        isCompleted: false,
        completionReason: null,
      );
      _state = _state.copyWith(
        events: const [],
        currentInningsIndex: 0,
        innings: [initialInnings],
        status: MatchStatus.live,
        result: null,
      );
      return;
    }

    final firstInnings = _state.innings.first;
    final baseInnings = InningsState(
      inningsId: firstInnings.inningsId,
      battingTeamId: firstInnings.battingTeamId,
      bowlingTeamId: firstInnings.bowlingTeamId,
      inningsNumber: 1,
      strikerId: events.first.strikerId,
      nonStrikerId: events.first.nonStrikerId,
      currentBowlerId: events.first.bowlerId,
      activeOverId: '${firstInnings.inningsId}_over_0',
      playingMemberCountSnapshot: firstInnings.playingMemberCountSnapshot,
      maximumWickets: firstInnings.maximumWickets,
    );

    _state = _state.copyWith(
      events: [],
      currentInningsIndex: 0,
      innings: [baseInnings],
      status: MatchStatus.live,
      result: null,
    );

    for (final ev in events) {
      recordDelivery(
        eventId: ev.eventId,
        scorerDeviceId: ev.scorerDeviceId,
        runsBatter: ev.runsBatter,
        extrasType: ev.extrasType,
        extrasRuns: ev.extrasRuns,
        wideRuns: ev.wideRuns,
        additionalWideRuns: ev.additionalWideRuns,
        noBallRuns: ev.noBallRuns,
        byeRuns: ev.byeRuns,
        legByeRuns: ev.legByeRuns,
        penaltyRuns: ev.penaltyRuns,
        isBoundaryFour: ev.isBoundaryFour,
        isBoundarySix: ev.isBoundarySix,
        wicket: ev.wicket,
      );
    }
  }

  /// Calculates final match result when 2nd innings completes
  void _checkMatchCompletion() {
    if (_state.innings.length < 2) return;
    final inn1 = _state.innings[0];
    final inn2 = _state.innings[1];

    MatchResult res;
    if (inn2.totalRuns >= inn1.totalRuns + 1) {
      final wicketsLeft = inn2.maximumWickets - inn2.totalWickets;
      final teamName = inn2.battingTeamId == _state.teamA.id
          ? _state.teamA.name
          : _state.teamB.name;
      res = MatchResult(
        winnerTeamId: inn2.battingTeamId,
        resultString:
            '$teamName won by $wicketsLeft ${wicketsLeft == 1 ? 'wicket' : 'wickets'}',
        winByWickets: wicketsLeft,
      );
    } else if (inn2.totalRuns < inn1.totalRuns) {
      final runDiff = inn1.totalRuns - inn2.totalRuns;
      final teamName = inn1.battingTeamId == _state.teamA.id
          ? _state.teamA.name
          : _state.teamB.name;
      res = MatchResult(
        winnerTeamId: inn1.battingTeamId,
        resultString: '$teamName won by $runDiff runs',
        winByRuns: runDiff,
      );
    } else {
      res = const MatchResult(
        winnerTeamId: '',
        resultString: 'Match Tied',
        isTie: true,
        isSuperOverRequired: true,
      );
    }

    _state = _state.copyWith(
      status: MatchStatus.completed,
      result: res,
      endedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Calculates Batter Scorecards for active innings
  List<BatterScorecard> getBatterScorecards(Team team, {String? inningsId}) {
    final Map<String, int> runsMap = {};
    final Map<String, int> ballsMap = {};
    final Map<String, int> foursMap = {};
    final Map<String, int> sixesMap = {};
    final Map<String, String> dismissalMap = {};

    for (final player in team.players) {
      runsMap[player.id] = 0;
      ballsMap[player.id] = 0;
      foursMap[player.id] = 0;
      sixesMap[player.id] = 0;
      dismissalMap[player.id] = 'yet to bat';
    }

    final selectedInningsId = inningsId ?? _state.activeInnings.inningsId;
    final selectedInnings = _state.innings.firstWhere(
      (innings) => innings.inningsId == selectedInningsId,
      orElse: () => _state.activeInnings,
    );
    final currentInningsEvents =
        _state.events.where((e) => e.inningsId == selectedInningsId).toList();

    for (final event in currentInningsEvents) {
      final sId = event.strikerId;
      dismissalMap[sId] = 'not out';
      dismissalMap[event.nonStrikerId] = 'not out';

      runsMap[sId] = (runsMap[sId] ?? 0) + event.runsBatter;

      if (event.isLegal && event.extrasType != ExtrasType.penalty) {
        ballsMap[sId] = (ballsMap[sId] ?? 0) + 1;
      }

      if (event.isBoundaryFour) foursMap[sId] = (foursMap[sId] ?? 0) + 1;
      if (event.isBoundarySix) sixesMap[sId] = (sixesMap[sId] ?? 0) + 1;

      if (event.wicket != null) {
        final dId = event.wicket!.dismissedPlayerId;
        final bPlayer = _findPlayer(event.bowlerId);
        final fPlayer = event.wicket!.fielderId != null
            ? _findPlayer(event.wicket!.fielderId!)
            : null;
        dismissalMap[dId] = WicketHandler.formatDismissal(
          type: event.wicket!.type,
          bowlerName: bPlayer?.name ?? 'Bowler',
          fielderName: fPlayer?.name,
        );
      }
    }

    final battingOrder = selectedInnings.battingOrder.isNotEmpty
        ? selectedInnings.battingOrder
        : _reconstructBattingOrder(_state, selectedInnings);
    final positions = <String, int>{
      for (var index = 0; index < battingOrder.length; index++)
        battingOrder[index]: index + 1,
    };
    final didNotBatLabel =
        selectedInnings.isCompleted ? 'Did not bat' : 'yet to bat';

    final rows = team.players.map((player) {
      final hasBatted = positions.containsKey(player.id);
      return BatterScorecard(
        playerId: player.id,
        playerName: player.name,
        runs: runsMap[player.id] ?? 0,
        ballsFaced: ballsMap[player.id] ?? 0,
        fours: foursMap[player.id] ?? 0,
        sixes: sixesMap[player.id] ?? 0,
        dismissalInfo: hasBatted
            ? (dismissalMap[player.id] == 'yet to bat'
                ? 'not out'
                : dismissalMap[player.id]!)
            : didNotBatLabel,
        isDismissed: dismissalMap[player.id] != 'not out' &&
            dismissalMap[player.id] != 'yet to bat',
        battingPosition: positions[player.id],
        hasBatted: hasBatted,
      );
    }).toList()
      ..sort((a, b) {
        if (a.battingPosition == null && b.battingPosition == null) return 0;
        if (a.battingPosition == null) return 1;
        if (b.battingPosition == null) return -1;
        return a.battingPosition!.compareTo(b.battingPosition!);
      });
    return rows;
  }

  /// Calculates Bowler Scorecards for active innings
  List<BowlerScorecard> getBowlerScorecards(
    Team bowlingTeam, {
    String? inningsId,
  }) {
    final Map<String, int> legalBallsMap = {};
    final Map<String, int> runsConcededMap = {};
    final Map<String, int> wicketsMap = {};
    final Map<String, int> widesMap = {};
    final Map<String, int> noBallsMap = {};
    final Map<String, int> maidensMap = {};

    for (final player in bowlingTeam.players) {
      legalBallsMap[player.id] = 0;
      runsConcededMap[player.id] = 0;
      wicketsMap[player.id] = 0;
      widesMap[player.id] = 0;
      noBallsMap[player.id] = 0;
      maidensMap[player.id] = 0;
    }

    final selectedInningsId = inningsId ?? _state.activeInnings.inningsId;
    final currentInningsEvents =
        _state.events.where((e) => e.inningsId == selectedInningsId).toList();

    for (final event in currentInningsEvents) {
      final bId = event.bowlerId;
      if (event.isLegal) {
        legalBallsMap[bId] = (legalBallsMap[bId] ?? 0) + 1;
      }

      final conceded = event.runsBatter + event.wideRuns + event.noBallRuns;
      runsConcededMap[bId] = (runsConcededMap[bId] ?? 0) + conceded;

      if (event.extrasType == ExtrasType.wide) {
        widesMap[bId] = (widesMap[bId] ?? 0) + event.wideRuns;
      } else if (event.extrasType == ExtrasType.noBall) {
        noBallsMap[bId] = (noBallsMap[bId] ?? 0) + event.noBallRuns;
      }

      if (event.isBowlerWicket) {
        wicketsMap[bId] = (wicketsMap[bId] ?? 0) + 1;
      }
    }

    final oversByBowler = <String, Map<int, int>>{};
    final legalBallsByBowlerOver = <String, Map<int, int>>{};
    for (final event in currentInningsEvents) {
      final bowlerOvers =
          oversByBowler.putIfAbsent(event.bowlerId, () => <int, int>{});
      final bowlerLegalBalls = legalBallsByBowlerOver.putIfAbsent(
          event.bowlerId, () => <int, int>{});
      final conceded = event.runsBatter + event.wideRuns + event.noBallRuns;
      bowlerOvers[event.overNumber] =
          (bowlerOvers[event.overNumber] ?? 0) + conceded;
      if (event.isLegal) {
        bowlerLegalBalls[event.overNumber] =
            (bowlerLegalBalls[event.overNumber] ?? 0) + 1;
      }
    }
    for (final entry in oversByBowler.entries) {
      maidensMap[entry.key] = entry.value.entries
          .where((over) =>
              over.value == 0 &&
              (legalBallsByBowlerOver[entry.key]?[over.key] ?? 0) >=
                  _state.config.ballsPerOver)
          .length;
    }

    final bowlingPositions = <String, int>{};
    for (final event in currentInningsEvents
      ..sort((a, b) => a.eventSequence.compareTo(b.eventSequence))) {
      bowlingPositions.putIfAbsent(
          event.bowlerId, () => bowlingPositions.length + 1);
    }

    final rows = bowlingTeam.players
        .where(
      (p) => bowlingPositions.containsKey(p.id),
    )
        .map((player) {
      return BowlerScorecard(
        playerId: player.id,
        playerName: player.name,
        legalBallsBowled: legalBallsMap[player.id] ?? 0,
        runsConceded: runsConcededMap[player.id] ?? 0,
        wickets: wicketsMap[player.id] ?? 0,
        wides: widesMap[player.id] ?? 0,
        noBalls: noBallsMap[player.id] ?? 0,
        maidens: maidensMap[player.id] ?? 0,
        ballsPerOver: _state.config.ballsPerOver,
        bowlingPosition: bowlingPositions[player.id],
      );
    }).toList()
      ..sort((a, b) => a.bowlingPosition!.compareTo(b.bowlingPosition!));
    return rows;
  }

  Player? _findPlayer(String id) {
    for (final p in _state.teamA.players) {
      if (p.id == id) return p;
    }
    for (final p in _state.teamB.players) {
      if (p.id == id) return p;
    }
    return null;
  }
}
