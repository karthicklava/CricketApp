import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'widgets/score_summary_card.dart';
import 'widgets/scoring_action_grid.dart';
import 'widgets/wicket_bottom_sheet.dart';
import 'widgets/bowler_selection_bottom_sheet.dart';
import 'widgets/second_innings_setup_modal.dart';
import 'widgets/over_summary_bottom_sheet.dart';
import 'widgets/match_result_view.dart';
import 'widgets/extras_bottom_sheet.dart';
import 'widgets/batter_change_bottom_sheet.dart';
import 'widgets/late_player_bottom_sheet.dart';
import 'widgets/live_player_figures_panel.dart';
import 'widgets/end_match_bottom_sheet.dart';
import 'widgets/next_batter_selection_bottom_sheet.dart';
import '../../core/theme.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/team_repository.dart';

enum _OverSummaryAction { none, selectBowler, endMatch }

class LiveScoringScreen extends ConsumerStatefulWidget {
  final MatchState initialMatchState;
  final String deviceId;

  const LiveScoringScreen({
    super.key,
    required this.initialMatchState,
    required this.deviceId,
  });

  @override
  ConsumerState<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends ConsumerState<LiveScoringScreen> {
  late CricketScoringEngine _engine;
  Future<void> _pendingWrites = Future<void>.value();
  bool _pendingWriteFailed = false;
  bool _recordingExtra = false;
  final String _syncStatusText = 'Offline (Saved)';
  final bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _engine = CricketScoringEngine(widget.initialMatchState);
    _persistMatchStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = _engine.state;
      if (state.status == MatchStatus.inningsBreak) {
        _showSecondInningsModal();
        return;
      }
      if (state.activeInnings.flowState ==
          InningsFlowState.awaitingNextBatter) {
        final lastEvent = state.events.isEmpty ? null : state.events.last;
        if (lastEvent != null) _showRequiredNextBatterModal(lastEvent);
        return;
      }
      if (state.activeInnings.flowState ==
          InningsFlowState.awaitingNextBowler) {
        _showOverSummaryModal();
      }
    });
  }

  Future<void> _persistMatchStatus() {
    final repo = ref.read(matchRepositoryProvider);
    return repo.persistState(_engine.state);
  }

  Future<void> _persistDelivery(DeliveryEvent event) async {
    final stateAfterDelivery = _engine.state;
    final write = _pendingWrites.then((_) => ref
        .read(matchRepositoryProvider)
        .persistDelivery(event, stateAfterDelivery));
    _pendingWrites = write.catchError((_) {
      _pendingWriteFailed = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn’t save this delivery. Your previous score is safe.',
            ),
          ),
        );
      }
    });
    await _pendingWrites;
  }

  void _attachAwardsWhenCompleted() {
    if (_engine.state.status != MatchStatus.completed ||
        _engine.state.awards.isNotEmpty) {
      return;
    }
    final result = const MatchAwardsService().calculateAwards(_engine.state);
    _engine.setAwards(result.awards);
  }

  bool _ensureCanScore() {
    try {
      _engine.validateCanRecordDelivery();
      return true;
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message.toString()),
      ));
      return false;
    }
  }

  void _recordRun(int runs) {
    if (!_ensureCanScore()) return;
    late DeliveryEvent event;
    setState(() {
      event = _engine.recordDelivery(
        eventId: DateTime.now().microsecondsSinceEpoch.toString(),
        scorerDeviceId: widget.deviceId,
        runsBatter: runs,
        isBoundaryFour: runs == 4,
        isBoundarySix: runs == 6,
      );
      _attachAwardsWhenCompleted();
    });
    _persistDelivery(event);
    _evaluatePostDeliveryPipeline(event);
  }

  Future<void> _recordExtras(ExtrasType type) async {
    if (_recordingExtra) return;
    _recordingExtra = true;
    try {
      if (!_ensureCanScore()) return;
      final selection = await showModalBottomSheet<ExtraSelection>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ExtrasBottomSheet(type: type),
      );
      if (selection == null || !mounted) return;
      if (!_ensureCanScore()) return;

      var batterRuns = 0;
      var byeRuns = 0;
      var legByeRuns = 0;
      if (type == ExtrasType.noBall) {
        switch (selection.noBallSource) {
          case NoBallRunSource.bat:
            batterRuns = selection.runs;
            break;
          case NoBallRunSource.bye:
          case NoBallRunSource.running:
            byeRuns = selection.runs;
            break;
          case NoBallRunSource.legBye:
            legByeRuns = selection.runs;
            break;
          case null:
            break;
        }
      } else if (type == ExtrasType.bye) {
        byeRuns = selection.runs;
      } else if (type == ExtrasType.legBye) {
        legByeRuns = selection.runs;
      }

      late DeliveryEvent event;
      setState(() {
        event = _engine.recordDelivery(
          eventId: DateTime.now().microsecondsSinceEpoch.toString(),
          scorerDeviceId: widget.deviceId,
          extrasType: type,
          runsBatter: batterRuns,
          additionalWideRuns: type == ExtrasType.wide ? selection.runs : null,
          noBallRuns: type == ExtrasType.noBall ? 1 : null,
          byeRuns: byeRuns,
          legByeRuns: legByeRuns,
          isBoundaryFour: batterRuns == 4,
          isBoundarySix: batterRuns == 6,
        );
        _attachAwardsWhenCompleted();
      });
      await _persistDelivery(event);
      _evaluatePostDeliveryPipeline(event);
    } finally {
      _recordingExtra = false;
    }
  }

  Future<void> _openWicketModal() async {
    if (!_ensureCanScore()) return;
    final state = _engine.state;
    final inn = state.activeInnings;
    final battingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowlingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamB : state.teamA;

    final striker = battingTeam.players.firstWhere((p) => p.id == inn.strikerId,
        orElse: () => Player(id: inn.strikerId, name: 'Striker'));
    final nonStriker = battingTeam.players.firstWhere(
        (p) => p.id == inn.nonStrikerId,
        orElse: () => Player(id: inn.nonStrikerId, name: 'Non-Striker'));
    final bowler = bowlingTeam.players.firstWhere(
        (p) => p.id == inn.currentBowlerId,
        orElse: () =>
            Player(id: inn.currentBowlerId ?? '', name: 'Bowler not selected'));

    final usedBatterIds = state.events
        .where((e) => e.inningsId == inn.inningsId)
        .expand((e) => [e.strikerId, e.nonStrikerId])
        .toSet();
    usedBatterIds.addAll([inn.strikerId, inn.nonStrikerId]);

    final remaining = battingTeam.players
        .where((p) => p.isAvailable && !usedBatterIds.contains(p.id))
        .toList();

    DeliveryEvent? confirmedEvent;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WicketBottomSheet(
        striker: striker,
        nonStriker: nonStriker,
        bowler: bowler,
        fieldingTeamPlayers:
            bowlingTeam.players.where((player) => player.isAvailable).toList(),
        remainingBatters: remaining,
        onAddNewBatter: () => _addLatePlayer(battingTeam),
        onConfirm: (detail, newBatterId) {
          if (!_ensureCanScore()) return;
          setState(() {
            confirmedEvent = _engine.recordDelivery(
              eventId: DateTime.now().microsecondsSinceEpoch.toString(),
              scorerDeviceId: widget.deviceId,
              runsBatter: detail.runsCompletedBeforeDismissal,
              extrasType: detail.type == WicketType.retiredHurt ||
                      detail.type == WicketType.retiredOut ||
                      detail.type == WicketType.absentHurt
                  ? ExtrasType.penalty
                  : ExtrasType.none,
              wicket: detail,
              newBatterId: newBatterId,
            );
            _attachAwardsWhenCompleted();
          });
        },
      ),
    );
    final event = confirmedEvent;
    if (event == null || !mounted) return;

    // Wait for the wicket sheet to be fully removed and the delivery to be
    // committed before routing to the next mandatory scoring state. Opening
    // another sheet from inside the closing sheet caused the end-of-over flow
    // to be popped together with the wicket sheet.
    await _persistDelivery(event);
    if (!mounted || _pendingWriteFailed) return;
    _evaluatePostDeliveryPipeline(event);
  }

  void _evaluatePostDeliveryPipeline(DeliveryEvent lastEvent) {
    final state = _engine.state;

    // Priority 1: Match Completed
    if (state.status == MatchStatus.completed) {
      _persistMatchStatus();
      return;
    }

    // Priority 2: First Innings Complete -> Innings Break
    if (state.status == MatchStatus.inningsBreak) {
      _persistMatchStatus();
      _showSecondInningsModal();
      return;
    }

    // Priority 3: Over Complete -> Show Over Summary & Select Next Bowler
    if (state.activeInnings.flowState == InningsFlowState.awaitingNextBatter) {
      _showRequiredNextBatterModal(lastEvent);
      return;
    }

    if (state.activeInnings.flowState == InningsFlowState.awaitingNextBowler) {
      _showOverSummaryModal();
    }
  }

  Future<void> _showRequiredNextBatterModal(DeliveryEvent wicketEvent) async {
    final state = _engine.state;
    final innings = state.activeInnings;
    if (innings.flowState != InningsFlowState.awaitingNextBatter) return;
    final battingTeam =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final dismissedIds = state.events
        .where((event) =>
            event.inningsId == innings.inningsId &&
            event.wicket != null &&
            WicketHandler.countsAsTeamWicket(event.wicket!.type))
        .map((event) => event.wicket!.dismissedPlayerId)
        .toSet();
    final eligible = battingTeam.players
        .where((player) =>
            player.isAvailable &&
            player.id != innings.strikerId &&
            player.id != innings.nonStrikerId &&
            !dismissedIds.contains(player.id))
        .toList();
    final dismissedId = wicketEvent.wicket!.dismissedPlayerId;
    final replaceStriker = innings.strikerId == dismissedId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) => NextBatterSelectionBottomSheet(
        eligibleBatters: eligible,
        onAddNewBatter: () => _addLatePlayer(battingTeam),
        onConfirmed: (playerId) async {
          final previous = _engine.state;
          try {
            setState(() => _engine.selectNextBatter(
                  newBatterId: playerId,
                  replaceStriker: replaceStriker,
                ));
            await _persistMatchStatus();
            return true;
          } catch (error) {
            if (mounted) {
              setState(() => _engine = CricketScoringEngine(previous));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(error.toString().replaceFirst('Bad state: ', '')),
              ));
            }
            return false;
          }
        },
      ),
    );
    if (!mounted) return;
    if (_engine.state.activeInnings.flowState ==
        InningsFlowState.awaitingNextBowler) {
      _showOverSummaryModal();
    }
  }

  Future<void> _showOverSummaryModal() async {
    var nextAction = _OverSummaryAction.none;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OverSummaryBottomSheet(
        matchState: _engine.state,
        onSelectNextBowler: () {
          nextAction = _OverSummaryAction.selectBowler;
        },
        onEndMatch: () {
          nextAction = _OverSummaryAction.endMatch;
        },
      ),
    );
    if (!mounted) return;
    switch (nextAction) {
      case _OverSummaryAction.selectBowler:
        _openBowlerSelectionModal(isMidOver: false);
        break;
      case _OverSummaryAction.endMatch:
        _showEndMatchFlow();
        break;
      case _OverSummaryAction.none:
        // The mandatory sheet cannot be dismissed without an explicit action.
        break;
    }
  }

  void _openBowlerSelectionModal({bool isMidOver = false}) {
    final state = _engine.state;
    final inn = state.activeInnings;
    final bowlingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamB : state.teamA;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: isMidOver,
      enableDrag: isMidOver,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BowlerSelectionBottomSheet(
        matchState: state,
        bowlingTeam: bowlingTeam,
        currentBowlerId: inn.currentBowlerId,
        previousBowlerId: inn.previousBowlerId,
        isMidOver: isMidOver,
        onAddNewBowler: () async {
          final added = await _addLatePlayer(bowlingTeam);
          if (added != null && mounted) {
            _openBowlerSelectionModal(isMidOver: isMidOver);
          }
        },
        onBowlerSelected: (newBowlerId, reason) async {
          final previous = _engine.state;
          try {
            BowlerReplacementEvent? replacement;
            setState(() {
              if (isMidOver) {
                final mappedReason = switch (reason) {
                  'Injury' => BowlerChangeReason.injury,
                  'Illness' => BowlerChangeReason.illness,
                  'Unable to continue' => BowlerChangeReason.unableToContinue,
                  'Equipment issue' => BowlerChangeReason.equipmentIssue,
                  'Suspended from bowling' => BowlerChangeReason.suspended,
                  'Tactical replacement under local rules' =>
                    BowlerChangeReason.tacticalLocalRule,
                  _ => BowlerChangeReason.other,
                };
                replacement = _engine.replaceCurrentBowler(
                  newBowlerId: newBowlerId,
                  reason: mappedReason,
                  changedBy: widget.deviceId,
                );
              } else {
                _engine.selectNextBowler(
                  newBowlerId,
                  allowConsecutiveOverride:
                      reason == 'Allow consecutive over once',
                );
              }
            });
            if (replacement != null) {
              await ref.read(matchRepositoryProvider).persistAudit(
                    state: _engine.state,
                    action: 'BOWLER_REPLACED_MID_OVER',
                    payload: replacement!.toJson(),
                  );
            }
            await _persistMatchStatus();
            return true;
          } catch (error) {
            if (mounted) {
              setState(() => _engine = CricketScoringEngine(previous));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(error.toString().replaceFirst('Bad state: ', '')),
              ));
            }
            return false;
          }
        },
      ),
    );
  }

  void _showSecondInningsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SecondInningsSetupModal(
        matchState: _engine.state,
        onEndMatch: _showEndMatchFlow,
        onStartSecondInnings: (strikerId, nonStrikerId, bowlerId) {
          setState(() {
            _engine.startSecondInnings(
              openingStrikerId: strikerId,
              openingNonStrikerId: nonStrikerId,
              openingBowlerId: bowlerId,
            );
            _persistMatchStatus();
          });
        },
      ),
    );
  }

  Future<void> _undo() async {
    DeliveryEvent? undone;
    setState(() {
      undone = _engine.undoLastDelivery();
    });
    if (undone == null) return;
    await ref
        .read(matchRepositoryProvider)
        .undoDelivery(undone!.eventId, _engine.state);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Last delivery undone successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showBatterActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('Batter Actions')),
            ListTile(
              leading: const Icon(Icons.sports_cricket),
              title: const Text('Change Striker'),
              onTap: () => Navigator.pop(context, 'striker'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Change Non-Striker'),
              onTap: () => Navigator.pop(context, 'nonStriker'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Swap Strike'),
              onTap: () => Navigator.pop(context, 'swap'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    if (action == 'swap') {
      final before = _engine.state.activeInnings;
      setState(_engine.swapStrikers);
      await ref.read(matchRepositoryProvider).persistAudit(
        state: _engine.state,
        action: 'STRIKE_SWAPPED',
        payload: {
          'previousStrikerId': before.strikerId,
          'previousNonStrikerId': before.nonStrikerId,
          'reason': 'Authorized scorer correction',
        },
      );
      return;
    }

    final state = _engine.state;
    final innings = state.activeInnings;
    final battingTeam =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final dismissedIds = state.events
        .where((event) => event.inningsId == innings.inningsId)
        .where((event) =>
            event.wicket != null &&
            WicketHandler.countsAsTeamWicket(event.wicket!.type))
        .map((event) => event.wicket!.dismissedPlayerId)
        .toSet();
    final eligible = battingTeam.players
        .where((player) =>
            player.id != innings.strikerId &&
            player.id != innings.nonStrikerId &&
            !dismissedIds.contains(player.id))
        .toList();
    final replaceStriker = action == 'striker';
    final selection = await showModalBottomSheet<BatterChangeSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BatterChangeBottomSheet(
        eligiblePlayers: eligible,
        replaceStriker: replaceStriker,
      ),
    );
    if (selection == null || !mounted) return;
    final previousBatterId =
        replaceStriker ? innings.strikerId : innings.nonStrikerId;
    setState(() {
      _engine.changeBatter(
        newBatterId: selection.player.id,
        replaceStriker: replaceStriker,
      );
    });
    await ref.read(matchRepositoryProvider).persistAudit(
      state: _engine.state,
      action: 'BATTER_CHANGED',
      payload: {
        'previousBatterId': previousBatterId,
        'newBatterId': selection.player.id,
        'batterEnd': replaceStriker ? 'striker' : 'nonStriker',
        'reason': selection.reason,
        'scorerId': widget.deviceId,
      },
    );
  }

  Future<void> _showMoreActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(title: Text('More Scoring Actions')),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Change Batter'),
              onTap: () => Navigator.pop(context, 'batter'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Swap Strike'),
              onTap: () => Navigator.pop(context, 'swap'),
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Replace Current Bowler'),
              subtitle:
                  const Text('Continue the same over with another bowler'),
              onTap: () => Navigator.pop(context, 'bowler'),
            ),
            if (_engine.state.bowlerReplacementEvents.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.undo),
                title: const Text('Undo Bowler Replacement'),
                subtitle: const Text(
                    'Available only before the replacement bowls a delivery'),
                onTap: () => Navigator.pop(context, 'undoBowlerReplacement'),
              ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Manage Players'),
              subtitle: const Text('Add a late player or view match squads'),
              onTap: () => Navigator.pop(context, 'players'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.stop_circle_outlined, color: Colors.red),
              title: const Text('End Match'),
              subtitle: const Text('Save the score and stop this match'),
              onTap: () => Navigator.pop(context, 'endMatch'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'endMatch') {
      _showEndMatchFlow();
    } else if (action == 'bowler') {
      _openBowlerSelectionModal(isMidOver: true);
    } else if (action == 'undoBowlerReplacement') {
      try {
        late BowlerReplacementEvent replacement;
        setState(() => replacement = _engine.undoBowlerReplacement());
        await ref.read(matchRepositoryProvider).persistAudit(
              state: _engine.state,
              action: 'BOWLER_REPLACEMENT_UNDONE',
              payload: replacement.toJson(),
            );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ));
        }
      }
    } else if (action == 'players') {
      _showManagePlayers();
    } else if (action == 'swap') {
      final before = _engine.state.activeInnings;
      setState(_engine.swapStrikers);
      await ref.read(matchRepositoryProvider).persistAudit(
        state: _engine.state,
        action: 'STRIKE_SWAPPED',
        payload: {
          'previousStrikerId': before.strikerId,
          'previousNonStrikerId': before.nonStrikerId,
          'reason': 'Authorized scorer correction',
        },
      );
    } else {
      _showBatterActions();
    }
  }

  Future<void> _showEndMatchFlow() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => EndMatchBottomSheet(
        matchState: _engine.state,
        onConfirm: (selection) async {
          final previous = _engine.state;
          try {
            await _pendingWrites;
            if (_pendingWriteFailed) return false;
            setState(() => _engine.endMatchManually(
                  outcome: selection.outcome,
                  reason: selection.reason,
                  reasonText: selection.reasonText,
                  endedBy: widget.deviceId,
                  note: selection.note,
                  winnerTeamId: selection.winnerTeamId,
                  forfeitingTeamId: selection.forfeitingTeamId,
                  resultType: selection.resultType,
                  resultText: selection.resultText,
                  isTie: selection.isTie,
                ));
            await ref
                .read(matchRepositoryProvider)
                .persistManualEnd(_engine.state);
            return true;
          } catch (_) {
            if (mounted) {
              setState(() => _engine = CricketScoringEngine(previous));
            }
            return false;
          }
        },
      ),
    );
  }

  Future<void> _showManagePlayers() async {
    final state = _engine.state;
    if (!state.config.latePlayerRules.allowLatePlayers) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Late player additions are disabled for this match.'),
      ));
      return;
    }
    final innings = state.activeInnings;
    final batting =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowling =
        innings.bowlingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          const ListTile(title: Text('Manage Match Players')),
          ListTile(
            leading: const Icon(Icons.sports_cricket),
            title: Text('Add Player to Batting Team'),
            subtitle: Text(batting.name),
            onTap: () => Navigator.pop(context, 'batting'),
          ),
          ListTile(
            leading: const Icon(Icons.sports_baseball),
            title: Text('Add Player to Bowling Team'),
            subtitle: Text(bowling.name),
            onTap: () => Navigator.pop(context, 'bowling'),
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('View Match Squads'),
            onTap: () => Navigator.pop(context, 'view'),
          ),
        ]),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'view') {
      _showMatchSquads();
    } else {
      await _addLatePlayer(action == 'batting' ? batting : bowling);
    }
  }

  Future<Player?> _addLatePlayer(Team team) async {
    final state = _engine.state;
    final roster =
        await ref.read(teamRepositoryProvider).getTeamPlayers(team.id);
    if (!mounted) return null;
    final matchIds = {
      ...state.teamA.players.map((player) => player.id),
      ...state.teamB.players.map((player) => player.id),
    };
    final available = roster
        .where((player) => !matchIds.contains(player.id))
        .map((player) => ExistingPlayerOption(
              id: player.id,
              name: player.name,
              jerseyNumber: player.jerseyNumber,
              role: player.role,
              battingStyle: BattingStyle.values.firstWhere(
                (style) => style.name == player.battingStyle,
                orElse: () => BattingStyle.rightHand,
              ),
              bowlingStyle: BowlingStyle.values.firstWhere(
                (style) => style.name == player.bowlingStyle,
                orElse: () => BowlingStyle.rightArmFast,
              ),
              isWicketKeeper: player.isWicketKeeper,
            ))
        .toList();
    final innings = state.activeInnings;
    final isBatting = innings.battingTeamId == team.id;
    final selection = await showModalBottomSheet<LatePlayerSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => LatePlayerBottomSheet(
        team: team,
        isBattingTeam: isBatting,
        existingPlayers: available,
        allowPermanentAddition:
            state.config.latePlayerRules.allowPermanentTeamAddition,
      ),
    );
    if (selection == null || !mounted) return null;

    try {
      final repository = ref.read(teamRepositoryProvider);
      final playerId = selection.source == LatePlayerSource.existing
          ? selection.existingPlayerId!
          : await repository.createPlayerForLiveMatch(
              name: selection.name,
              role: selection.role,
              battingStyle: selection.battingStyle.name,
              bowlingStyle: selection.bowlingStyle.name,
              jerseyNumber: selection.jerseyNumber,
              addToPermanentTeam: selection.addPermanently,
              teamId: team.id,
              isWicketKeeper: selection.isWicketKeeper,
            );
      final now = DateTime.now().millisecondsSinceEpoch;
      final latePlayer = Player(
        id: playerId,
        name: selection.name,
        battingStyle: selection.battingStyle,
        bowlingStyle: selection.bowlingStyle,
        isLateAddition: true,
        isEligibleBowler: selection.isEligibleBowler,
        joinedAt: now,
        joinedInningsId: innings.inningsId,
        joinedOverNumber: innings.legalBallsBowled ~/ state.config.ballsPerOver,
        joinedDeliverySequence: state.events.length + 1,
        addedToPermanentTeam: selection.addPermanently,
      );
      setState(
          () => _engine.addLatePlayer(teamId: team.id, player: latePlayer));
      await ref.read(matchRepositoryProvider).persistLatePlayer(
            state: _engine.state,
            teamId: team.id,
            player: latePlayer,
            mode: selection.addPermanently
                ? LatePlayerAddMode.teamAndCurrentMatch
                : LatePlayerAddMode.currentMatchOnly,
            addedBy: widget.deviceId,
          );
      if (!mounted) return latePlayer;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${latePlayer.name} was added to ${team.name} and is available for this match.',
        ),
      ));
      return latePlayer;
    } catch (error) {
      if (mounted) {
        setState(() => _engine = CricketScoringEngine(state));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
      }
      return null;
    }
  }

  void _showMatchSquads() {
    final state = _engine.state;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Match Squads',
                style: Theme.of(context).textTheme.headlineSmall),
            for (final team in [state.teamA, state.teamB]) ...[
              const SizedBox(height: 16),
              Text(team.name, style: Theme.of(context).textTheme.titleMedium),
              ...team.players.map((player) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(player.name),
                    subtitle: Text(player.isLateAddition
                        ? 'Joined during match · ${player.isAvailable ? 'Available' : 'Unavailable'}'
                        : 'Playing'),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Manage ${player.name}',
                      onSelected: (action) {
                        Navigator.pop(context);
                        if (action == 'remove') {
                          _removeLiveMatchPlayer(team, player);
                        } else {
                          _setLivePlayerAvailability(
                            team,
                            player,
                            action == 'available',
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove from Current Match'),
                        ),
                        PopupMenuItem(
                          value:
                              player.isAvailable ? 'unavailable' : 'available',
                          child: Text(player.isAvailable
                              ? 'Mark Unavailable'
                              : 'Restore Availability'),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _removeLiveMatchPlayer(Team team, Player player) async {
    final record = await ref
        .read(matchRepositoryProvider)
        .getMatchRecord(_engine.state.matchId);
    final isCaptain = player.id == record?.teamACaptainId ||
        player.id == record?.teamBCaptainId;
    if (isCaptain || _engine.hasPlayerParticipated(player.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${player.name} has already participated in this match and cannot be removed. Mark the player unavailable instead.',
        ),
      ));
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${player.name} from this match?'),
        content: Text(
          'The player will remain in the ${team.name} roster and can be selected for future matches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove from Match'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      setState(() => _engine.removeUnparticipatedPlayer(
            teamId: team.id,
            playerId: player.id,
          ));
      await ref.read(matchRepositoryProvider).persistSquadPlayerState(
            state: _engine.state,
            teamId: team.id,
            playerId: player.id,
            isActive: false,
            isAvailable: false,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${player.name} was removed from this match squad.'),
        ));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  Future<void> _setLivePlayerAvailability(
    Team team,
    Player player,
    bool available,
  ) async {
    setState(() => _engine.setPlayerAvailability(
          teamId: team.id,
          playerId: player.id,
          isAvailable: available,
        ));
    await ref.read(matchRepositoryProvider).persistSquadPlayerState(
          state: _engine.state,
          teamId: team.id,
          playerId: player.id,
          isActive: true,
          isAvailable: available,
        );
  }

  Future<bool> _handleBackPress() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave scoring screen?'),
        content: const Text(
            'Your match is saved safely. You can resume scoring anytime from the home screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('STAY & SCORE'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SAVE & GO HOME'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      if (mounted) {
        context.go('/');
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = _engine.state;

    // Render Match Result View if match is completed
    if (state.status == MatchStatus.completed ||
        state.status == MatchStatus.abandoned ||
        state.status == MatchStatus.noResult ||
        state.status == MatchStatus.cancelled) {
      return MatchResultView(matchState: state, engine: _engine);
    }

    final inn = state.activeInnings;
    final bowlingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamB : state.teamA;

    final liveFigures = const LiveFiguresService().calculate(state);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackPress,
          ),
          title: Text('${state.teamA.shortName} vs ${state.teamB.shortName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Swap Strikers',
              onPressed: _showBatterActions,
            ),
            IconButton(
              icon: const Icon(Icons.assessment),
              tooltip: 'Scorecard',
              onPressed: () {
                context.push('/scorecard', extra: _engine);
              },
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Fixed match context. Keeping this outside the scroll view means
              // the scorer never loses the score or current-over state.
              ScoreSummaryCard(
                key: const ValueKey('fixed-live-match-summary'),
                matchState: state,
                syncStatusText: _syncStatusText,
                isOnline: _isOnline,
                compact: true,
              ),
              // Only secondary live information scrolls. Expanded constrains
              // its viewport to the space between the fixed header and footer,
              // so content cannot render underneath the scoring controls.
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('live-scoring-scroll-area'),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      if (state.status == MatchStatus.inningsBreak) ...[
                        Card(
                          color: Colors.orange.shade800,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: const Text('FIRST INNINGS COMPLETE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Target for ${bowlingTeam.name}: ${(state.innings[0].totalRuns + 1)} Runs',
                                style: const TextStyle(color: Colors.white70)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.orange.shade800),
                              onPressed: _showSecondInningsModal,
                              child: const Text('START 2ND INNINGS',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                      LivePlayerFiguresPanel(
                        figures: liveFigures,
                        matchState: state,
                        onMorePressed: _showMoreActions,
                        onBowlerPressed: inn.flowState ==
                                InningsFlowState.scoring
                            ? () => _openBowlerSelectionModal(isMidOver: true)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.status == MatchStatus.live &&
                  !inn.isCompleted &&
                  inn.flowState == InningsFlowState.scoring)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    key: const ValueKey('fixed-scoring-keypad'),
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: const Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ScoringActionGrid(
                        onRunPressed: _recordRun,
                        onWicketPressed: _openWicketModal,
                        onExtrasPressed: _recordExtras,
                        onUndoPressed: _undo,
                        onMorePressed: _showMoreActions,
                      ),
                    ),
                  ),
                ),
              if (state.status == MatchStatus.live &&
                  inn.flowState == InningsFlowState.awaitingNextBatter)
                Card(
                  color: Colors.orange.shade50,
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: const Text(
                      'Wicket recorded. Select the next batter to continue.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: ElevatedButton(
                      onPressed: state.events.isEmpty
                          ? null
                          : () =>
                              _showRequiredNextBatterModal(state.events.last),
                      child: const Text('Select Batter'),
                    ),
                  ),
                ),
              if (state.status == MatchStatus.live &&
                  inn.flowState == InningsFlowState.awaitingNextBowler)
                Card(
                  color: Colors.orange.shade50,
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: const Text(
                      'Over complete. Select the next bowler to continue.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _openBowlerSelectionModal(isMidOver: false),
                      child: const Text('Select Next Bowler'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
