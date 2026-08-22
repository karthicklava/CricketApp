import 'package:flutter/material.dart';
import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/presentation/common/widgets/sports_ui.dart';

/// Reusable team card widget ensuring consistent responsive layout,
/// compact captain indicator (C chip), and clean single-line truncation.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.players,
    required this.onTap,
    this.onAddPlayers,
    this.onEditTeam,
    this.customActions,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final TeamsTableData team;
  final List<PlayersTableData> players;
  final VoidCallback onTap;
  final VoidCallback? onAddPlayers;
  final VoidCallback? onEditTeam;
  final List<Widget>? customActions;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final teamColor = team.color != null
        ? Color(int.parse(team.color!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    final captain = players.firstWhere(
      (p) => p.isCaptain,
      orElse: () => PlayersTableData(
        id: '',
        name: '',
        role: '',
        battingStyle: '',
        bowlingStyle: '',
        isCaptain: false,
        isWicketKeeper: false,
        createdAt: 0,
        syncStatus: '',
      ),
    );
    final hasCaptain = captain.name.isNotEmpty;

    return Padding(
      padding: margin,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: teamColor,
                  child: Text(
                    team.shortName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (players.isEmpty)
                        Text(
                          '0 Players • Setup incomplete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${players.length} ${players.length == 1 ? 'Player' : 'Players'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              if (hasCaptain) ...[
                                const TextSpan(
                                  text: ' • ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Text(
                                      'C',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: captain.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (customActions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: customActions!,
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onAddPlayers != null)
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
                          onPressed: onAddPlayers,
                        ),
                      if (onEditTeam != null)
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
                          onPressed: onEditTeam,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
