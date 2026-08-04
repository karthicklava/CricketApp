import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/local/database.dart';
import '../../core/theme.dart';
import '../common/widgets/sports_ui.dart';

class TeamsListScreen extends ConsumerStatefulWidget {
  const TeamsListScreen({super.key});

  @override
  ConsumerState<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends ConsumerState<TeamsListScreen> {
  final _searchController = TextEditingController();
  List<TeamsTableData> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final query = _searchController.text.trim();
    final teams = await ref.read(teamRepositoryProvider).searchTeams(query);
    if (mounted) {
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
      ),
      floatingActionButton: _isLoading || _teams.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'CREATE TEAM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => context.push('/teams/create'),
            ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: PremiumSearchBar(
              controller: _searchController,
              hintText: 'Search teams by name or short code',
              onChanged: (_) => _loadTeams(),
              onClear: () {
                _searchController.clear();
                _loadTeams();
              },
            ),
          ),

          // Team List / Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _teams.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.groups_rounded,
                        title: 'Build your first team',
                        message:
                            'Create a team, add the playing squad, and start scoring your first match.',
                        actionLabel: 'Create Team',
                        onAction: () => context.push('/teams/create'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _teams.length,
                        itemBuilder: (ctx, idx) {
                          final team = _teams[idx];
                          final teamColor = team.color != null
                              ? Color(int.parse(
                                  team.color!.replaceFirst('#', '0xFF')))
                              : AppColors.primary;

                          return FutureBuilder<List<PlayersTableData>>(
                            future: ref
                                .read(teamRepositoryProvider)
                                .getTeamPlayers(team.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: SizedBox(
                                    height: 76,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              }
                              final players = snapshot.data ?? [];
                              final captain = players.firstWhere(
                                (p) => p.isCaptain,
                                orElse: () => PlayersTableData(
                                  id: '',
                                  name: 'Not assigned',
                                  role: '',
                                  battingStyle: '',
                                  bowlingStyle: '',
                                  isCaptain: false,
                                  isWicketKeeper: false,
                                  createdAt: 0,
                                  syncStatus: '',
                                ),
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  onTap: () => context.push('/teams/details',
                                      extra: team),
                                  leading: CircleAvatar(
                                    backgroundColor: teamColor,
                                    child: Text(
                                      team.shortName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                  title: Text(team.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    players.isEmpty
                                        ? '0 Players • Setup incomplete'
                                        : '${players.length} Players • Captain: ${captain.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: players.isEmpty
                                          ? Colors.orange.shade900
                                          : null,
                                      fontWeight: players.isEmpty
                                          ? FontWeight.w600
                                          : null,
                                    ),
                                  ),
                                  trailing: players.isEmpty
                                      ? TextButton.icon(
                                          icon: const Icon(Icons.person_add),
                                          label: const Text('Add Players'),
                                          onPressed: () async {
                                            await context.push(
                                              '/teams/add-players/${team.id}',
                                            );
                                            _loadTeams();
                                          },
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () => context.push(
                                                  '/teams/create?id=${team.id}'),
                                            ),
                                            PopupMenuButton<String>(
                                              onSelected: (val) async {
                                                if (val == 'archive') {
                                                  await ref
                                                      .read(
                                                          teamRepositoryProvider)
                                                      .archiveTeam(team.id);
                                                  _loadTeams();
                                                } else if (val == 'delete') {
                                                  await ref
                                                      .read(
                                                          teamRepositoryProvider)
                                                      .deleteTeam(team.id);
                                                  _loadTeams();
                                                }
                                              },
                                              itemBuilder: (ctx) => [
                                                const PopupMenuItem(
                                                    value: 'archive',
                                                    child:
                                                        Text('Archive Team')),
                                                const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete Team',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red))),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
