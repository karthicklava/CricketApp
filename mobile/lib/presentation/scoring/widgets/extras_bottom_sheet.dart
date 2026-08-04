import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

enum NoBallRunSource { bat, bye, legBye, running }

class ExtraSelection {
  final ExtrasType type;
  final int runs;
  final NoBallRunSource? noBallSource;

  const ExtraSelection({
    required this.type,
    required this.runs,
    this.noBallSource,
  });
}

class ExtrasBottomSheet extends StatefulWidget {
  final ExtrasType type;

  const ExtrasBottomSheet({super.key, required this.type});

  @override
  State<ExtrasBottomSheet> createState() => _ExtrasBottomSheetState();
}

class _ExtrasBottomSheetState extends State<ExtrasBottomSheet> {
  int _runs = 1;
  NoBallRunSource _source = NoBallRunSource.bat;

  @override
  void initState() {
    super.initState();
    if (widget.type == ExtrasType.noBall || widget.type == ExtrasType.wide) {
      _runs = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNoBall = widget.type == ExtrasType.noBall;
    final isWide = widget.type == ExtrasType.wide;
    final choices = isNoBall
        ? const [0, 1, 2, 3, 4, 6]
        : isWide
            ? const [0, 1, 2, 3, 4, 5]
            : const [1, 2, 3, 4, 5];
    final title = switch (widget.type) {
      ExtrasType.wide => 'Wide',
      ExtrasType.noBall => 'No Ball',
      ExtrasType.bye => 'Bye Runs',
      ExtrasType.legBye => 'Leg Bye Runs',
      _ => 'Select Runs',
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (isWide) ...[
              const SizedBox(height: 12),
              const Text(
                'Additional Runs After Wide',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select only the additional runs completed after the mandatory Wide. One penalty run for the Wide is added automatically.',
              ),
            ],
            if (isNoBall) ...[
              const SizedBox(height: 16),
              const Text('Additional runs from'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: NoBallRunSource.values.map((source) {
                  return ChoiceChip(
                    label: Text(switch (source) {
                      NoBallRunSource.bat => 'Bat',
                      NoBallRunSource.bye => 'Bye',
                      NoBallRunSource.legBye => 'Leg Bye',
                      NoBallRunSource.running => 'Running',
                    }),
                    selected: _source == source,
                    onSelected: (_) => setState(() => _source = source),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            if (!isWide) Text(isNoBall ? 'Additional runs' : 'Runs'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: choices.map((runs) {
                return ChoiceChip(
                  label: Text('$runs'),
                  selected: _runs == runs,
                  onSelected: (_) => setState(() => _runs = runs),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      ExtraSelection(
                        type: widget.type,
                        runs: _runs,
                        noBallSource: isNoBall ? _source : null,
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
