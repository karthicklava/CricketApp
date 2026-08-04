import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import '../../common/widgets/sports_ui.dart';

class ScoringActionGrid extends StatefulWidget {
  final ValueChanged<int> onRunPressed;
  final VoidCallback onWicketPressed;
  final ValueChanged<ExtrasType> onExtrasPressed;
  final VoidCallback onUndoPressed;
  final VoidCallback onMorePressed;

  const ScoringActionGrid({
    super.key,
    required this.onRunPressed,
    required this.onWicketPressed,
    required this.onExtrasPressed,
    required this.onUndoPressed,
    required this.onMorePressed,
  });

  @override
  State<ScoringActionGrid> createState() => _ScoringActionGridState();
}

class _ScoringActionGridState extends State<ScoringActionGrid> {
  DateTime? _lastActionAt;

  void _debounced(VoidCallback action) {
    final now = DateTime.now();
    if (_lastActionAt != null &&
        now.difference(_lastActionAt!) < const Duration(milliseconds: 250)) {
      return;
    }
    _lastActionAt = now;
    action();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 300 ? 3 : 4;
              final cellWidth =
                  (constraints.maxWidth - ((columns - 1) * 8)) / columns;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Runs',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: cellWidth / 48,
                    children: [
                      for (final runs in const [0, 1, 2, 3, 4, 5, 6])
                        _ActionButton(
                          label: '$runs',
                          semanticLabel: 'Record $runs runs',
                          background: runs == 4 || runs == 6
                              ? AppColors.primaryLight
                              : Colors.grey.shade200,
                          foreground: runs == 4 || runs == 6
                              ? Colors.white
                              : AppColors.textPrimary,
                          onPressed: () =>
                              _debounced(() => widget.onRunPressed(runs)),
                        ),
                      _ActionButton(
                        label: 'W',
                        semanticLabel: 'Record wicket',
                        background: AppColors.wicketRed,
                        foreground: Colors.white,
                        onPressed: () => _debounced(widget.onWicketPressed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Extras',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _extra('Wd', 'Wide', ExtrasType.wide),
                      const SizedBox(width: 6),
                      _extra('Nb', 'No Ball', ExtrasType.noBall),
                      const SizedBox(width: 6),
                      _extra('Bye', 'Bye', ExtrasType.bye),
                      const SizedBox(width: 6),
                      _extra('LB', 'Leg Bye', ExtrasType.legBye),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _debounced(widget.onUndoPressed),
                            icon: const Icon(Icons.undo, size: 20),
                            label: const Text('Undo'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: widget.onMorePressed,
                            icon: const Icon(Icons.more_horiz, size: 20),
                            label: const Text('More'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _extra(String label, String semanticLabel, ExtrasType type) {
    return Expanded(
      child: _ActionButton(
        label: label,
        semanticLabel: 'Record $semanticLabel',
        background: Colors.orange.shade100,
        foreground: Colors.orange.shade900,
        onPressed: () => _debounced(() => widget.onExtrasPressed(type)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.semanticLabel,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ScoreButton(
        label: label,
        onPressed: onPressed,
        backgroundColor: background,
        foregroundColor: foreground,
      ),
    );
  }
}
