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
        final scheduledAt = data['scheduledAt'] as int?;
        if (scheduledAt != null) {
          _matchDate = DateTime.fromMillisecondsSinceEpoch(scheduledAt);
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
      _teamA = teams.firstWhere((t) => t.id == widget.preselectTeamId);
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
            'currentStep': _currentStep,
            'teamACaptainId': _teamACaptainId,
            'teamBCaptainId': _teamBCaptainId,
            'teamAWicketkeeperId': _teamAWicketkeeperId,
            'teamBWicketkeeperId': _teamBWicketkeeperId,
            'teamASquad': _selectedASquad.toList(),
            'teamBSquad': _selectedBSquad.toList(),
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

    final matchId =
        widget.draftId ?? 'match_${DateTime.now().millisecondsSinceEpoch}';
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
      scheduledAt: _matchDate.millisecondsSinceEpoch,
      startedAt: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
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
        scheduledAt: _matchDate.millisecondsSinceEpoch,
        startedAt: engine.state.startedAt,
        matchTimeZone: engine.state.matchTimeZone,
        tossWinnerTeamId: _tossWinnerId,
        tossDecision: _tossDecision,
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

  Widget _buildStickySetupActions() {
    final blocked = _currentStep == 0 &&
        (_loadingTeamAPlayers ||
            _loadingTeamBPlayers ||
            !_teamValidation.isValid);
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
      _tossWinnerId ??= _teamA!.id;
    } else if (_currentStep == 4) {
      if (_strikerId == null || _nonStrikerId == null || _bowlerId == null) {
        _showSetupIssue('Select striker, non-striker, and opening bowler.');
        return;
      }
      if (_strikerId == _nonStrikerId) {
        _showSetupIssue('Striker and non-striker must be different.');
        return;
      }
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
          final teams = snapshot.data ?? [];
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
                  const Text('Select Team A (Batting/Bowling)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Team'),
                    onPressed: () => context.push('/teams/create'),
                  ),
                ],
              ),
              DropdownButtonFormField<TeamsTableData>(
                value: _teamA,
                hint: const Text('Choose Team A'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: teams
                    .where((t) => t.id != _teamB?.id)
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (val) => _selectTeam(val, isTeamA: true),
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
                  const Text('Select Team B (Opponent)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Team'),
                    onPressed: () => context.push('/teams/create'),
                  ),
                ],
              ),
              DropdownButtonFormField<TeamsTableData>(
                value: _teamB,
                hint: const Text('Choose Team B'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: teams
                    .where((t) => t.id != _teamA?.id)
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (val) => _selectTeam(val, isTeamA: false),
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
                setState(() => _matchDate = DateTime(selected.year,
                    selected.month, selected.day, time.hour, time.minute));
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
    final players = isTeamA ? _teamAPlayers : _teamBPlayers;
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
    final teamAName = _teamA?.name ?? 'Team A';
    final teamBName = _teamB?.name ?? 'Team B';

    return Step(
      title: const Text('Toss'),
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Who won the toss?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: Text(teamAName),
            value: _teamA?.id ?? '',
            groupValue: _tossWinnerId,
            onChanged: (val) => setState(() => _tossWinnerId = val),
          ),
          RadioListTile<String>(
            title: Text(teamBName),
            value: _teamB?.id ?? '',
            groupValue: _tossWinnerId,
            onChanged: (val) => setState(() => _tossWinnerId = val),
          ),
          const SizedBox(height: 16),
          const Text('Toss Winner elected to:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('BAT FIRST'),
                  selected: _tossDecision == 'BAT',
                  onSelected: (val) {
                    if (val) setState(() => _tossDecision = 'BAT');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('BOWL FIRST'),
                  selected: _tossDecision == 'BOWL',
                  onSelected: (val) {
                    if (val) setState(() => _tossDecision = 'BOWL');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Step _buildOpenersStep() {
    final battingTeamId = _tossDecision == 'BAT'
        ? _tossWinnerId
        : (_tossWinnerId == _teamA?.id ? _teamB?.id : _teamA?.id);

    final isTeamABatting = battingTeamId == _teamA?.id;
    final battingSquad = isTeamABatting
        ? _teamAPlayers.where((p) => _selectedASquad.contains(p.id)).toList()
        : _teamBPlayers.where((p) => _selectedBSquad.contains(p.id)).toList();

    final bowlingSquad = isTeamABatting
        ? _teamBPlayers
            .where((p) =>
                _selectedBSquad.contains(p.id) &&
                _eligibleBBowlers.contains(p.id))
            .toList()
        : _teamAPlayers
            .where((p) =>
                _selectedASquad.contains(p.id) &&
                _eligibleABowlers.contains(p.id))
            .toList();

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
            value: _strikerId,
            hint: const Text('Select Striker'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: battingSquad
                .where((p) => p.id != _nonStrikerId)
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _strikerId = val),
          ),
          const SizedBox(height: 16),
          const Text('Opening Non-Striker:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _nonStrikerId,
            hint: const Text('Select Non-Striker'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: battingSquad
                .where((p) => p.id != _strikerId)
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _nonStrikerId = val),
          ),
          const SizedBox(height: 16),
          const Text('Opening Bowler:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _bowlerId,
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

  Step _buildConfirmationStep() {
    return Step(
      title: const Text('Confirm'),
      isActive: _currentStep >= 5,
      content: Card(
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_teamA?.name} vs ${_teamB?.name}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Format: Custom $_totalOvers Overs (6 balls/over)',
                  style: const TextStyle(color: Colors.white70)),
              Text(
                  'Venue: ${_venueController.text.isEmpty ? "Local Field" : _venueController.text}',
                  style: const TextStyle(color: Colors.white70)),
              const Divider(color: Colors.white30, height: 20),
              const Text('Ready to begin live scoring session!',
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquadReadinessItem {
  final bool isValid;
  final String label;

  const _SquadReadinessItem(this.isValid, this.label);
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
