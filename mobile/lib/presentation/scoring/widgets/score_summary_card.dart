import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import '../../common/widgets/live_match_header.dart';
import 'over_delivery_sequence.dart';

class ScoreSummaryCard extends StatelessWidget {
  final MatchState matchState;
  final String syncStatusText;
  final bool isOnline;
  final bool compact;

  const ScoreSummaryCard({
    super.key,
    required this.matchState,
    required this.syncStatusText,
    required this.isOnline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final inn = matchState.activeInnings;
    final bowlingTeam = inn.battingTeamId == matchState.teamA.id
        ? matchState.teamB
        : matchState.teamA;
    final bowler = bowlingTeam.players.firstWhere(
      (player) => player.id == inn.currentBowlerId,
      orElse: () =>
          Player(id: inn.currentBowlerId ?? '', name: 'Awaiting next bowler'),
    );

    final currentOverNumber =
        inn.legalBallsBowled ~/ matchState.config.ballsPerOver;
    final currentOver = matchState.events
        .where((event) =>
            event.inningsId == inn.inningsId &&
            event.overNumber == currentOverNumber)
        .toList()
      ..sort((a, b) => a.sequenceInOver.compareTo(b.sequenceInOver));
    final displayItems =
        currentOver.map(DeliveryDisplayItem.fromEvent).toList();
    final overRuns =
        currentOver.fold<int>(0, (sum, event) => sum + event.totalRuns);
    final overWickets = currentOver
        .where((event) =>
            event.wicket != null &&
            WicketHandler.countsAsTeamWicket(event.wicket!.type))
        .length;
    final activeOverNumber = currentOverNumber + 1;
    final replacements = matchState.bowlerReplacementEvents.where((item) =>
        item.inningsId == inn.inningsId && item.overId == inn.activeOverId);
    final replacement = replacements.isEmpty ? null : replacements.last;
    String playerName(String id) {
      final players = bowlingTeam.players.where((player) => player.id == id);
      return players.isEmpty ? id : players.first.name;
    }

    return Card(
      margin: EdgeInsets.fromLTRB(12, compact ? 6 : 12, 12, compact ? 4 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F5132), Color(0xFF198754)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            LiveMatchHeader.fromMatchState(
              matchState,
              darkSurface: true,
              compact: compact,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.onlineGreen
                      : AppColors.offlineOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      syncStatusText,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.white24, height: compact ? 12 : 20),
            Align(
              alignment: Alignment.centerLeft,
              child: CurrentOverWidget(
                title: 'Current Over · $activeOverNumber',
                bowlerName: bowler.name,
                deliveries: displayItems,
                ballsPerOver: matchState.config.ballsPerOver,
                currentOverRuns: overRuns,
                currentOverWickets: overWickets,
                isCompleted: false,
                onDarkSurface: true,
              ),
            ),
            if (replacement != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bowler changed: ${playerName(replacement.previousBowlerId)} '
                  '→ ${playerName(replacement.replacementBowlerId)} '
                  'due to ${replacement.reason.name}.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
