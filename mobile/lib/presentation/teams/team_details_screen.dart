import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/local/database.dart';
import '../../core/theme.dart';
import '../../core/utils/player_sorting.dart';
import '../common/widgets/sports_ui.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

class TeamDetailsScreen extends ConsumerStatefulWidget {
  final TeamsTableData team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  ConsumerState<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends ConsumerState<TeamDetailsScreen> {
  List<PlayersTableData> _players = [];
  List<PlayersTableData> _removedPlayers = [];
  bool _isLoading = true;

  BattingStyle _battingStyle(String value) => BattingStyle.values.firstWhere(
        (style) => style.name == value,
        orElse: () => BattingStyle.notSet,
      );

  BowlingStyle _bowlingStyle(String value) => BowlingStyle.values.firstWhere(
        (style) => style.name == value,
        orElse: () => BowlingStyle.notSet,
      );

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final repo = ref.read(teamRepositoryProvider);
    final players = await repo.getTeamPlayers(widget.team.id);
    final removedPlayers = await repo.getRemovedTeamPlayers(widget.team.id);
    if (mounted) {
      setState(() {
        _players = sortPlayerItemsByName(
          players,
          nameOf: (player) => player.name,
          idOf: (player) => player.id,
          jerseyNumberOf: (player) => player.jerseyNumber,
        );
        _removedPlayers = sortPlayerItemsByName(
          removedPlayers,
          nameOf: (player) => player.name,
          idOf: (player) => player.id,
          jerseyNumberOf: (player) => player.jerseyNumber,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromTeam(PlayersTableData player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${player.name} from ${widget.team.name}?'),
        content: const Text(
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
        .removePlayerFromTeam(widget.team.id, player.id);
    await _loadPlayers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} was removed from ${widget.team.name}.'),
        ),
      );
    }
  }

  Future<void> _restore(PlayersTableData player) async {
    await ref
        .read(teamRepositoryProvider)
        .restorePlayerToTeam(widget.team.id, player.id);
    await _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = widget.team.color != null
        ? Color(int.parse(widget.team.color!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    final captain = _players.firstWhere((p) => p.isCaptain,
        orElse: () => PlayersTableData(
            id: '',
            name: 'Not assigned',
            role: '',
            battingStyle: '',
            bowlingStyle: '',
            isCaptain: false,
            isWicketKeeper: false,
            createdAt: 0,
            syncStatus: ''));
    final keeper = _players.firstWhere((p) => p.isWicketKeeper,
        orElse: () => PlayersTableData(
            id: '',
            name: 'Not assigned',
            role: '',
            battingStyle: '',
            bowlingStyle: '',
            isCaptain: false,
            isWicketKeeper: false,
            createdAt: 0,
            syncStatus: ''));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Team',
            onPressed: () => context.push('/teams/create?id=${widget.team.id}'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Header Card
                  AppCard(
                    color: teamColor,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.team.shortName,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: teamColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(widget.team.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        if (widget.team.city != null &&
                            widget.team.city!.isNotEmpty)
                          Text(widget.team.city!,
                              style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Captain',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(captain.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Wicketkeeper',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(keeper.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Players',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text('${_players.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('ADD PLAYERS'),
                          onPressed: () => context
                              .push('/teams/add-players/${widget.team.id}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.sports_cricket),
                          label: const Text('CREATE MATCH'),
                          onPressed: () => context.push(
                              '/matches/create?preselectTeamId=${widget.team.id}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Player Roster List
                  const Text('Player Roster',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _players.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                                child: Text(
                                    'No players added yet. Click "Add Players" to manage squad.')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _players.length,
                          itemBuilder: (ctx, idx) {
                            final p = _players[idx];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(p.jerseyNumber ?? '${idx + 1}',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                title: Text(
                                  '${p.name} ${p.isCaptain ? "(C)" : ""} ${p.isWicketKeeper ? "(WK)" : ""}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  playerStyleSummary(
                                    _battingStyle(p.battingStyle),
                                    _bowlingStyle(p.bowlingStyle),
                                  ),
                                ),
                                trailing: IconButton(
                                  tooltip: 'Remove ${p.name} from team',
                                  icon: const Icon(Icons.person_remove,
                                      color: Colors.red),
                                  onPressed: () => _removeFromTeam(p),
                                ),
                              ),
                            );
                          },
                        ),
                  if (_removedPlayers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Removed Players',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ..._removedPlayers.map((player) => ListTile(
                          leading: const Icon(Icons.person_off),
                          title: Text(player.name),
                          trailing: TextButton(
                            onPressed: () => _restore(player),
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
