import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import '../../../core/utils/player_sorting.dart';

class BowlerSelectionBottomSheet extends StatefulWidget {
  final MatchState matchState;
  final Team bowlingTeam;
  final String? currentBowlerId;
  final String? previousBowlerId;
  final bool isMidOver;
  final Future<bool> Function(String newBowlerId, String? reason)
      onBowlerSelected;
  final VoidCallback? onAddNewBowler;
  final Future<bool> Function()? onUndoLastBall;

  const BowlerSelectionBottomSheet({
    super.key,
    required this.matchState,
    required this.bowlingTeam,
    this.currentBowlerId,
    this.previousBowlerId,
    this.isMidOver = false,
    required this.onBowlerSelected,
    this.onAddNewBowler,
    this.onUndoLastBall,
  });

  @override
  State<BowlerSelectionBottomSheet> createState() =>
      _BowlerSelectionBottomSheetState();
}

class _BowlerSelectionBottomSheetState
    extends State<BowlerSelectionBottomSheet> {
  String? _selectedReason = 'Injury';
  bool _overrideConsecutiveRestriction = false;
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    final engine = CricketScoringEngine(widget.matchState);
    final bowlerCards = engine.getBowlerScorecards(widget.bowlingTeam);
    final maxOvers = widget.matchState.config.maxOversPerBowler;
    final innings = widget.matchState.activeInnings;
    final currentOver =
        innings.legalBallsBowled ~/ widget.matchState.config.ballsPerOver;
    final previousOverParticipants = widget.matchState.events
        .where((event) =>
            event.inningsId == innings.inningsId &&
            event.overNumber == currentOver - 1)
        .map((event) => event.bowlerId)
        .toSet();
    final displayedBowlers = sortPlayersByName(widget.bowlingTeam.players);

    final eligibleCount = widget.bowlingTeam.players.where((player) {
      if (!player.isAvailable || !player.isEligibleBowler) return false;
      final card = bowlerCards.firstWhere((c) => c.playerId == player.id,
          orElse: () =>
              BowlerScorecard(playerId: player.id, playerName: player.name));
      final maximumLegalBalls =
          widget.matchState.config.maximumLegalBallsFor(player.id);
      final isMaxReached = maximumLegalBalls != null &&
          card.legalBallsBowled >= maximumLegalBalls;
      final isConsecutive = previousOverParticipants.contains(player.id) &&
          !widget.matchState.config.allowConsecutiveOvers;
      return !isMaxReached &&
          !isConsecutive &&
          !widget.matchState.suspendedBowlerIds.contains(player.id) &&
          widget.currentBowlerId != player.id;
    }).length;

    return PopScope(
      canPop: _allowPop || widget.isMidOver,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isMidOver
                        ? 'MID-OVER BOWLER CHANGE'
                        : 'SELECT NEXT BOWLER',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    widget.matchState.config.bowlerLimitMode ==
                            BowlerLimitMode.unlimited
                        ? 'Unlimited overs'
                        : 'Default $maxOvers ov/bowler',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!widget.isMidOver && widget.onUndoLastBall != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const ValueKey('next-bowler-undo-last-ball'),
                    onPressed: () async {
                      final undone = await widget.onUndoLastBall!();
                      if (undone && context.mounted) {
                        setState(() => _allowPop = true);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.undo),
                    label: const Text('UNDO LAST BALL'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (widget.isMidOver) ...[
                const Text('Reason for mid-over change:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: 'Injury', child: Text('Injury')),
                    const DropdownMenuItem(
                        value: 'Illness', child: Text('Illness')),
                    const DropdownMenuItem(
                        value: 'Unable to continue',
                        child: Text('Unable to continue')),
                    const DropdownMenuItem(
                        value: 'Equipment issue',
                        child: Text('Equipment issue')),
                    const DropdownMenuItem(
                        value: 'Suspended from bowling',
                        child: Text('Suspended from bowling')),
                    if (widget
                        .matchState.config.allowTacticalMidOverReplacement)
                      const DropdownMenuItem(
                          value: 'Tactical replacement under local rules',
                          child:
                              Text('Tactical replacement under local rules')),
                    const DropdownMenuItem(
                        value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) => setState(() => _selectedReason = val),
                ),
                const SizedBox(height: 16),
              ],
              if (eligibleCount == 0 && !_overrideConsecutiveRestriction) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'No eligible bowler available under strict rules.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.amber),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade900),
                        onPressed: () => setState(
                            () => _overrideConsecutiveRestriction = true),
                        child: const Text(
                            'ALLOW CONSECUTIVE OVER FOR THIS SELECTION'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text('Eligible Bowlers:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (widget.onAddNewBowler != null) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _allowPop = true);
                    Navigator.pop(context);
                    widget.onAddNewBowler!();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New Bowler'),
                ),
                const SizedBox(height: 8),
              ],
              ...displayedBowlers.map((player) {
                final card = bowlerCards.firstWhere(
                  (c) => c.playerId == player.id,
                  orElse: () => BowlerScorecard(
                      playerId: player.id, playerName: player.name),
                );

                final maximumLegalBalls =
                    widget.matchState.config.maximumLegalBallsFor(player.id);
                final isMaxOversReached = maximumLegalBalls != null &&
                    card.legalBallsBowled >= maximumLegalBalls;
                final isConsecutiveOver = !_overrideConsecutiveRestriction &&
                    previousOverParticipants.contains(player.id) &&
                    !widget.matchState.config.allowConsecutiveOvers;
                final isCurrentBowler = widget.currentBowlerId == player.id;
                final isSuspended =
                    widget.matchState.suspendedBowlerIds.contains(player.id);

                bool isEligible = player.isAvailable &&
                    player.isEligibleBowler &&
                    !isMaxOversReached &&
                    !isConsecutiveOver &&
                    !isSuspended &&
                    !isCurrentBowler;

                String subtitle =
                    '${card.oversFormatted} ov • ${card.runsConceded} r • ${card.wickets} w';
                if (maximumLegalBalls != null && !isMaxOversReached) {
                  final remaining = maximumLegalBalls - card.legalBallsBowled;
                  final ballsPerOver = widget.matchState.config.ballsPerOver;
                  subtitle += remaining % ballsPerOver == 0
                      ? ' • Remaining: ${remaining ~/ ballsPerOver} over${remaining == ballsPerOver ? '' : 's'}'
                      : ' • Remaining: $remaining legal balls';
                }
                if (isMaxOversReached) subtitle += ' • Maximum overs reached';
                if (isConsecutiveOver)
                  subtitle += ' (Cannot bowl consecutive overs)';
                if (isCurrentBowler) subtitle += ' (Current bowler)';
                if (!player.isEligibleBowler)
                  subtitle += ' (Not an eligible bowler)';
                if (!player.isAvailable) subtitle += ' (Unavailable)';
                if (isSuspended) subtitle += ' (Suspended for this innings)';

                return Card(
                  color: isEligible ? Colors.white : Colors.grey[100],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    enabled: isEligible,
                    leading: CircleAvatar(
                      backgroundColor:
                          isEligible ? AppColors.primary : Colors.grey,
                      child: Text(
                        player.name.isNotEmpty ? player.name[0] : 'B',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isEligible ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    subtitle:
                        Text(subtitle, style: const TextStyle(fontSize: 12)),
                    trailing: isEligible
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white),
                            onPressed: () async {
                              final saved = await widget.onBowlerSelected(
                                  player.id,
                                  widget.isMidOver
                                      ? _selectedReason
                                      : _overrideConsecutiveRestriction
                                          ? 'Allow consecutive over once'
                                          : null);
                              if (saved && context.mounted) {
                                setState(() => _allowPop = true);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('SELECT'),
                          )
                        : const Text('DISABLED',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
