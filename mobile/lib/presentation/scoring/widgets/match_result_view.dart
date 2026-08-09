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
  final Future<bool> Function()? onUndoLastBall;

  const MatchResultView({
    super.key,
    required this.matchState,
    required this.engine,
    this.onUndoLastBall,
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
            VictoryHeroBanner(
              result: res,
              resultText: resultText,
              teamA: matchState.teamA,
              teamB: matchState.teamB,
              manuallyEnded: manuallyEnded,
            ),
            const SizedBox(height: 20),

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

            if (!manuallyEnded && onUndoLastBall != null) ...[
              OutlinedButton.icon(
                key: const ValueKey('match-result-undo-last-ball'),
                icon: const Icon(Icons.undo),
                label: const Text('UNDO LAST BALL'),
                onPressed: onUndoLastBall,
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
                minimumSize: const Size(double.infinity, AppCtaStyle.height),
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
                  '${matchState.teamA.name} vs ${matchState.teamB.name}\n\n$resultText\n\n${captainLine(matchState.teamA)}\n${captainLine(matchState.teamB)}\n\nScore at match end:\n$scores\n\nFull scorecard available in TurfScore.',
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

class VictoryHeroBanner extends StatefulWidget {
  const VictoryHeroBanner({
    super.key,
    required this.result,
    required this.resultText,
    required this.teamA,
    required this.teamB,
    required this.manuallyEnded,
  });

  final MatchResult? result;
  final String resultText;
  final Team teamA;
  final Team teamB;
  final bool manuallyEnded;

  @override
  State<VictoryHeroBanner> createState() => _VictoryHeroBannerState();
}

class _VictoryHeroBannerState extends State<VictoryHeroBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _heroScale = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  bool get _isTie =>
      widget.result?.isTie == true ||
      widget.resultText.toLowerCase().contains('tied');

  Team? get _winner {
    final winnerId = widget.result?.winnerTeamId;
    if (winnerId == widget.teamA.id) return widget.teamA;
    if (winnerId == widget.teamB.id) return widget.teamB;
    return null;
  }

  String get _marginText {
    final result = widget.result;
    if (_isTie) return 'MATCH TIED';
    if (result != null && result.winByRuns > 0) {
      return 'WON BY ${result.winByRuns} ${result.winByRuns == 1 ? 'RUN' : 'RUNS'}';
    }
    if (result != null && result.winByWickets > 0) {
      return 'WON BY ${result.winByWickets} ${result.winByWickets == 1 ? 'WICKET' : 'WICKETS'}';
    }
    return widget.resultText.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = _winner;
    final isNeutral = widget.manuallyEnded || winner == null;
    final badge = widget.manuallyEnded
        ? 'FINAL RESULT'
        : _isTie
            ? 'FINAL RESULT'
            : 'MATCH COMPLETE';

    return Semantics(
      container: true,
      label: _isTie
          ? 'Final result. Match tied.'
          : winner == null
              ? 'Final result. ${widget.resultText}'
              : 'Match complete. ${widget.resultText}',
      child: Container(
        key: const ValueKey('victory-hero-banner'),
        constraints: const BoxConstraints(minHeight: 300),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFF063D2E), Color(0xFF0B6E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3307513B),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _ResultBadge(label: badge, isTie: _isTie),
            const SizedBox(height: 8),
            SizedBox(
              height: 142,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => CustomPaint(
                  painter: _CelebrationPainter(
                    progress: _controller.value,
                    isTie: _isTie || isNeutral,
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: _heroScale,
                      child: _isTie
                          ? const _TieIllustration()
                          : isNeutral
                              ? const _FinalResultIllustration()
                              : const _GoldTrophyIllustration(),
                    ),
                  ),
                ),
              ),
            ),
            if (winner != null && !_isTie) ...[
              Text(
                winner.name,
                key: const ValueKey('victory-team-name'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              _marginText,
              key: const ValueKey('victory-result-margin'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    _isTie ? const Color(0xFFE8F4FF) : const Color(0xFFFFD66B),
                fontSize: winner == null ? 17 : 15,
                fontWeight: FontWeight.w900,
                letterSpacing: winner == null ? .2 : 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.label, required this.isTie});

  final String label;
  final bool isTie;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: .24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTie ? Icons.balance_rounded : Icons.emoji_events_rounded,
              color: isTie ? const Color(0xFFDCEEFF) : const Color(0xFFFFD66B),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _GoldTrophyIllustration extends StatelessWidget {
  const _GoldTrophyIllustration();

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('gold-trophy-illustration'),
        width: 116,
        height: 116,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x66FFD66B), Color(0x11FFD66B), Colors.transparent],
            stops: [0, .62, 1],
          ),
        ),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFF3B0), Color(0xFFFFC337), Color(0xFFCE8500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(Icons.emoji_events_rounded, size: 88),
        ),
      );
}

class _TieIllustration extends StatelessWidget {
  const _TieIllustration();

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('tie-result-illustration'),
        width: 108,
        height: 108,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x665EB5F7), Color(0x115EB5F7), Colors.transparent],
          ),
        ),
        child: const Icon(
          Icons.balance_rounded,
          size: 72,
          color: Color(0xFFDCEEFF),
        ),
      );
}

class _FinalResultIllustration extends StatelessWidget {
  const _FinalResultIllustration();

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('neutral-result-illustration'),
        width: 104,
        height: 104,
        decoration: const BoxDecoration(
          color: Color(0x1FFFFFFF),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_score_rounded,
            size: 66, color: Colors.white),
      );
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({required this.progress, required this.isTie});

  final double progress;
  final bool isTie;

  static const _particles = <(Offset, double)>[
    (Offset(.12, .28), 4),
    (Offset(.22, .68), 3),
    (Offset(.34, .14), 3),
    (Offset(.68, .12), 4),
    (Offset(.79, .64), 3),
    (Offset(.89, .30), 4),
    (Offset(.08, .52), 2.5),
    (Offset(.93, .55), 2.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress.clamp(0, 1).toDouble();
    final colors = isTie
        ? const [Color(0xFFDCEEFF), Color(0xFF8CC8FF)]
        : const [Color(0xFFFFD66B), Color(0xFFFFF2B2)];
    for (var index = 0; index < _particles.length; index++) {
      final particle = _particles[index];
      final center = Offset(
        particle.$1.dx * size.width,
        particle.$1.dy * size.height - (1 - progress) * 8,
      );
      final paint = Paint()
        ..color = colors[index % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      if (index.isEven) {
        canvas.drawCircle(center, particle.$2, paint);
      } else {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(progress * .7);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.$2 * 1.4,
            height: particle.$2 * 3,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isTie != isTie;
}
