import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/local/database.dart';
import '../../core/theme.dart';
import '../../core/rules/captain_rules.dart';
import '../../core/rules/bowling_rule_config.dart';
import '../../core/validation/match_setup_validation.dart';
import '../../core/navigation/match_destination.dart';
import '../../core/utils/player_sorting.dart';
import '../common/widgets/draft_delete_dialog.dart';
import 'widgets/digital_coin_toss_widget.dart';

class MatchSetupWizard extends ConsumerStatefulWidget {
  final String? preselectTeamId;
  final String? draftId;

  const MatchSetupWizard({super.key, this.preselectTeamId, this.draftId});

  @override
  ConsumerState<MatchSetupWizard> createState() => _MatchSetupWizardState();
}

class _MatchSetupWizardState extends ConsumerState<MatchSetupWizard> {
  int _currentStep = 0;
  bool _checkingActiveMatch = true;
  bool _blockedByActiveMatch = false;

  // Step 1: Teams
  TeamsTableData? _teamA;
  TeamsTableData? _teamB;

  // Step 2: Details
  final _venueController = TextEditingController();
  final _oversController = TextEditingController(text: '20');
  final _maxOversController = TextEditingController(text: '4');
  int _totalOvers = 20;
  final int _ballsPerOver = 6;
  final String _format = 'custom';
  DateTime _matchDate = DateTime.now();
  bool _isScheduledDateCustom = false;
  int? _draftCreatedAt;

  // Step 3: Squads
  List<PlayersTableData> _teamAPlayers = [];
  List<PlayersTableData> _teamBPlayers = [];
  final Set<String> _selectedASquad = {};
  final Set<String> _selectedBSquad = {};
  final Set<String> _eligibleABowlers = {};
  final Set<String> _eligibleBBowlers = {};
  final Map<String, int> _perBowlerMaxOvers = {};
  BowlerLimitMode _bowlerLimitMode = BowlerLimitMode.localAutomatic;
  int _customMaxOversPerBowler = 4;
  bool _maxOversWasManuallyEdited = false;
  bool _allowConsecutiveOvers = false;
  bool _allowTacticalMidOverReplacement = false;
  String? _teamACaptainId;
  String? _teamBCaptainId;
  String? _teamAWicketkeeperId;
  String? _teamBWicketkeeperId;
  int _activeSquadTeamIndex = 0;
  bool _restoredTeamASquad = false;
  bool _restoredTeamBSquad = false;
  bool _loadingTeamAPlayers = false;
  bool _loadingTeamBPlayers = false;
  late final String _draftMatchId =
      widget.draftId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
  int get _minimumPlayersRequired => 2;

  // Step 4: Toss
  String? _tossWinnerId;
  String _tossDecision = 'BAT'; // BAT or BOWL
  String? _tossCallingTeamId;
  String? _tossCall; // HEADS or TAILS
  String? _coinResult; // HEADS or TAILS

  // Step 5: Openers
  String? _strikerId;
  String? _nonStrikerId;
  String? _bowlerId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final active = await ref.read(matchRepositoryProvider).getActiveMatch();
    if (!mounted) return;
    if (active != null) {
      setState(() {
        _checkingActiveMatch = false;
        _blockedByActiveMatch = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showActiveMatchDialog(active);
      });
      return;
    }
    await _loadInitialTeams();
    if (mounted) setState(() => _checkingActiveMatch = false);
  }

  Future<void> _showActiveMatchDialog(MatchesTableData active) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('A live match is already in progress'),
        content: const Text(
          'Only one match can be active at a time. Please finish or abandon the current match before creating a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.go(MatchDestinationResolver.routeFor(
                    matchId: active.id,
                    status: active.status,
                  ));
            },
            child: const Text('Resume Match'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInitialTeams() async {
    final teams = await ref.read(teamRepositoryProvider).getAllTeams();
    if (widget.draftId != null) {
      final draft = await ref
          .read(matchRepositoryProvider)
          .getMatchRecord(widget.draftId!);
      if (draft?.setupDraftJson != null) {
        final data = jsonDecode(draft!.setupDraftJson!) as Map<String, dynamic>;
        final matchingA =
            teams.where((team) => team.id == data['teamAId']).toList();
        final matchingB =
            teams.where((team) => team.id == data['teamBId']).toList();
        _teamA = matchingA.isEmpty ? null : matchingA.first;
        _teamB = matchingB.isEmpty ? null : matchingB.first;
        _venueController.text = data['venue'] as String? ?? '';
        _isScheduledDateCustom =
            data['isScheduledDateCustom'] as bool? ?? false;
        _draftCreatedAt = data['draftCreatedAt'] as int? ?? draft?.createdAt;
        final scheduledAt = data['scheduledAt'] as int?;
        if (_isScheduledDateCustom && scheduledAt != null) {
          _matchDate = DateTime.fromMillisecondsSinceEpoch(scheduledAt);
        } else {
          _matchDate = DateTime.now();
        }
        _totalOvers = data['overs'] as int? ?? 20;
        _oversController.text = '$_totalOvers';
        _currentStep = data['currentStep'] as int? ?? 0;
        _teamACaptainId = data['teamACaptainId'] as String?;
        _teamBCaptainId = data['teamBCaptainId'] as String?;
        _teamAWicketkeeperId = data['teamAWicketkeeperId'] as String?;
        _teamBWicketkeeperId = data['teamBWicketkeeperId'] as String?;
        _restoredTeamASquad = data.containsKey('teamASquad');
        _restoredTeamBSquad = data.containsKey('teamBSquad');
        _selectedASquad.addAll(
          (data['teamASquad'] as List<dynamic>? ?? const []).cast<String>(),
        );
        _selectedBSquad.addAll(
          (data['teamBSquad'] as List<dynamic>? ?? const []).cast<String>(),
        );
        _tossCallingTeamId = data['tossCallingTeamId'] as String? ?? draft?.tossCallingTeamId;
        _tossCall = data['tossCall'] as String? ?? draft?.tossCall;
        _coinResult = data['coinResult'] as String? ?? draft?.coinResult;
        _tossWinnerId = data['tossWinnerTeamId'] as String? ?? draft?.tossWinnerTeamId;
        _tossDecision = data['tossDecision'] as String? ?? draft?.tossDecision ?? 'BAT';
        _eligibleABowlers.addAll(
          (data['eligibleABowlers'] as List<dynamic>? ?? const [])
              .cast<String>(),
        );
        _eligibleBBowlers.addAll(
          (data['eligibleBBowlers'] as List<dynamic>? ?? const [])
              .cast<String>(),
        );
        _bowlerLimitMode = BowlerLimitMode.values.firstWhere(
          (value) => value.name == data['bowlerLimitMode'],
          orElse: () => BowlerLimitMode.localAutomatic,
        );
        _maxOversWasManuallyEdited =
            data['maxOversWasManuallyEdited'] as bool? ?? false;
        _customMaxOversPerBowler = data['customMaxOversPerBowler'] as int? ??
            BowlingRuleConfig.suggestOfficialMaxOversPerBowler(_totalOvers);
        // Older drafts stored the Step 3 one-over default without recording a
        // user choice. Re-suggest it when Match Details is reopened.
        if (!_maxOversWasManuallyEdited) {
          _customMaxOversPerBowler =
              BowlingRuleConfig.suggestOfficialMaxOversPerBowler(_totalOvers);
        }
        _maxOversController.text = '$_customMaxOversPerBowler';
        _allowConsecutiveOvers =
            data['allowConsecutiveOvers'] as bool? ?? false;
        _allowTacticalMidOverReplacement =
            data['allowTacticalMidOverReplacement'] as bool? ?? false;
        final restoredLimits = data['perBowlerMaxOvers'] as Map?;
        if (restoredLimits != null) {
          _perBowlerMaxOvers.addAll(restoredLimits.map(
            (key, value) => MapEntry(key as String, value as int),
          ));
        }
        await _loadSquads();
      }
    }
    if (widget.preselectTeamId != null &&
        teams.any((t) => t.id == widget.preselectTeamId)) {
      final preselected =
          teams.firstWhere((t) => t.id == widget.preselectTeamId);
      await _selectTeam(preselected, isTeamA: true);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _venueController.dispose();
    _oversController.dispose();
    _maxOversController.dispose();
    super.dispose();
  }

  Future<void> _loadSquads() async {
    if (_teamA != null) {
      await _loadPlayersForTeam(_teamA!, isTeamA: true);
    }
    if (_teamB != null) {
      await _loadPlayersForTeam(_teamB!, isTeamA: false);
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadPlayersForTeam(
    TeamsTableData team, {
    required bool isTeamA,
  }) async {
    setState(() {
      if (isTeamA) {
        _loadingTeamAPlayers = true;
      } else {
        _loadingTeamBPlayers = true;
      }
    });
    final players =
        await ref.read(teamRepositoryProvider).getTeamPlayers(team.id);
    if (!mounted) return;
    setState(() {
      final playerIds = players.map((player) => player.id).toSet();
      final profiledBowlers = players
          .where((player) =>
              player.bowlingStyle != BowlingStyle.none.name &&
              player.bowlingStyle != BowlingStyle.notSet.name)
          .map((player) => player.id);
      final defaults = players.where((player) => player.isCaptain).toList();
      if (isTeamA) {
        _teamAPlayers = players;
        _selectedASquad.removeWhere((id) => !playerIds.contains(id));
        if (!_restoredTeamASquad) {
          _selectedASquad.addAll(playerIds);
        }
        _eligibleABowlers.removeWhere((id) => !playerIds.contains(id));
        if (_eligibleABowlers.isEmpty) {
          _eligibleABowlers.addAll(profiledBowlers);
        }
        if (!playerIds.contains(_teamACaptainId)) {
          _teamACaptainId = playerIds.contains(team.defaultCaptainId)
              ? team.defaultCaptainId
              : (defaults.isEmpty ? null : defaults.first.id);
        }
        if (!playerIds.contains(_teamAWicketkeeperId)) {
          final keepers = players.where((player) => player.isWicketKeeper);
          _teamAWicketkeeperId = keepers.isEmpty ? null : keepers.first.id;
        }
        _loadingTeamAPlayers = false;
      } else {
        _teamBPlayers = players;
        _selectedBSquad.removeWhere((id) => !playerIds.contains(id));
        if (!_restoredTeamBSquad) {
          _selectedBSquad.addAll(playerIds);
        }
        _eligibleBBowlers.removeWhere((id) => !playerIds.contains(id));
        if (_eligibleBBowlers.isEmpty) {
          _eligibleBBowlers.addAll(profiledBowlers);
        }
        if (!playerIds.contains(_teamBCaptainId)) {
          _teamBCaptainId = playerIds.contains(team.defaultCaptainId)
              ? team.defaultCaptainId
              : (defaults.isEmpty ? null : defaults.first.id);
        }
        if (!playerIds.contains(_teamBWicketkeeperId)) {
          final keepers = players.where((player) => player.isWicketKeeper);
          _teamBWicketkeeperId = keepers.isEmpty ? null : keepers.first.id;
        }
        _loadingTeamBPlayers = false;
      }
    });
  }

  Future<void> _selectTeam(TeamsTableData? team,
      {required bool isTeamA}) async {
    setState(() {
      if (isTeamA) {
        _teamA = team;
        _teamAPlayers = [];
        _selectedASquad.clear();
        _eligibleABowlers.clear();
        _restoredTeamASquad = false;
        _teamACaptainId = null;
        _teamAWicketkeeperId = null;
      } else {
        _teamB = team;
        _teamBPlayers = [];
        _selectedBSquad.clear();
        _eligibleBBowlers.clear();
        _restoredTeamBSquad = false;
        _teamBCaptainId = null;
        _teamBWicketkeeperId = null;
      }
    });
    if (team != null) {
      await _loadPlayersForTeam(team, isTeamA: isTeamA);
    }
  }

  Future<void> _persistDraft({bool exitAfterSave = false}) async {
    if (_teamA == null || _teamB == null) return;
    _totalOvers = int.tryParse(_oversController.text.trim()) ?? _totalOvers;
    final matchName = '${_teamA!.name} vs ${_teamB!.name}';

    await ref.read(matchRepositoryProvider).saveMatch(
          id: _draftMatchId,
          matchName: matchName,
          teamAId: _teamA!.id,
          teamBId: _teamB!.id,
          format: _format,
          totalOvers: _totalOvers,
          ballsPerOver: _ballsPerOver,
          maxOversPerBowler: _customMaxOversPerBowler,
          allowConsecutiveOvers: _allowConsecutiveOvers,
          maxOversWasManuallyEdited: _maxOversWasManuallyEdited,
          venueName: _venueController.text.trim(),
          scheduledAt: _matchDate.millisecondsSinceEpoch,
          tossWinnerTeamId: _tossWinnerId,
          tossDecision: _tossDecision,
          tossCallingTeamId: _tossCallingTeamId,
          tossCall: _tossCall,
          coinResult: _coinResult,
          teamASquadJson: jsonEncode(_selectedASquad.toList()),
          teamBSquadJson: jsonEncode(_selectedBSquad.toList()),
          teamACaptainId: _teamACaptainId,
          teamBCaptainId: _teamBCaptainId,
          teamAWicketkeeperId: _teamAWicketkeeperId,
          teamBWicketkeeperId: _teamBWicketkeeperId,
          setupDraftJson: jsonEncode({
            'teamAId': _teamA!.id,
            'teamBId': _teamB!.id,
            'venue': _venueController.text,
            'overs': _totalOvers,
            'format': _format,
            'scheduledAt': _matchDate.millisecondsSinceEpoch,
            'isScheduledDateCustom': _isScheduledDateCustom,
            'draftCreatedAt':
                _draftCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
            'draftUpdatedAt': DateTime.now().millisecondsSinceEpoch,
            'currentStep': _currentStep,
            'teamACaptainId': _teamACaptainId,
            'teamBCaptainId': _teamBCaptainId,
            'teamAWicketkeeperId': _teamAWicketkeeperId,
            'teamBWicketkeeperId': _teamBWicketkeeperId,
            'teamASquad': _selectedASquad.toList(),
            'teamBSquad': _selectedBSquad.toList(),
            'tossCallingTeamId': _tossCallingTeamId,
            'tossCall': _tossCall,
            'coinResult': _coinResult,
            'tossWinnerTeamId': _tossWinnerId,
            'tossDecision': _tossDecision,
            'eligibleABowlers': _eligibleABowlers.toList(),
            'eligibleBBowlers': _eligibleBBowlers.toList(),
            'bowlerLimitMode': _bowlerLimitMode.name,
            'customMaxOversPerBowler': _customMaxOversPerBowler,
            'maxOversWasManuallyEdited': _maxOversWasManuallyEdited,
            'allowConsecutiveOvers': _allowConsecutiveOvers,
            'allowTacticalMidOverReplacement': _allowTacticalMidOverReplacement,
            'perBowlerMaxOvers': _perBowlerMaxOvers,
          }),
          status: 'draft',
          currentScorerDeviceId: 'device_local',
        );
    if (mounted && exitAfterSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match setup saved to Drafts!')),
      );
      context.pop();
    }
  }

  Future<void> _openPlayerRecovery(
    TeamsTableData team, {
    required bool isTeamA,
  }) async {
    final existingIds = (isTeamA ? _teamAPlayers : _teamBPlayers)
        .map((player) => player.id)
        .toSet();
    await _persistDraft();
    if (!mounted) return;
    await context.push(
      '/teams/add-players/${team.id}?returnToMatchSetup=true',
    );
    if (!mounted) return;
    await _loadPlayersForTeam(team, isTeamA: isTeamA);
    if (!mounted) return;
    final players = isTeamA ? _teamAPlayers : _teamBPlayers;
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    final eligible = isTeamA ? _eligibleABowlers : _eligibleBBowlers;
    final addedPlayers =
        players.where((player) => !existingIds.contains(player.id)).toList();
    if (addedPlayers.isNotEmpty) {
      setState(() {
        selected.addAll(addedPlayers.map((player) => player.id));
        eligible.addAll(addedPlayers
            .where((player) =>
                player.bowlingStyle != BowlingStyle.none.name &&
                player.bowlingStyle != BowlingStyle.notSet.name)
            .map((player) => player.id));
      });
    }
  }

  void _toggleSquadPlayer(
    PlayersTableData player, {
    required bool isTeamA,
  }) {
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    if (!selected.contains(player.id)) {
      setState(() {
        selected.add(player.id);
        if (player.bowlingStyle != BowlingStyle.none.name &&
            player.bowlingStyle != BowlingStyle.notSet.name) {
          (isTeamA ? _eligibleABowlers : _eligibleBBowlers).add(player.id);
        }
      });
      return;
    }
    final wasCaptain =
        (isTeamA ? _teamACaptainId : _teamBCaptainId) == player.id;
    final wasKeeper =
        (isTeamA ? _teamAWicketkeeperId : _teamBWicketkeeperId) == player.id;
    setState(() {
      selected.remove(player.id);
      (isTeamA ? _eligibleABowlers : _eligibleBBowlers).remove(player.id);
      if (isTeamA && wasCaptain) _teamACaptainId = null;
      if (!isTeamA && wasCaptain) _teamBCaptainId = null;
      if (isTeamA && _teamAWicketkeeperId == player.id) {
        _teamAWicketkeeperId = null;
      }
      if (!isTeamA && _teamBWicketkeeperId == player.id) {
        _teamBWicketkeeperId = null;
      }
      if (_strikerId == player.id) _strikerId = null;
      if (_nonStrikerId == player.id) _nonStrikerId = null;
      if (_bowlerId == player.id) _bowlerId = null;
    });
    if (wasCaptain) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'The selected captain was removed. Choose a new captain before continuing.',
        ),
      ));
    } else if (wasKeeper) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a new wicketkeeper before continuing.'),
      ));
    }
  }

  void _selectAllSquadPlayers({required bool isTeamA}) {
    final players = isTeamA ? _teamAPlayers : _teamBPlayers;
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    final eligible = isTeamA ? _eligibleABowlers : _eligibleBBowlers;
    setState(() {
      selected.addAll(players.map((player) => player.id));
      eligible.addAll(players
          .where((player) =>
              player.bowlingStyle != BowlingStyle.none.name &&
              player.bowlingStyle != BowlingStyle.notSet.name)
          .map((player) => player.id));
    });
  }

  Future<void> _clearSquadSelection({required bool isTeamA}) async {
    final team = isTeamA ? _teamA : _teamB;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Clear all selected players for ${team?.name ?? 'this team'}?'),
        content: const Text(
          'This changes only the current match squad. The permanent team roster is unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      (isTeamA ? _selectedASquad : _selectedBSquad).clear();
      (isTeamA ? _eligibleABowlers : _eligibleBBowlers).clear();
      if (isTeamA) {
        _teamACaptainId = null;
        _teamAWicketkeeperId = null;
      } else {
        _teamBCaptainId = null;
        _teamBWicketkeeperId = null;
      }
      _strikerId = null;
      _nonStrikerId = null;
      _bowlerId = null;
    });
  }

  MatchSetupValidation get _teamValidation => MatchSetupValidator.validateTeams(
        teamAId: _teamA?.id,
        teamAName: _teamA?.name,
        teamAPlayerCount: _teamAPlayers.length,
        teamBId: _teamB?.id,
        teamBName: _teamB?.name,
        teamBPlayerCount: _teamBPlayers.length,
        minimumPlayersRequired: _minimumPlayersRequired,
      );

  void _startMatch() async {
    final active = await ref.read(matchRepositoryProvider).getActiveMatch();
    if (active != null) {
      if (mounted) await _showActiveMatchDialog(active);
      return;
    }
    if (_strikerId == null || _nonStrikerId == null || _bowlerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select opening batters and bowler')));
      return;
    }
    if (!_hasValidCaptains) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Select exactly one captain for each team before starting the match.'),
        ),
      );
      return;
    }

    final matchId = _draftMatchId;
    final matchName = '${_teamA!.name} vs ${_teamB!.name}';

    final aEligible = _eligibleABowlers.intersection(_selectedASquad).length;
    final bEligible = _eligibleBBowlers.intersection(_selectedBSquad).length;
    final calculatedMaxOvers = _effectiveEqualBowlerLimit;
    final validationA = BowlingRules.validate(
      totalOvers: _totalOvers,
      eligibleBowlerCount: aEligible,
      mode: _bowlerLimitMode,
      equalMaxOvers: calculatedMaxOvers,
      allowConsecutiveOvers: _allowConsecutiveOvers,
      perBowlerMaxOvers: Map.fromEntries(_perBowlerMaxOvers.entries
          .where((entry) => _eligibleABowlers.contains(entry.key))),
    );
    final validationB = BowlingRules.validate(
      totalOvers: _totalOvers,
      eligibleBowlerCount: bEligible,
      mode: _bowlerLimitMode,
      equalMaxOvers: calculatedMaxOvers,
      allowConsecutiveOvers: _allowConsecutiveOvers,
      perBowlerMaxOvers: Map.fromEntries(_perBowlerMaxOvers.entries
          .where((entry) => _eligibleBBowlers.contains(entry.key))),
    );
    final validation = !validationA.isValid ? validationA : validationB;
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.message!),
        ),
      );
      return;
    }

    final config = MatchConfig(
      format: MatchFormat.custom,
      totalOvers: _totalOvers,
      ballsPerOver: _ballsPerOver,
      maxOversPerBowler: calculatedMaxOvers,
      bowlerLimitMode: _bowlerLimitMode,
      eligibleBowlerIds: {..._eligibleABowlers, ..._eligibleBBowlers}.toList(),
      perBowlerMaxOvers: Map.unmodifiable(_perBowlerMaxOvers),
      perBowlerMaximumLegalBalls: {
        for (final entry in _perBowlerMaxOvers.entries)
          entry.key: entry.value * _ballsPerOver,
      },
      allowConsecutiveOvers: _allowConsecutiveOvers,
      allowMidOverBowlerReplacement: true,
      allowTacticalMidOverReplacement: _allowTacticalMidOverReplacement,
      bowlingRulesConfirmedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final engine = CricketScoringEngine.createMatch(
      matchId: matchId,
      config: config,
      teamA: Team(
        id: _teamA!.id,
        name: _teamA!.name,
        shortName: _teamA!.shortName,
        players: _teamAPlayers
            .where((p) => _selectedASquad.contains(p.id))
            .map((p) => Player(
                  id: p.id,
                  name: p.name,
                  battingStyle: _parseBattingStyle(p.battingStyle),
                  bowlingStyle: _parseBowlingStyle(p.bowlingStyle),
                  isEligibleBowler: _eligibleABowlers.contains(p.id),
                ))
            .toList(),
      ),
      teamB: Team(
        id: _teamB!.id,
        name: _teamB!.name,
        shortName: _teamB!.shortName,
        players: _teamBPlayers
            .where((p) => _selectedBSquad.contains(p.id))
            .map((p) => Player(
                  id: p.id,
                  name: p.name,
                  battingStyle: _parseBattingStyle(p.battingStyle),
                  bowlingStyle: _parseBowlingStyle(p.bowlingStyle),
                  isEligibleBowler: _eligibleBBowlers.contains(p.id),
                ))
            .toList(),
      ),
      tossWinnerTeamId: _tossWinnerId!,
      tossDecision: _tossDecision,
      tossCallingTeamId: _tossCallingTeamId,
      tossCall: _tossCall,
      coinResult: _coinResult,
      openingStrikerId: _strikerId!,
      openingNonStrikerId: _nonStrikerId!,
      openingBowlerId: _bowlerId!,
      teamRoleSnapshots: [
        MatchTeamRoleSnapshot(
          teamId: _teamA!.id,
          captainPlayerId: _teamACaptainId!,
          wicketkeeperPlayerId: _teamAWicketkeeperId,
        ),
        MatchTeamRoleSnapshot(
          teamId: _teamB!.id,
          captainPlayerId: _teamBCaptainId!,
          wicketkeeperPlayerId: _teamBWicketkeeperId,
        ),
      ],
      scheduledAt: _isScheduledDateCustom
          ? _matchDate.millisecondsSinceEpoch
          : DateTime.now().millisecondsSinceEpoch,
      startedAt: DateTime.now().millisecondsSinceEpoch,
      createdAt: _draftCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
      venueName: _venueController.text.trim(),
      matchTimeZone: DateTime.now().timeZoneName,
    );

    final repository = ref.read(matchRepositoryProvider);
    try {
      await repository.saveMatch(
        id: matchId,
        matchName: matchName,
        teamAId: _teamA!.id,
        teamBId: _teamB!.id,
        format: _format,
        totalOvers: _totalOvers,
        ballsPerOver: _ballsPerOver,
        maxOversPerBowler: calculatedMaxOvers,
        allowConsecutiveOvers: _allowConsecutiveOvers,
        maxOversWasManuallyEdited: _maxOversWasManuallyEdited,
        venueName: _venueController.text.trim(),
        scheduledAt: engine.state.scheduledAt ?? DateTime.now().millisecondsSinceEpoch,
        startedAt: engine.state.startedAt,
        matchTimeZone: engine.state.matchTimeZone,
        tossWinnerTeamId: _tossWinnerId,
        tossDecision: _tossDecision,
        tossCallingTeamId: _tossCallingTeamId,
        tossCall: _tossCall,
        coinResult: _coinResult,
        teamASquadJson: jsonEncode(_selectedASquad.toList()),
        teamBSquadJson: jsonEncode(_selectedBSquad.toList()),
        teamACaptainId: _teamACaptainId,
        teamBCaptainId: _teamBCaptainId,
        teamAWicketkeeperId: _teamAWicketkeeperId,
        teamBWicketkeeperId: _teamBWicketkeeperId,
        status: 'live',
        currentScorerDeviceId: 'device_local',
      );
    } on StateError {
      final existing = await repository.getActiveMatch();
      if (mounted && existing != null) await _showActiveMatchDialog(existing);
      return;
    }
    // Persist the complete initial innings before navigation. History and
    // restart recovery can now resume this exact match immediately.
    await repository.persistState(engine.state);

    if (mounted) {
      context.pushReplacement(
        '/matches/$matchId/scoring',
        extra: engine.state,
      );
    }
  }

  Future<void> _confirmAndDeleteDraft() async {
    final name = (_teamA != null && _teamB != null)
        ? '${_teamA!.name} vs ${_teamB!.name}'
        : 'Draft Match';
    final confirmed = await showDeleteDraftConfirmationDialog(
      context,
      matchName: name,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(matchRepositoryProvider).deleteDraftMatch(_draftMatchId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft match deleted.')),
      );
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete draft match: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingActiveMatch || _blockedByActiveMatch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Setup'),
        actions: [
          TextButton(
            onPressed: () => _persistDraft(exitAfterSave: true),
            child:
                const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
          if (widget.draftId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Delete Draft',
              onPressed: _confirmAndDeleteDraft,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildCompactProgress(),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('match-setup-step-$_currentStep'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: _currentStepContent,
              ),
            ),
            _buildStickySetupActions(),
          ],
        ),
      ),
    );
  }

  static const _stepLabels = [
    'Teams',
    'Details',
    'Squads',
    'Toss',
    'Openers',
    'Review',
  ];

  Widget get _currentStepContent => [
        _buildTeamSelectionStep().content,
        _buildMatchDetailsStep().content,
        _buildSquadSelectionStep().content,
        _buildTossStep().content,
        _buildOpenersStep().content,
        _buildConfirmationStep().content,
      ][_currentStep];

  Widget _buildCompactProgress() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Step ${_currentStep + 1} of 6 · ${_stepLabels[_currentStep]}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 6,
            minHeight: 5,
            borderRadius: BorderRadius.circular(99),
          ),
        ]),
      );

  bool get _tossIsReady =>
      _tossCallingTeamId != null &&
      _tossCall != null &&
      _coinResult != null &&
      _tossWinnerId != null;

  Widget _buildStickySetupActions() {
    final blocked = (_currentStep == 0 &&
            (_loadingTeamAPlayers ||
                _loadingTeamBPlayers ||
                !_teamValidation.isValid)) ||
        (_currentStep == 3 && !_tossIsReady) ||
        (_currentStep == 5 && !_reviewIsReady);
    return Container(
      key: const ValueKey('match-setup-sticky-actions'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            ),
          )
        else
          Expanded(
            child: OutlinedButton(
              onPressed: () => _persistDraft(exitAfterSave: true),
              child: const Text('Save Draft'),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: blocked ? null : _continueSetup,
            child: Text(_currentStep == 5 ? 'Start Match' : 'Continue'),
          ),
        ),
      ]),
    );
  }

  void _continueSetup() {
    if (_currentStep == 0) {
      if (_teamA == null || _teamB == null) {
        _showSetupIssue('Please select two distinct teams.');
        return;
      }
      if (_loadingTeamAPlayers || _loadingTeamBPlayers) return;
      if (!_teamValidation.isValid) {
        _showSetupIssue(_teamValidation.issues.first.message);
        return;
      }
    } else if (_currentStep == 1) {
      final overs = int.tryParse(_oversController.text.trim());
      if (overs == null || overs < 2 || overs > 50) {
        _showSetupIssue('Total overs must be between 2 and 50.');
        return;
      }
      _totalOvers = overs;
      final maxOvers = int.tryParse(_maxOversController.text.trim());
      if (maxOvers == null || maxOvers < 1) {
        _showSetupIssue('Enter at least 1 over per bowler.');
        return;
      }
      if (maxOvers > overs) {
        _showSetupIssue(
            'Maximum overs per bowler cannot exceed the total match overs.');
        return;
      }
      _customMaxOversPerBowler = maxOvers;
    } else if (_currentStep == 2) {
      final firstIssue = _firstSquadReadinessIssue;
      if (firstIssue != null) {
        _showSetupIssue(firstIssue);
        return;
      }
    } else if (_currentStep == 3) {
      if (!_tossIsReady) {
        if (_tossCallingTeamId == null) {
          _showSetupIssue('Please select which team calls the toss.');
        } else if (_tossCall == null) {
          _showSetupIssue('Please choose your call (HEADS or TAILS).');
        } else if (_coinResult == null || _tossWinnerId == null) {
          _showSetupIssue('Please flip the coin to determine the toss winner.');
        } else {
          _showSetupIssue('Please complete the toss decision.');
        }
        return;
      }
    } else if (_currentStep == 4) {
      if (_strikerId == null || _nonStrikerId == null || _bowlerId == null) {
        _showSetupIssue('Select striker, non-striker, and opening bowler.');
        return;
      }
      if (_strikerId == _nonStrikerId) {
        _showSetupIssue('Striker and non-striker must be different.');
        return;
      }
    } else if (_currentStep == 5 && !_reviewIsReady) {
      _showSetupIssue(_reviewReadinessIssue);
      return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _startMatch();
    }
  }

  void _showSetupIssue(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Step _buildTeamSelectionStep() {
    return Step(
      title: const Text('Teams'),
      isActive: _currentStep >= 0,
      content: FutureBuilder<List<TeamsTableData>>(
        future: ref.read(teamRepositoryProvider).getAllTeams(),
        builder: (context, snapshot) {
          final rawTeams = snapshot.data ?? [];
          final uniqueTeamsMap = <String, TeamsTableData>{};
          for (final t in rawTeams) {
            uniqueTeamsMap[t.id] = t;
          }
          final teams = uniqueTeamsMap.values.toList();

          if (_teamA != null && uniqueTeamsMap.containsKey(_teamA!.id)) {
            _teamA = uniqueTeamsMap[_teamA!.id];
          }
          if (_teamB != null && uniqueTeamsMap.containsKey(_teamB!.id)) {
            _teamB = uniqueTeamsMap[_teamB!.id];
          }

          if (teams.length < 2) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text(
                      'Two teams are required to setup a match.',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'You currently have ${teams.length} team(s) saved in the database.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                      icon: const Icon(Icons.group_add),
                      label: const Text('CREATE NEW TEAM'),
                      onPressed: () => context.push('/teams/create'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Team A',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Team'),
                    onPressed: () => context.push('/teams/create'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: (_teamA != null &&
                        teams.any(
                            (t) => t.id == _teamA!.id && t.id != _teamB?.id))
                    ? _teamA!.id
                    : null,
                hint: const Text('Choose Team A'),
                decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                items: teams
                    .where((t) => t.id != _teamB?.id)
                    .map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (selectedId) {
                  if (selectedId == null) {
                    _selectTeam(null, isTeamA: true);
                  } else {
                    final selected = uniqueTeamsMap[selectedId];
                    _selectTeam(selected, isTeamA: true);
                  }
                },
              ),
              if (_teamA != null) ...[
                const SizedBox(height: 10),
                _buildSelectedTeamStatus(
                  team: _teamA!,
                  players: _teamAPlayers,
                  isTeamA: true,
                  isLoading: _loadingTeamAPlayers,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Team B',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Team'),
                    onPressed: () => context.push('/teams/create'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: (_teamB != null &&
                        teams.any(
                            (t) => t.id == _teamB!.id && t.id != _teamA?.id))
                    ? _teamB!.id
                    : null,
                hint: const Text('Choose Team B'),
                decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                items: teams
                    .where((t) => t.id != _teamA?.id)
                    .map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (selectedId) {
                  if (selectedId == null) {
                    _selectTeam(null, isTeamA: false);
                  } else {
                    final selected = uniqueTeamsMap[selectedId];
                    _selectTeam(selected, isTeamA: false);
                  }
                },
              ),
              if (_teamB != null) ...[
                const SizedBox(height: 10),
                _buildSelectedTeamStatus(
                  team: _teamB!,
                  players: _teamBPlayers,
                  isTeamA: false,
                  isLoading: _loadingTeamBPlayers,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedTeamStatus({
    required TeamsTableData team,
    required List<PlayersTableData> players,
    required bool isTeamA,
    required bool isLoading,
  }) {
    final issue = _teamValidation.issueForTeam(team.id);
    final missingCount =
        (_minimumPlayersRequired - players.length).clamp(0, 999);
    return Card(
      color: issue == null ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  issue == null ? Icons.check_circle : Icons.warning_amber,
                  color: issue == null ? Colors.green.shade700 : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        isLoading
                            ? 'Checking players…'
                            : '${players.length} ${players.length == 1 ? "Player" : "Players"}',
                      ),
                    ],
                  ),
                ),
                Text(
                  issue == null ? 'Ready' : 'Setup incomplete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: issue == null
                        ? Colors.green.shade800
                        : Colors.orange.shade900,
                  ),
                ),
              ],
            ),
            if (!isLoading && issue != null) ...[
              const SizedBox(height: 8),
              Text(issue.message),
              if (missingCount > 0)
                Text(
                  missingCount == 1
                      ? 'Add 1 more player'
                      : 'Add $missingCount more players',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: Text('Add Players to ${team.name}'),
                    onPressed: () =>
                        _openPlayerRecovery(team, isTeamA: isTeamA),
                  ),
                  TextButton(
                    onPressed: () => _selectTeam(null, isTeamA: isTeamA),
                    child: const Text('Choose Another Team'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Step _buildMatchDetailsStep() {
    return Step(
      title: const Text('Details'),
      isActive: _currentStep >= 1,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Rules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _format,
            decoration: const InputDecoration(
                labelText: 'Match Format', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'custom', child: Text('Custom Match')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _oversController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Total Overs (2 to 50 Overs) *',
              hintText: 'Enter total overs (e.g. 20)',
              prefixIcon: Icon(Icons.timer),
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              final parsed = int.tryParse(val ?? '');
              if (parsed == null || parsed < 2 || parsed > 50) {
                return 'Overs must be between 2 and 50 overs';
              }
              return null;
            },
            onChanged: (value) {
              final overs = int.tryParse(value);
              if (overs == null || overs < 1 || overs > 50) return;
              final config = BowlingRuleConfig(
                totalOvers: _totalOvers,
                maxOversPerBowler: _customMaxOversPerBowler,
                wasManuallyEdited: _maxOversWasManuallyEdited,
                allowConsecutiveOvers: _allowConsecutiveOvers,
              ).withTotalOvers(overs);
              setState(() {
                _totalOvers = overs;
                _customMaxOversPerBowler = config.maxOversPerBowler;
                _maxOversWasManuallyEdited = config.wasManuallyEdited;
                _maxOversController.text = '${config.maxOversPerBowler}';
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('maximum-overs-per-bowler-field'),
            controller: _maxOversController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Maximum Overs Per Bowler',
              border: OutlineInputBorder(),
              helperText:
                  'Suggested from match overs. You can edit this value.',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              setState(() {
                _maxOversWasManuallyEdited = true;
                if (parsed != null) _customMaxOversPerBowler = parsed;
              });
            },
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Balls Per Over', border: OutlineInputBorder()),
            child: Text('$_ballsPerOver'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title:
                const Text('Allow the same bowler to bowl consecutive overs'),
            subtitle: const Text(
                'When disabled, the bowler who completed the previous over cannot bowl the next over.'),
            value: _allowConsecutiveOvers,
            onChanged: (value) =>
                setState(() => _allowConsecutiveOvers = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow tactical mid-over bowler replacement'),
            subtitle: const Text(
              'Injury, illness, suspension, or incapacity replacements remain available. Enable this only for local tactical changes.',
            ),
            value: _allowTacticalMidOverReplacement,
            onChanged: (value) =>
                setState(() => _allowTacticalMidOverReplacement = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _venueController,
            decoration: const InputDecoration(
              labelText: 'Venue / Ground (Optional)',
              hintText: 'e.g. Oval Stadium',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date and Time'),
            subtitle: Text(
                '${MaterialLocalizations.of(context).formatFullDate(_matchDate)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_matchDate))}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: _matchDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (selected == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_matchDate),
              );
              if (time != null) {
                setState(() {
                  _matchDate = DateTime(selected.year, selected.month,
                      selected.day, time.hour, time.minute);
                  _isScheduledDateCustom = true;
                });
                _persistDraft();
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Standard cricket rule applied: 6 legal deliveries per over (excluding wides and no-balls).',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Step _buildSquadSelectionStep() {
    return Step(
      title: const Text('Squads'),
      isActive: _currentStep >= 2,
      content: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final teamA = _buildSquadTeamCard(isTeamA: true);
          final teamB = _buildSquadTeamCard(isTeamA: false);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!wide) ...[
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text(
                            '${_teamA?.shortName ?? "Team A"} · ${_selectedASquad.length}'),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text(
                            '${_teamB?.shortName ?? "Team B"} · ${_selectedBSquad.length}'),
                      ),
                    ],
                    selected: {_activeSquadTeamIndex},
                    onSelectionChanged: (selection) =>
                        setState(() => _activeSquadTeamIndex = selection.first),
                    showSelectedIcon: false,
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(
                      key: ValueKey(_activeSquadTeamIndex),
                      child: _activeSquadTeamIndex == 0 ? teamA : teamB,
                    ),
                  ),
                ] else
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: teamA),
                    const SizedBox(width: 12),
                    Expanded(child: teamB),
                  ]),
              ]);
        },
      ),
    );
  }

  Widget _buildSquadTeamCard({required bool isTeamA}) {
    final team = isTeamA ? _teamA : _teamB;
    final players = sortPlayerItemsByName(
      isTeamA ? _teamAPlayers : _teamBPlayers,
      nameOf: (player) => player.name,
      idOf: (player) => player.id,
      jerseyNumberOf: (player) => player.jerseyNumber,
    );
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    final eligible = isTeamA ? _eligibleABowlers : _eligibleBBowlers;
    final captainId = isTeamA ? _teamACaptainId : _teamBCaptainId;
    final wicketkeeperId =
        isTeamA ? _teamAWicketkeeperId : _teamBWicketkeeperId;
    final readiness = _squadReadiness(isTeamA: isTeamA);
    String playerName(String? id) {
      final matches = players.where((player) => player.id == id);
      return matches.isEmpty ? 'Not selected' : matches.first.name;
    }

    return Container(
      key: ValueKey('squad-team-${isTeamA ? 'a' : 'b'}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text((team?.shortName ?? 'TEAM').toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              _SquadStatusBadge(isReady: readiness.isValid),
            ]),
            const SizedBox(height: 6),
            Text(
              'Selected: ${selected.length} of ${players.length} · Max wickets ${InningsCompletionEvaluator.calculateMaximumWickets(playingMemberCount: selected.length)}',
              style: const TextStyle(fontSize: 13),
            ),
            Text('Captain: ${playerName(captainId)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(
              'WK: ${playerName(wicketkeeperId)} · Bowlers: ${eligible.intersection(selected).length}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Row(children: [
            TextButton(
              onPressed: selected.length == players.length
                  ? null
                  : () => _selectAllSquadPlayers(isTeamA: isTeamA),
              child: const Text('Select All'),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => _clearSquadSelection(isTeamA: isTeamA),
              child: const Text('Clear Selection'),
            ),
          ]),
        ),
        const Divider(height: 1),
        for (var index = 0; index < players.length; index++) ...[
          _buildSquadPlayerRow(
            player: players[index],
            isTeamA: isTeamA,
          ),
          if (index != players.length - 1) const Divider(height: 1, indent: 46),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: OutlinedButton.icon(
            onPressed: team == null
                ? null
                : () => _openPlayerRecovery(team, isTeamA: isTeamA),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: Text('Add Player to ${team?.shortName ?? 'Team'}'),
          ),
        ),
        Container(
          width: double.infinity,
          color:
              readiness.isValid ? Colors.green.shade50 : Colors.orange.shade50,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: readiness.items
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Icon(
                            item.isValid
                                ? Icons.check_circle
                                : Icons.warning_amber,
                            size: 16,
                            color: item.isValid
                                ? Colors.green.shade700
                                : Colors.orange.shade800),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item.label,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ]),
                    ))
                .toList(),
          ),
        ),
      ]),
    );
  }

  Widget _buildSquadPlayerRow({
    required PlayersTableData player,
    required bool isTeamA,
  }) {
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    final eligible = isTeamA ? _eligibleABowlers : _eligibleBBowlers;
    final isSelected = selected.contains(player.id);
    final isCaptain =
        (isTeamA ? _teamACaptainId : _teamBCaptainId) == player.id;
    final isKeeper =
        (isTeamA ? _teamAWicketkeeperId : _teamBWicketkeeperId) == player.id;
    final canBowl = eligible.contains(player.id) && isSelected;

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${player.name}, ${_playerRoleLabel(player.role)}, ${isSelected ? 'selected' : 'not selected'}${isCaptain ? ', captain' : ''}${isKeeper ? ', wicketkeeper' : ''}${canBowl ? ', eligible bowler' : ''}',
      child: InkWell(
        onTap: () => _toggleSquadPlayer(player, isTeamA: isTeamA),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 62),
          color: isSelected ? const Color(0xFFF0F9F5) : Colors.white,
          padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
          child: Row(children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSquadPlayer(player, isTeamA: isTeamA),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? null : Colors.black54,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500)),
                  Text(
                    [
                      _playerRoleLabel(player.role),
                      playerStyleSummary(
                        _parseBattingStyle(player.battingStyle),
                        _parseBowlingStyle(player.bowlingStyle),
                      ),
                      if (player.jerseyNumber?.isNotEmpty == true)
                        '#${player.jerseyNumber}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (isSelected && (isCaptain || isKeeper || canBowl))
                    Text(
                      [
                        if (isCaptain) 'C',
                        if (isKeeper) 'WK',
                        if (canBowl) 'BOWL',
                      ].join(' · '),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Actions for ${player.name}',
              enabled: isSelected,
              onSelected: (action) =>
                  _handleSquadPlayerAction(action, player, isTeamA: isTeamA),
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'captain',
                    child: Text(
                        isCaptain ? 'Captain selected' : 'Set as Captain')),
                PopupMenuItem(
                    value: 'keeper',
                    child: Text(isKeeper
                        ? 'Remove Wicketkeeper'
                        : 'Set as Wicketkeeper')),
                PopupMenuItem(
                    value: 'bowler',
                    child: Text(canBowl
                        ? 'Remove Bowling Eligibility'
                        : 'Mark Eligible Bowler')),
                const PopupMenuDivider(),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _handleSquadPlayerAction(String action, PlayersTableData player,
      {required bool isTeamA}) async {
    final eligible = isTeamA ? _eligibleABowlers : _eligibleBBowlers;
    switch (action) {
      case 'captain':
        setState(() {
          if (isTeamA) {
            _teamACaptainId = player.id;
          } else {
            _teamBCaptainId = player.id;
          }
        });
        break;
      case 'keeper':
        setState(() {
          if (isTeamA) {
            _teamAWicketkeeperId =
                _teamAWicketkeeperId == player.id ? null : player.id;
          } else {
            _teamBWicketkeeperId =
                _teamBWicketkeeperId == player.id ? null : player.id;
          }
        });
        break;
      case 'bowler':
        if (!eligible.contains(player.id) &&
            player.bowlingStyle == BowlingStyle.none.name) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Override bowling profile?'),
              content: Text(
                '${player.name} is marked Does Not Bowl. Make them eligible for this match only?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Make Eligible'),
                ),
              ],
            ),
          );
          if (confirmed != true || !mounted) return;
        }
        setState(() {
          if (!eligible.remove(player.id)) {
            eligible.add(player.id);
            _perBowlerMaxOvers.putIfAbsent(
                player.id, () => _customMaxOversPerBowler);
          }
        });
        break;
    }
  }

  BattingStyle _parseBattingStyle(String value) =>
      BattingStyle.values.firstWhere(
        (style) => style.name == value,
        orElse: () => BattingStyle.notSet,
      );

  BowlingStyle _parseBowlingStyle(String value) =>
      BowlingStyle.values.firstWhere(
        (style) => style.name == value,
        orElse: () => BowlingStyle.notSet,
      );

  String _playerRoleLabel(String role) => switch (role) {
        'batter' => 'Batter',
        'bowler' => 'Bowler',
        'wicketKeeper' => 'Wicketkeeper',
        'wicketKeeperBatter' => 'WK-Batter',
        _ => 'All-rounder',
      };

  _SquadReadiness _squadReadiness({required bool isTeamA}) {
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    final eligible = (isTeamA ? _eligibleABowlers : _eligibleBBowlers)
        .intersection(selected);
    final captain = isTeamA ? _teamACaptainId : _teamBCaptainId;
    final keeper = isTeamA ? _teamAWicketkeeperId : _teamBWicketkeeperId;
    final limits = Map.fromEntries(_perBowlerMaxOvers.entries
        .where((entry) => eligible.contains(entry.key)));
    final bowling = BowlingRules.validate(
      totalOvers: _totalOvers,
      eligibleBowlerCount: eligible.length,
      mode: _bowlerLimitMode,
      equalMaxOvers: _effectiveEqualBowlerLimit,
      allowConsecutiveOvers: _allowConsecutiveOvers,
      perBowlerMaxOvers: limits,
    );
    final items = [
      _SquadReadinessItem(
        selected.length >= _minimumPlayersRequired,
        selected.length >= _minimumPlayersRequired
            ? 'Minimum players selected'
            : 'Select ${_minimumPlayersRequired - selected.length} more player${_minimumPlayersRequired - selected.length == 1 ? '' : 's'}',
      ),
      _SquadReadinessItem(
        captain != null && selected.contains(captain),
        captain != null && selected.contains(captain)
            ? 'Captain selected'
            : 'Select one captain',
      ),
      _SquadReadinessItem(
        true,
        keeper != null && selected.contains(keeper)
            ? 'Wicketkeeper selected'
            : 'Wicketkeeper optional · not assigned',
      ),
      _SquadReadinessItem(
        eligible.isNotEmpty,
        eligible.isNotEmpty
            ? '${eligible.length} eligible bowler${eligible.length == 1 ? '' : 's'}'
            : 'Select an eligible bowler',
      ),
      _SquadReadinessItem(
        bowling.isValid,
        bowling.isValid
            ? 'Bowling capacity supports $_totalOvers overs'
            : bowling.message!,
      ),
    ];
    return _SquadReadiness(items);
  }

  String? get _firstSquadReadinessIssue {
    for (final isTeamA in const [true, false]) {
      final teamName =
          isTeamA ? (_teamA?.name ?? 'Team A') : (_teamB?.name ?? 'Team B');
      final invalid = _squadReadiness(isTeamA: isTeamA)
          .items
          .where((item) => !item.isValid);
      if (invalid.isNotEmpty) return '$teamName: ${invalid.first.label}';
    }
    return null;
  }

  int get _effectiveEqualBowlerLimit {
    return _customMaxOversPerBowler;
  }

  bool get _hasValidCaptains =>
      CaptainRules.isValidMatchCaptain(
        captainId: _teamACaptainId,
        playingSquadIds: _selectedASquad,
      ) &&
      CaptainRules.isValidMatchCaptain(
        captainId: _teamBCaptainId,
        playingSquadIds: _selectedBSquad,
      );

  Step _buildTossStep() {
    final teamAId = _teamA?.id ?? 'team_a';
    final teamAName = _teamA?.name ?? 'Team A';
    final teamBId = _teamB?.id ?? 'team_b';
    final teamBName = _teamB?.name ?? 'Team B';

    return Step(
      title: const Text('Toss'),
      isActive: _currentStep >= 3,
      content: DigitalCoinTossWidget(
        teamAId: teamAId,
        teamAName: teamAName,
        teamBId: teamBId,
        teamBName: teamBName,
        initialCallingTeamId: _tossCallingTeamId,
        initialTossCall: _tossCall,
        initialCoinResult: _coinResult,
        initialTossWinnerId: _tossWinnerId,
        initialTossDecision: _tossDecision,
        onTossCompleted: (result) {
          setState(() {
            _tossCallingTeamId = result.tossCallingTeamId;
            _tossCall = result.tossCall;
            _coinResult = result.coinResult;
            _tossWinnerId = result.tossWinnerTeamId;
            _tossDecision = result.tossDecision;
            _sanitizeOpenerSelections();
          });
          _persistDraft();
        },
        onTossReset: () {
          setState(() {
            _tossCallingTeamId = null;
            _tossCall = null;
            _coinResult = null;
            _tossWinnerId = null;
          });
          _persistDraft();
        },
        onConfirmToss: () {
          if (_currentStep == 3 && _tossIsReady) {
            setState(() {
              _currentStep = 4;
            });
            _persistDraft();
          }
        },
      ),
    );
  }

  Step _buildOpenersStep() {
    final battingTeamId = _tossDecision == 'BAT'
        ? _tossWinnerId
        : (_tossWinnerId == _teamA?.id ? _teamB?.id : _teamA?.id);

    final isTeamABatting = battingTeamId == _teamA?.id;
    final battingSquad = sortPlayerItemsByName(
      isTeamABatting
          ? _teamAPlayers.where((p) => _selectedASquad.contains(p.id))
          : _teamBPlayers.where((p) => _selectedBSquad.contains(p.id)),
      nameOf: (player) => player.name,
      idOf: (player) => player.id,
      jerseyNumberOf: (player) => player.jerseyNumber,
    );

    final bowlingSquad = sortPlayerItemsByName(
      isTeamABatting
          ? _teamBPlayers.where((p) =>
              _selectedBSquad.contains(p.id) &&
              _eligibleBBowlers.contains(p.id))
          : _teamAPlayers.where((p) =>
              _selectedASquad.contains(p.id) &&
              _eligibleABowlers.contains(p.id)),
      nameOf: (player) => player.name,
      idOf: (player) => player.id,
      jerseyNumberOf: (player) => player.jerseyNumber,
    );

    final validBattingIds = battingSquad.map((p) => p.id).toSet();
    final validBowlingIds = bowlingSquad.map((p) => p.id).toSet();

    final effectiveStrikerId =
        (_strikerId != null && validBattingIds.contains(_strikerId))
            ? _strikerId
            : null;
    final effectiveNonStrikerId =
        (_nonStrikerId != null && validBattingIds.contains(_nonStrikerId))
            ? _nonStrikerId
            : null;
    final effectiveBowlerId =
        (_bowlerId != null && validBowlingIds.contains(_bowlerId))
            ? _bowlerId
            : null;

    return Step(
      title: const Text('Openers'),
      isActive: _currentStep >= 4,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Opening Striker:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: effectiveStrikerId,
            hint: const Text('Select Striker'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: battingSquad
                .where((p) => p.id != effectiveNonStrikerId)
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _strikerId = val),
          ),
          const SizedBox(height: 16),
          const Text('Opening Non-Striker:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: effectiveNonStrikerId,
            hint: const Text('Select Non-Striker'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: battingSquad
                .where((p) => p.id != effectiveStrikerId)
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _nonStrikerId = val),
          ),
          const SizedBox(height: 16),
          const Text('Opening Bowler:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: effectiveBowlerId,
            hint: const Text('Select Opening Bowler'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: bowlingSquad
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _bowlerId = val),
          ),
        ],
      ),
    );
  }

  void _sanitizeOpenerSelections() {
    final battingTeamId = _tossDecision == 'BAT'
        ? _tossWinnerId
        : (_tossWinnerId == _teamA?.id ? _teamB?.id : _teamA?.id);

    final isTeamABatting = battingTeamId == _teamA?.id;
    final battingSquad = isTeamABatting
        ? _teamAPlayers.where((p) => _selectedASquad.contains(p.id))
        : _teamBPlayers.where((p) => _selectedBSquad.contains(p.id));

    final bowlingSquad = isTeamABatting
        ? _teamBPlayers.where((p) =>
            _selectedBSquad.contains(p.id) &&
            _eligibleBBowlers.contains(p.id))
        : _teamAPlayers.where((p) =>
            _selectedASquad.contains(p.id) &&
            _eligibleABowlers.contains(p.id));

    final battingIds = battingSquad.map((p) => p.id).toSet();
    final bowlingIds = bowlingSquad.map((p) => p.id).toSet();

    if (_strikerId != null && !battingIds.contains(_strikerId)) {
      _strikerId = null;
    }
    if (_nonStrikerId != null && !battingIds.contains(_nonStrikerId)) {
      _nonStrikerId = null;
    }
    if (_bowlerId != null && !bowlingIds.contains(_bowlerId)) {
      _bowlerId = null;
    }
  }

  Step _buildConfirmationStep() {
    final teamAPlayers = _selectedPlayers(isTeamA: true);
    final teamBPlayers = _selectedPlayers(isTeamA: false);
    final teamAReadiness = _squadReadiness(isTeamA: true);
    final teamBReadiness = _squadReadiness(isTeamA: false);
    final localizations = MaterialLocalizations.of(context);
    final venue = _venueController.text.trim().isEmpty
        ? 'Local Field'
        : _venueController.text.trim();
    final tossWinner = _tossWinnerId == _teamA?.id ? _teamA : _teamB;
    final tossChoice = _tossDecision == 'BAT' ? 'bat first' : 'bowl first';

    return Step(
      title: const Text('Review'),
      isActive: _currentStep >= 5,
      content: TweenAnimationBuilder<double>(
        key: const ValueKey('premium-match-review'),
        duration: const Duration(milliseconds: 240),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Review Match',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Confirm the teams, roles, rules and opening players.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            _MatchReviewBanner(teamA: _teamA, teamB: _teamB),
            const SizedBox(height: 14),
            _ReviewSectionCard(
              key: const ValueKey('review-match-summary'),
              title: 'Match Summary',
              icon: Icons.event_note_rounded,
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final itemWidth = width >= 520 ? (width - 12) / 2 : width;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.location_on_outlined,
                        label: 'Venue',
                        value: venue),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.calendar_today_outlined,
                        label: 'Match Date',
                        value: localizations.formatMediumDate(_matchDate)),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value: localizations.formatTimeOfDay(
                            TimeOfDay.fromDateTime(_matchDate))),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.emoji_events_outlined,
                        label: 'Match Type',
                        value: 'Custom Match'),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.timer_outlined,
                        label: 'Total Overs',
                        value: '$_totalOvers Overs'),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.sports_cricket_outlined,
                        label: 'Balls per Over',
                        value: '$_ballsPerOver'),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.rotate_right_rounded,
                        label: 'Max Overs per Bowler',
                        value: '$_customMaxOversPerBowler'),
                    _ReviewFact(
                        width: itemWidth,
                        icon: Icons.casino_outlined,
                        label: 'Toss',
                        value:
                            '${tossWinner?.name ?? 'Not selected'} · $tossChoice'),
                  ],
                );
              }),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final stack = constraints.maxWidth < 360;
              final teamACard = _ReviewTeamCard(
                team: _teamA,
                playerCount: teamAPlayers.length,
                captain: _playerName(_teamAPlayers, _teamACaptainId),
                wicketkeeper: _playerName(_teamAPlayers, _teamAWicketkeeperId),
              );
              final teamBCard = _ReviewTeamCard(
                team: _teamB,
                playerCount: teamBPlayers.length,
                captain: _playerName(_teamBPlayers, _teamBCaptainId),
                wicketkeeper: _playerName(_teamBPlayers, _teamBWicketkeeperId),
              );
              if (stack) {
                return Column(children: [
                  teamACard,
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('VS',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  teamBCard,
                ]);
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: teamACard),
                    const SizedBox(
                      width: 34,
                      child: Center(
                        child: Text('VS',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    Expanded(child: teamBCard),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
            _ReviewSectionCard(
              key: const ValueKey('review-squads'),
              title: 'Squad Summary',
              icon: Icons.groups_2_outlined,
              padding: EdgeInsets.zero,
              child: Column(children: [
                _ReviewSquadTile(
                  teamName: _teamA?.name ?? 'Team A',
                  players: teamAPlayers,
                  captainId: _teamACaptainId,
                  wicketkeeperId: _teamAWicketkeeperId,
                ),
                const Divider(),
                _ReviewSquadTile(
                  teamName: _teamB?.name ?? 'Team B',
                  players: teamBPlayers,
                  captainId: _teamBCaptainId,
                  wicketkeeperId: _teamBWicketkeeperId,
                ),
              ]),
            ),
            const SizedBox(height: 14),
            _ReviewSectionCard(
              key: const ValueKey('review-match-rules'),
              title: 'Match Rules',
              icon: Icons.rule_rounded,
              child: Column(children: [
                _ReviewRule(text: 'Custom limited-overs match'),
                _ReviewRule(
                    text: '$_totalOvers overs · $_ballsPerOver balls per over'),
                _ReviewRule(
                    text:
                        'Maximum $_customMaxOversPerBowler over${_customMaxOversPerBowler == 1 ? '' : 's'} per bowler'),
                _ReviewRule(
                    text: _allowConsecutiveOvers
                        ? 'Consecutive overs allowed'
                        : 'Consecutive overs not allowed'),
                _ReviewRule(
                    text: _allowTacticalMidOverReplacement
                        ? 'Tactical mid-over replacement allowed'
                        : 'Mid-over replacement for incapacity only'),
              ]),
            ),
            const SizedBox(height: 14),
            _ReviewSectionCard(
              key: const ValueKey('review-ready-status'),
              title: 'Ready Status',
              icon: Icons.verified_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReviewValidationChip(
                      valid: _teamValidation.isValid,
                      label: 'Both teams selected'),
                  _ReviewValidationChip(
                      valid: _hasValidCaptains, label: 'Captains assigned'),
                  _ReviewValidationChip(
                      valid: _teamAWicketkeeperId == null ||
                          _selectedASquad.contains(_teamAWicketkeeperId),
                      label: _teamAWicketkeeperId == null
                          ? 'Team A keeper optional'
                          : 'Team A keeper assigned'),
                  _ReviewValidationChip(
                      valid: _teamBWicketkeeperId == null ||
                          _selectedBSquad.contains(_teamBWicketkeeperId),
                      label: _teamBWicketkeeperId == null
                          ? 'Team B keeper optional'
                          : 'Team B keeper assigned'),
                  _ReviewValidationChip(
                      valid: teamAReadiness.isValid && teamBReadiness.isValid,
                      label: 'Squads ready'),
                  _ReviewValidationChip(
                      valid: teamAReadiness.items.last.isValid &&
                          teamBReadiness.items.last.isValid,
                      label: 'Bowling rules valid'),
                  _ReviewValidationChip(
                      valid: _strikerId != null &&
                          _nonStrikerId != null &&
                          _bowlerId != null &&
                          _strikerId != _nonStrikerId,
                      label: 'Opening players selected'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _reviewIsReady
                    ? const Color(0xFFE4F5EE)
                    : const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(
                  _reviewIsReady
                      ? Icons.sports_cricket_rounded
                      : Icons.warning_amber_rounded,
                  color: _reviewIsReady
                      ? AppColors.primary
                      : Colors.orange.shade800,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _reviewIsReady
                        ? 'All set! Time for the match.'
                        : _reviewReadinessIssue,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  List<PlayersTableData> _selectedPlayers({required bool isTeamA}) {
    final selected = isTeamA ? _selectedASquad : _selectedBSquad;
    return sortPlayerItemsByName(
      (isTeamA ? _teamAPlayers : _teamBPlayers)
          .where((player) => selected.contains(player.id)),
      nameOf: (player) => player.name,
      idOf: (player) => player.id,
      jerseyNumberOf: (player) => player.jerseyNumber,
    );
  }

  String _playerName(List<PlayersTableData> players, String? id) {
    final match = players.where((player) => player.id == id);
    return match.isEmpty ? 'Not assigned' : match.first.name;
  }

  bool get _reviewIsReady =>
      _teamA != null &&
      _teamB != null &&
      _teamValidation.isValid &&
      _squadReadiness(isTeamA: true).isValid &&
      _squadReadiness(isTeamA: false).isValid &&
      _hasValidCaptains &&
      _strikerId != null &&
      _nonStrikerId != null &&
      _strikerId != _nonStrikerId &&
      _bowlerId != null;

  String get _reviewReadinessIssue {
    if (!_teamValidation.isValid) return _teamValidation.issues.first.message;
    final squadIssue = _firstSquadReadinessIssue;
    if (squadIssue != null) return squadIssue;
    if (!_hasValidCaptains) return 'Assign one captain to each playing squad.';
    if (_strikerId == null || _nonStrikerId == null || _bowlerId == null) {
      return 'Select the opening batters and opening bowler.';
    }
    if (_strikerId == _nonStrikerId) {
      return 'Opening striker and non-striker must be different.';
    }
    return 'Review the match setup before continuing.';
  }
}

class _SquadReadinessItem {
  final bool isValid;
  final String label;

  const _SquadReadinessItem(this.isValid, this.label);
}

class _MatchReviewBanner extends StatelessWidget {
  final TeamsTableData? teamA;
  final TeamsTableData? teamB;

  const _MatchReviewBanner({required this.teamA, required this.teamB});

  String _initials(String? name) {
    final words = (name ?? '').trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'T';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('review-match-banner'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2607513B),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: _ReviewBannerTeam(
              initials: _initials(teamA?.name),
              name: teamA?.name ?? 'Team A',
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _ReviewBannerTeam(
              initials: _initials(teamB?.name),
              name: teamB?.name ?? 'Team B',
            ),
          ),
        ]),
      );
}

class _ReviewBannerTeam extends StatelessWidget {
  final String initials;
  final String name;

  const _ReviewBannerTeam({required this.initials, required this.name});

  @override
  Widget build(BuildContext context) => Column(children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ]);
}

class _ReviewSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ReviewSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 16),
  });

  @override
  Widget build(BuildContext context) => Card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ]),
          ),
          Padding(padding: padding, child: child),
        ]),
      );
}

class _ReviewFact extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;

  const _ReviewFact({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
      );
}

class _ReviewTeamCard extends StatelessWidget {
  final TeamsTableData? team;
  final int playerCount;
  final String captain;
  final String wicketkeeper;

  const _ReviewTeamCard({
    required this.team,
    required this.playerCount,
    required this.captain,
    required this.wicketkeeper,
  });

  @override
  Widget build(BuildContext context) => Card(
        key: ValueKey('review-team-${team?.id ?? 'unknown'}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE4F5EE),
              foregroundColor: AppColors.primary,
              child: Text(
                (team?.shortName.isNotEmpty ?? false)
                    ? team!.shortName.substring(0, 1).toUpperCase()
                    : 'T',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
            Text(team?.name ?? 'Team',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _TeamDetail(
                icon: Icons.check_circle_outline, text: '$playerCount players'),
            _TeamDetail(
                icon: Icons.workspace_premium_outlined,
                text: 'Captain: $captain'),
            _TeamDetail(
                icon: Icons.sports_handball_outlined,
                text: 'Keeper: $wicketkeeper'),
          ]),
        ),
      );
}

class _TeamDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TeamDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
          ),
        ]),
      );
}

class _ReviewSquadTile extends StatelessWidget {
  final String teamName;
  final List<PlayersTableData> players;
  final String? captainId;
  final String? wicketkeeperId;

  const _ReviewSquadTile({
    required this.teamName,
    required this.players,
    required this.captainId,
    required this.wicketkeeperId,
  });

  String _displayName(PlayersTableData player) {
    final captain = player.id == captainId;
    final keeper = player.id == wicketkeeperId;
    if (captain && keeper) return '${player.name} (C & WK)';
    if (captain) return '${player.name} (C)';
    if (keeper) return '${player.name} (WK)';
    return player.name;
  }

  @override
  Widget build(BuildContext context) => ExpansionTile(
        key: ValueKey('review-squad-$teamName'),
        initiallyExpanded: false,
        title:
            Text(teamName, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${players.length} selected players'),
        children: players
            .map((player) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle,
                      size: 18, color: AppColors.primary),
                  title: Text(_displayName(player)),
                ))
            .toList(),
      );
}

class _ReviewRule extends StatelessWidget {
  final String text;

  const _ReviewRule({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          const Icon(Icons.check_rounded, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ]),
      );
}

class _ReviewValidationChip extends StatelessWidget {
  final bool valid;
  final String label;

  const _ReviewValidationChip({required this.valid, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: valid ? const Color(0xFFE4F5EE) : const Color(0xFFFFE9E5),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: valid ? const Color(0xFFB9E3D1) : const Color(0xFFF2B8AE),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(valid ? Icons.check_circle : Icons.error_outline,
              size: 15, color: valid ? AppColors.primary : AppColors.wicketRed),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valid ? AppColors.primaryDark : AppColors.wicketRed,
              )),
        ]),
      );
}

class _SquadReadiness {
  final List<_SquadReadinessItem> items;

  const _SquadReadiness(this.items);

  bool get isValid => items.every((item) => item.isValid);
}

class _SquadStatusBadge extends StatelessWidget {
  final bool isReady;

  const _SquadStatusBadge({required this.isReady});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isReady ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isReady ? Colors.green.shade300 : Colors.orange.shade300,
          ),
        ),
        child: Text(
          isReady ? 'READY' : 'ACTION REQUIRED',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isReady ? Colors.green.shade800 : Colors.orange.shade900,
          ),
        ),
      );
}
