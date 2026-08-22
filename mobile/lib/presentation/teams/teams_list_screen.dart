import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/team_repository.dart';
import '../../data/local/database.dart';
import '../../core/theme.dart';
import '../common/widgets/sports_ui.dart';
import 'widgets/team_card.dart';

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
                              final players = snapshot.data ?? [];
                              return TeamCard(
                                team: team,
                                players: players,
                                onTap: () => context.push('/teams/details',
                                    extra: team),
                                customActions: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: const Icon(
                                      Icons.person_add_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    tooltip: 'Add Players',
                                    onPressed: () async {
                                      await context.push(
                                        '/teams/add-players/${team.id}',
                                      );
                                      _loadTeams();
                                    },
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    tooltip: 'Edit Team',
                                    onPressed: () => context
                                        .push('/teams/create?id=${team.id}'),
                                  ),
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: const Icon(
                                      Icons.more_vert_rounded,
                                      color: Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    onSelected: (val) async {
                                      if (val == 'archive') {
                                        await ref
                                            .read(teamRepositoryProvider)
                                            .archiveTeam(team.id);
                                        _loadTeams();
                                      } else if (val == 'delete') {
                                        await ref
                                            .read(teamRepositoryProvider)
                                            .deleteTeam(team.id);
                                        _loadTeams();
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'archive',
                                        child: Text('Archive Team'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete Team',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
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
