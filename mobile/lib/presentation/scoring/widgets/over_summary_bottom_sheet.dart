import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import 'over_delivery_sequence.dart';

class OverSummaryBottomSheet extends StatefulWidget {
  final MatchState matchState;
  final VoidCallback onSelectNextBowler;
  final VoidCallback onEndMatch;

  const OverSummaryBottomSheet({
    super.key,
    required this.matchState,
    required this.onSelectNextBowler,
    required this.onEndMatch,
  });

  @override
  State<OverSummaryBottomSheet> createState() => _OverSummaryBottomSheetState();
}

class _OverSummaryBottomSheetState extends State<OverSummaryBottomSheet> {
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    final matchState = widget.matchState;
    final activeInnings = matchState.activeInnings;
    final ballsPerOver = matchState.config.ballsPerOver;
    final totalOvers = activeInnings.legalBallsBowled ~/ ballsPerOver;

    final completedOverNumber = totalOvers - 1;
    final lastOverEvents = matchState.events
        .where((event) =>
            event.inningsId == activeInnings.inningsId &&
            event.overNumber == completedOverNumber)
        .toList()
      ..sort((a, b) => a.sequenceInOver.compareTo(b.sequenceInOver));

    final overRuns = lastOverEvents.fold(0, (sum, e) => sum + e.totalRuns);
    final overWickets = lastOverEvents
        .where((event) =>
            event.wicket != null &&
            WicketHandler.countsAsTeamWicket(event.wicket!.type))
        .length;
    final displayItems =
        lastOverEvents.map(DeliveryDisplayItem.fromEvent).toList();

    final battingTeam = activeInnings.battingTeamId == matchState.teamA.id
        ? matchState.teamA
        : matchState.teamB;
    final bowlingTeam = activeInnings.battingTeamId == matchState.teamA.id
        ? matchState.teamB
        : matchState.teamA;

    final striker = battingTeam.players.firstWhere(
        (p) => p.id == activeInnings.strikerId,
        orElse: () => Player(id: activeInnings.strikerId, name: 'Striker'));
    final nonStriker = battingTeam.players.firstWhere(
        (p) => p.id == activeInnings.nonStrikerId,
        orElse: () =>
            Player(id: activeInnings.nonStrikerId, name: 'Non-Striker'));
    final completedOverBowlerIds =
        lastOverEvents.map((event) => event.bowlerId).toSet().toList();
    final bowlerNames = completedOverBowlerIds.map((id) => bowlingTeam.players
        .firstWhere((player) => player.id == id,
            orElse: () => Player(id: id, name: 'Bowler'))
        .name);

    return PopScope(
      canPop: _allowPop,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'END OF OVER $totalOvers',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '$overRuns Runs • $overWickets Wkt',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CurrentOverWidget(
                title: 'Over $totalOvers delivery sequence',
                bowlerName: bowlerNames.join(' / '),
                deliveries: displayItems,
                ballsPerOver: ballsPerOver,
                currentOverRuns: overRuns,
                currentOverWickets: overWickets,
                isCompleted: true,
              ),
              const SizedBox(height: 16),
              const Divider(),

              // Match Score Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${battingTeam.shortName}: ${activeInnings.totalRuns}/${activeInnings.totalWickets}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('CRR: ${activeInnings.runRate.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Batting: ${striker.name} * & ${nonStriker.name}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
              Text(
                  'Bowler${bowlerNames.length > 1 ? 's' : ''}: ${bowlerNames.join(' / ')}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('SELECT NEXT BOWLER',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() => _allowPop = true);
                    Navigator.pop(context);
                    widget.onSelectNextBowler();
                  },
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _allowPop = true);
                  Navigator.pop(context);
                  widget.onEndMatch();
                },
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                label: const Text('END MATCH',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
