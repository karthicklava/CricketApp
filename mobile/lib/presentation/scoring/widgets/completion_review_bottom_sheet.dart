import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class CompletionReviewBottomSheet extends StatefulWidget {
  const CompletionReviewBottomSheet({
    super.key,
    required this.matchState,
    required this.onUndo,
    required this.onEdit,
    required this.onConfirm,
  });

  final MatchState matchState;
  final Future<bool> Function() onUndo;
  final Future<bool> Function() onEdit;
  final Future<bool> Function() onConfirm;

  @override
  State<CompletionReviewBottomSheet> createState() =>
      _CompletionReviewBottomSheetState();
}

class _CompletionReviewBottomSheetState
    extends State<CompletionReviewBottomSheet> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() => _busy = true);
    final close = await action();
    if (!mounted) return;
    if (close) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.matchState;
    final innings = state.activeInnings;
    final team =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final last = state.events.last;
    final isMatchReview = state.status == MatchStatus.matchReview;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isMatchReview ? 'TARGET REACHED' : 'INNINGS COMPLETE',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${team.shortName}  ${innings.totalRuns}/${innings.totalWickets}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Text('${innings.oversFormatted} overs'
                  '${innings.completionReason == null ? '' : ' · ${innings.completionReason}'}'),
              const SizedBox(height: 18),
              const Text('LAST DELIVERY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                finalDeliveryDescription(last),
                key: const ValueKey('completion-review-last-delivery'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review the final delivery before this result is finalized.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('completion-review-undo'),
                      onPressed: _busy ? null : () => _run(widget.onUndo),
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo Last Ball'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('completion-review-edit'),
                      onPressed: _busy ? null : () => _run(widget.onEdit),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Last Ball'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton(
                key: const ValueKey('completion-review-confirm'),
                onPressed: _busy ? null : () => _run(widget.onConfirm),
                child: Text(isMatchReview
                    ? 'CONFIRM & END MATCH'
                    : 'CONFIRM INNINGS & CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String finalDeliveryDescription(DeliveryEvent delivery) {
  final wicket = delivery.wicket;
  if (wicket != null) {
    return switch (wicket.type) {
      WicketType.runOut => 'Run Out',
      WicketType.retiredHurt => 'Retired Hurt',
      WicketType.retiredOut => 'Retired Out',
      WicketType.retiredNotOut => 'Retired Not Out',
      WicketType.absentHurt => 'Absent Hurt',
      _ => 'Wicket',
    };
  }
  if (delivery.wideRuns > 0) {
    return delivery.additionalWideRuns == 0
        ? 'Wide'
        : 'Wd + ${delivery.additionalWideRuns}';
  }
  if (delivery.noBallRuns > 0) {
    final additional =
        delivery.runsBatter + delivery.byeRuns + delivery.legByeRuns;
    return additional == 0 ? 'No Ball' : 'Nb + $additional';
  }
  if (delivery.legByeRuns > 0) return 'Leg Bye ${delivery.legByeRuns}';
  if (delivery.byeRuns > 0) return 'Bye ${delivery.byeRuns}';
  if (delivery.penaltyRuns > 0) {
    return 'Penalty ${delivery.penaltyRuns} Runs';
  }
  if (delivery.runsBatter == 0) return 'Dot Ball';
  if (delivery.isBoundarySix) return 'Six';
  if (delivery.isBoundaryFour) return 'Boundary Four';
  return '${delivery.runsBatter} ${delivery.runsBatter == 1 ? 'Run' : 'Runs'}';
}

enum FinalDeliveryEditType { legalRuns, wide, noBall }

class FinalDeliveryEdit {
  const FinalDeliveryEdit(this.type, this.runs);
  final FinalDeliveryEditType type;
  final int runs;
}

class EditFinalDeliveryBottomSheet extends StatelessWidget {
  const EditFinalDeliveryBottomSheet({super.key, required this.delivery});

  final DeliveryEvent delivery;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('EDIT LAST BALL',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Current: ${delivery.displayLabel}'),
              const SizedBox(height: 16),
              const Text('Replace with legal runs'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final runs in const [0, 1, 2, 3, 4, 5, 6])
                    ActionChip(
                      label: Text('$runs'),
                      onPressed: () => Navigator.pop(
                        context,
                        FinalDeliveryEdit(
                            FinalDeliveryEditType.legalRuns, runs),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Or replace delivery type'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const FinalDeliveryEdit(FinalDeliveryEditType.wide, 1),
                      ),
                      child: const Text('Wide'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const FinalDeliveryEdit(
                            FinalDeliveryEditType.noBall, 1),
                      ),
                      child: const Text('No Ball'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
