import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/local/database.dart';
import '../../core/theme.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

class AddPlayersScreen extends ConsumerStatefulWidget {
  final String teamId;
  final bool returnToMatchSetup;

  const AddPlayersScreen({
    super.key,
    required this.teamId,
    this.returnToMatchSetup = false,
  });

  @override
  ConsumerState<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends ConsumerState<AddPlayersScreen> {
  TeamsTableData? _team;
  List<PlayersTableData> _players = [];
  List<PlayersTableData> _removedPlayers = [];
  bool _isLoading = true;

  // Form Controllers
  final _nameController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole =
      'allRounder'; // batter, bowler, allRounder, wicketKeeper, wicketKeeperBatter
  String _battingStyle = 'notSet';
  String _bowlingStyle = 'notSet';
  bool _isCaptain = false;
  bool _isWicketKeeper = false;

  String? _editingPlayerId;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    final repo = ref.read(teamRepositoryProvider);
    _team = await repo.getTeamById(widget.teamId);
    _players = await repo.getTeamPlayers(widget.teamId);
    _removedPlayers = await repo.getRemovedTeamPlayers(widget.teamId);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _jerseyController.clear();
    _phoneController.clear();
    _selectedRole = 'allRounder';
    _battingStyle = 'notSet';
    _bowlingStyle = 'notSet';
    _isCaptain = false;
    _isWicketKeeper = false;
    _editingPlayerId = null;
  }

  Future<void> _savePlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player name is required')),
      );
      return;
    }
    if (_battingStyle == 'notSet') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a batting hand.')),
      );
      return;
    }
    if (_bowlingStyle == 'notSet') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a bowling type.')),
      );
      return;
    }

    final jersey = _jerseyController.text.trim();
    if (jersey.isNotEmpty) {
      final duplicate = _players
          .any((p) => p.id != _editingPlayerId && p.jerseyNumber == jersey);
      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Jersey number $jersey is already assigned to another player in this team.')),
        );
        return;
      }
    }

    final repo = ref.read(teamRepositoryProvider);
    if (_editingPlayerId != null) {
      await repo.updatePlayer(
        teamId: widget.teamId,
        playerId: _editingPlayerId!,
        name: name,
        role: _selectedRole,
        battingStyle: _battingStyle,
        bowlingStyle: _bowlingStyle,
        jerseyNumber: _jerseyController.text.trim(),
        phone: _phoneController.text.trim(),
        isCaptain: _isCaptain,
        isWicketKeeper: _isWicketKeeper,
      );
    } else {
      await repo.addPlayerToTeam(
        teamId: widget.teamId,
        name: name,
        role: _selectedRole,
        battingStyle: _battingStyle,
        bowlingStyle: _bowlingStyle,
        jerseyNumber: _jerseyController.text.trim(),
        phone: _phoneController.text.trim(),
        isCaptain: _isCaptain,
        isWicketKeeper: _isWicketKeeper,
      );
    }

    _clearForm();
    await _loadTeamData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.returnToMatchSetup
                ? 'Player added to ${_team?.name ?? "team"}.'
                : 'Player saved to roster',
          ),
        ),
      );
      if (widget.returnToMatchSetup && _editingPlayerId == null) {
        final addAnother = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Player Added'),
            content: Text(
              'Add another player to ${_team?.name ?? "this team"}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add Another Player'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Done'),
              ),
            ],
          ),
        );
        if (addAnother == false && mounted) {
          context.pop(true);
        }
      }
    }
  }

  void _editPlayer(PlayersTableData player) {
    setState(() {
      _editingPlayerId = player.id;
      _nameController.text = player.name;
      _jerseyController.text = player.jerseyNumber ?? '';
      _phoneController.text = player.phone ?? '';
      _selectedRole = player.role;
      _battingStyle =
          BattingStyle.values.any((e) => e.name == player.battingStyle)
              ? player.battingStyle
              : 'notSet';
      _bowlingStyle = player.bowlingStyle != BowlingStyle.none.name &&
              BowlingStyle.values.any((e) => e.name == player.bowlingStyle)
          ? player.bowlingStyle
          : 'notSet';
      _isCaptain = player.isCaptain;
      _isWicketKeeper = player.isWicketKeeper;
    });
  }

  Future<void> _removePlayer(PlayersTableData player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${player.name} from ${_team?.name ?? 'team'}?'),
        content: Text(
          'The player will no longer appear in future match squads. Existing completed match scorecards will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove from Team'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(teamRepositoryProvider)
        .removePlayerFromTeam(widget.teamId, player.id);
    await _loadTeamData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '${player.name} was removed from ${_team?.name ?? 'the team'}.',
        ),
      ));
    }
  }

  Future<void> _restorePlayer(PlayersTableData player) async {
    await ref
        .read(teamRepositoryProvider)
        .restorePlayerToTeam(widget.teamId, player.id);
    await _loadTeamData();
  }

  void _submitRoster() {
    if (widget.returnToMatchSetup) {
      if (_players.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_team?.name ?? "This team"} needs at least one player.'),
          ),
        );
        return;
      }
      context.pop(true);
      return;
    }
    final hasCaptain = _players.any((p) => p.isCaptain);
    final hasWicketKeeper = _players.any((p) => p.isWicketKeeper);

    if (!hasCaptain || !hasWicketKeeper) {
      String missing = '';
      if (!hasCaptain && !hasWicketKeeper) {
        missing = 'at least one Captain and one Wicket-Keeper';
      } else if (!hasCaptain) {
        missing = 'at least one Captain';
      } else {
        missing = 'at least one Wicket-Keeper';
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Roster Validation Error'),
            ],
          ),
          content:
              Text('Please assign $missing to the team roster before saving.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_team != null) {
      context.pushReplacement('/teams/details', extra: _team);
    } else {
      context.pop();
    }
  }

  String _formatRole(String role) {
    switch (role) {
      case 'batter':
        return 'Batter';
      case 'bowler':
        return 'Bowler';
      case 'allRounder':
        return 'All-Rounder';
      case 'wicketKeeper':
        return 'Wicketkeeper';
      case 'wicketKeeperBatter':
        return 'Wicketkeeper-Batter';
      default:
        return role;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final hasCaptain = _players.any((p) => p.isCaptain);
    final hasWicketKeeper = _players.any((p) => p.isWicketKeeper);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_team?.name ?? "Team"} Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Roster',
            onPressed: _submitRoster,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Roster Overview Card & Validation Summary
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_team?.name ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${_players.length} Players in Squad',
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.save),
                          label: const Text('SAVE ROSTER',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _submitRoster,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 24),

                    // Role Validation Indicators
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: hasCaptain
                                  ? Colors.green.shade800
                                  : Colors.red.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    hasCaptain
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: Colors.white,
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  hasCaptain
                                      ? 'Captain Assigned'
                                      : 'Captain Required',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: hasWicketKeeper
                                  ? Colors.green.shade800
                                  : Colors.red.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    hasWicketKeeper
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: Colors.white,
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  hasWicketKeeper
                                      ? 'WicketKeeper Assigned'
                                      : 'WK Required',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Player Form Card (Add/Edit)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _editingPlayerId != null
                              ? 'Edit Player'
                              : 'Add New Player',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        if (_editingPlayerId != null)
                          TextButton(
                            onPressed: () => setState(() => _clearForm()),
                            child: const Text('Cancel Edit'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Player Name *',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _jerseyController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: const InputDecoration(
                                labelText: 'Jersey #',
                                helperText: 'Numbers only; up to 3 digits',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                labelText: 'Phone (Optional)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                          labelText: 'Player Primary Role',
                          border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: 'batter', child: Text('Batter')),
                        DropdownMenuItem(
                            value: 'bowler', child: Text('Bowler')),
                        DropdownMenuItem(
                            value: 'allRounder', child: Text('All-Rounder')),
                        DropdownMenuItem(
                            value: 'wicketKeeper', child: Text('Wicketkeeper')),
                        DropdownMenuItem(
                            value: 'wicketKeeperBatter',
                            child: Text('Wicketkeeper-Batter')),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                    const SizedBox(height: 12),

                    const Text('Batting Hand',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'rightHand', label: Text('Right Hand')),
                          ButtonSegment(
                              value: 'leftHand', label: Text('Left Hand')),
                        ],
                        selected: _battingStyle == 'notSet'
                            ? <String>{}
                            : {_battingStyle},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (value) =>
                            setState(() => _battingStyle = value.first),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Bowling Type',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'rightArmFast', label: Text('Fast')),
                          ButtonSegment(
                              value: 'rightArmSpin', label: Text('Spinner')),
                        ],
                        selected: _bowlingStyle == 'notSet'
                            ? <String>{}
                            : {_bowlingStyle},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (value) =>
                            setState(() => _bowlingStyle = value.first),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Leadership controls
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Default Captain [C]',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              value: true,
                              groupValue: _isCaptain ? true : null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (_) =>
                                  setState(() => _isCaptain = true),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Wicket-Keeper [WK]',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              value: _isWicketKeeper,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(
                                  () => _isWicketKeeper = val ?? false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: AppCtaStyle.height,
                      child: ElevatedButton.icon(
                        icon: Icon(_editingPlayerId != null
                            ? Icons.save
                            : Icons.person_add),
                        label: Text(
                            _editingPlayerId != null
                                ? 'UPDATE PLAYER'
                                : 'ADD PLAYER TO SQUAD',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                        onPressed: _savePlayer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Roster Player List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Squad Roster',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${_players.length} Players',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            if (_players.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No players added yet. Add players above.',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  final isEditing = _editingPlayerId == player.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isEditing
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          player.jerseyNumber != null &&
                                  player.jerseyNumber!.isNotEmpty
                              ? '#${player.jerseyNumber}'
                              : player.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (player.isCaptain)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.amber.shade800,
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('C',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          if (player.isWicketKeeper)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('WK',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${_formatRole(player.role)} · ${playerStyleSummary(_parseBattingStyle(player.battingStyle), _parseBowlingStyle(player.bowlingStyle))}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () => _editPlayer(player),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            tooltip: 'Remove ${player.name} from team',
                            onPressed: () => _removePlayer(player),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (_removedPlayers.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Removed Players',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ..._removedPlayers.map((player) => ListTile(
                    leading: const Icon(Icons.person_off),
                    title: Text(player.name),
                    subtitle: const Text('Removed from team'),
                    trailing: TextButton(
                      onPressed: () => _restorePlayer(player),
                      child: const Text('Restore to Team'),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
