import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../common/widgets/live_match_header.dart';
import 'over_delivery_sequence.dart';
import 'compact_live_players_section.dart';

class ScoreSummaryCard extends StatelessWidget {
  final MatchState matchState;
  final String syncStatusText;
  final bool isOnline;
  final bool compact;
  final LivePlayerFigures? liveFigures;
  final VoidCallback? onMorePressed;
  final VoidCallback? onBowlerPressed;

  const ScoreSummaryCard({
    super.key,
    required this.matchState,
    required this.syncStatusText,
    required this.isOnline,
    this.compact = false,
    this.liveFigures,
    this.onMorePressed,
    this.onBowlerPressed,
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

    final calculatedOverNumber =
        inn.legalBallsBowled ~/ matchState.config.ballsPerOver;
    final lastInningsEvents = matchState.events
        .where((event) => event.inningsId == inn.inningsId)
        .toList();
    final currentOverNumber = inn.isCompleted && lastInningsEvents.isNotEmpty
        ? lastInningsEvents.last.overNumber
        : calculatedOverNumber.clamp(
            0,
            matchState.config.totalOvers - 1,
          ) as int;
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
      margin: EdgeInsets.fromLTRB(10, compact ? 4 : 12, 10, compact ? 4 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(compact ? 10 : 16),
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
            LiveMatchSummaryCard.fromMatchState(
              matchState,
              variant: compact
                  ? LiveMatchCardVariant.liveScoringCompact
                  : LiveMatchCardVariant.liveScoreHeader,
              darkSurface: true,
              connectionState: isOnline
                  ? MatchConnectionState.online
                  : MatchConnectionState.savedOffline,
            ),
            Divider(color: Colors.white24, height: compact ? 8 : 20),
            Align(
              alignment: Alignment.centerLeft,
              child: CurrentOverWidget(
                title: 'Current Over · $activeOverNumber',
                bowlerName: liveFigures == null ? bowler.name : null,
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
            if (liveFigures != null) ...[
              const Divider(color: Colors.white24, height: 8),
              CompactLivePlayersSection(
                figures: liveFigures!,
                matchState: matchState,
                onMorePressed: onMorePressed ?? () {},
                onBowlerPressed: onBowlerPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
