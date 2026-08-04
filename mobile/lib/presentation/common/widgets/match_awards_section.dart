import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

class MatchAwardsSection extends StatelessWidget {
  final List<MatchAward> awards;
  final bool compact;
  final MatchState? matchState;

  const MatchAwardsSection({
    super.key,
    required this.awards,
    this.compact = false,
    this.matchState,
  });

  String _awardName(MatchAward award) =>
      matchState?.displayNameFor(
        award.teamId,
        award.playerId,
        award.playerNameSnapshot,
      ) ??
      award.playerNameSnapshot;

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Awards not available for this match.'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match Awards', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...awards.map((award) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Icon(
                        award.type == MatchAwardType.bestBatter
                            ? Icons.sports_cricket
                            : Icons.sports_baseball,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            award.type == MatchAwardType.bestBatter
                                ? 'Best Batter'
                                : 'Best Bowler',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _awardName(award),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          Text(award.teamNameSnapshot),
                          Text(award.summary),
                          if (!compact && award.secondarySummary.isNotEmpty)
                            Text(
                              award.secondarySummary,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (award.isManualOverride)
                            const Text(
                              'Selected manually',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.amber),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
