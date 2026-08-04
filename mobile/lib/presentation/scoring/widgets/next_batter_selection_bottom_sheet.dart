import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class NextBatterSelectionBottomSheet extends StatefulWidget {
  const NextBatterSelectionBottomSheet({
    super.key,
    required this.eligibleBatters,
    required this.onConfirmed,
    this.onAddNewBatter,
  });

  final List<Player> eligibleBatters;
  final Future<bool> Function(String playerId) onConfirmed;
  final Future<Player?> Function()? onAddNewBatter;

  @override
  State<NextBatterSelectionBottomSheet> createState() =>
      _NextBatterSelectionBottomSheetState();
}

class _NextBatterSelectionBottomSheetState
    extends State<NextBatterSelectionBottomSheet> {
  late final List<Player> _batters = List.of(widget.eligibleBatters);
  String? _selectedId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SELECT NEXT BATTER',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
                const SizedBox(height: 6),
                const Text(
                  'A wicket has fallen. Confirm the incoming batter before continuing.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                for (final player in _batters)
                  RadioListTile<String>(
                    value: player.id,
                    groupValue: _selectedId,
                    title: Text(player.name),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _selectedId = value),
                  ),
                if (_batters.isEmpty)
                  const Text('No eligible batter is currently available.'),
                if (widget.onAddNewBatter != null)
                  TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final player = await widget.onAddNewBatter!();
                            if (player != null && mounted) {
                              setState(() {
                                _batters.add(player);
                                _selectedId = player.id;
                              });
                            }
                          },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add New Batter'),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedId == null || _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            final saved =
                                await widget.onConfirmed(_selectedId!);
                            if (!mounted) return;
                            if (saved) {
                              Navigator.pop(context);
                            } else {
                              setState(() => _saving = false);
                            }
                          },
                    child: Text(_saving ? 'SAVING…' : 'CONFIRM BATTER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
