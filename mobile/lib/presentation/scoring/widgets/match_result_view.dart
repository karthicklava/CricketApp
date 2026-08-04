import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import '../../common/widgets/match_awards_section.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/match_repository.dart';

class MatchResultView extends ConsumerWidget {
  final MatchState matchState;
  final CricketScoringEngine engine;

  const MatchResultView({
    super.key,
    required this.matchState,
    required this.engine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = matchState.result;
    final resultText =
        matchState.manualResultText ?? res?.resultString ?? 'Match Completed';
    final manuallyEnded = matchState.endedManually;

    final inn1 = matchState.innings.isNotEmpty ? matchState.innings[0] : null;
    final inn2 = matchState.innings.length > 1 ? matchState.innings[1] : null;

    final team1 = inn1 != null
        ? (inn1.battingTeamId == matchState.teamA.id
            ? matchState.teamA
            : matchState.teamB)
        : matchState.teamA;
    final team2 = inn2 != null
        ? (inn2.battingTeamId == matchState.teamA.id
            ? matchState.teamA
            : matchState.teamB)
        : matchState.teamB;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.emoji_events, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 20),

            Text(
              manuallyEnded ? 'MATCH ENDED' : 'MATCH COMPLETE',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),

            Text(
              resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 32),

            if (manuallyEnded) ...[
              Text(
                'Reason: ${matchState.endReasonText ?? 'Not specified'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (matchState.endNote?.isNotEmpty == true)
                Text(matchState.endNote!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
            ],

            // Final Innings Scorecard Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (inn1 != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(team1.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                              '${inn1.totalRuns}/${inn1.totalWickets} (${inn1.oversFormatted} ov)${inn1.completionReason == 'All Out' ? ' All Out' : ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                    if (inn2 != null) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(team2.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                              '${inn2.totalRuns}/${inn2.totalWickets} (${inn2.oversFormatted} ov)${inn2.completionReason == 'All Out' ? ' All Out' : ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!manuallyEnded)
              MatchAwardsSection(
                awards: matchState.awards,
                matchState: matchState,
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.home),
                label: const Text('RETURN HOME',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => context.go('/'),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.assessment),
              label: const Text('VIEW FULL SCORECARD'),
              onPressed: () => context.push('/scorecard', extra: engine),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERATE PDF'),
              onPressed: () => context.push(
                '/matches/history/${matchState.matchId}/pdf',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('SHARE SUMMARY'),
              onPressed: () {
                String captainLine(Team team) {
                  final captainId =
                      matchState.roleSnapshotForTeam(team.id)?.captainPlayerId;
                  String? captainName;
                  for (final player in team.players) {
                    if (player.id == captainId) captainName = player.name;
                  }
                  return '${team.name} Captain: ${captainName ?? 'Not recorded'}';
                }

                final scores = matchState.innings.map((innings) {
                  final team = innings.battingTeamId == matchState.teamA.id
                      ? matchState.teamA
                      : matchState.teamB;
                  return '${team.name} — ${innings.totalRuns}/${innings.totalWickets} in ${innings.oversFormatted} overs';
                }).join('\n');
                Share.share(
                  '${matchState.teamA.name} vs ${matchState.teamB.name}\n\n$resultText\n\n${captainLine(matchState.teamA)}\n${captainLine(matchState.teamB)}\n\nScore at match end:\n$scores\n\nFull scorecard available in Cricket Scorer.',
                );
              },
            ),
            if (manuallyEnded) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('START NEW MATCH'),
                onPressed: () => context.go('/matches/create'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text('REOPEN MATCH'),
                onPressed: () => _reopen(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen this match?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Administrative reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim().isNotEmpty,
            ),
            child: const Text('Reopen Match'),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (confirmed != true || !context.mounted) return;
    final previous = engine.state;
    try {
      engine.reopenManuallyEndedMatch();
      await ref.read(matchRepositoryProvider).persistManualReopen(
            state: engine.state,
            reason: reason,
            reopenedBy: 'device_123',
          );
      if (context.mounted) {
        context.go('/matches/${engine.state.matchId}/scoring',
            extra: engine.state);
      }
    } catch (error) {
      engine.restoreState(previous);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
      }
    }
  }
}
