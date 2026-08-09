import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils/player_sorting.dart';

class NextBatterSelectionBottomSheet extends StatefulWidget {
  const NextBatterSelectionBottomSheet({
    super.key,
    required this.eligibleBatters,
    required this.onConfirmed,
    this.onAddNewBatter,
    this.onUndoLastBall,
  });

  final List<Player> eligibleBatters;
  final Future<bool> Function(String playerId) onConfirmed;
  final Future<Player?> Function()? onAddNewBatter;
  final Future<bool> Function()? onUndoLastBall;

  @override
  State<NextBatterSelectionBottomSheet> createState() =>
      _NextBatterSelectionBottomSheetState();
}

class _NextBatterSelectionBottomSheetState
    extends State<NextBatterSelectionBottomSheet> {
  late final List<Player> _batters = sortPlayersByName(widget.eligibleBatters);
  final TextEditingController _searchController = TextEditingController();
  String? _selectedId;
  String _query = '';
  bool _saving = false;

  List<Player> get _visibleBatters {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _batters;
    return _batters
        .where((player) => player.name.trim().toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Column(
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
                      if (widget.onUndoLastBall != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const ValueKey('next-batter-undo-last-ball'),
                            onPressed: _saving
                                ? null
                                : () async {
                                    setState(() => _saving = true);
                                    final undone =
                                        await widget.onUndoLastBall!();
                                    if (!mounted) return;
                                    if (undone) {
                                      Navigator.pop(context);
                                    } else {
                                      setState(() => _saving = false);
                                    }
                                  },
                            icon: const Icon(Icons.undo),
                            label: const Text('UNDO LAST BALL'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        key: const ValueKey('next-batter-search'),
                        controller: _searchController,
                        enabled: !_saving,
                        onChanged: (value) => setState(() => _query = value),
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search batter…',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    key: const ValueKey('next-batter-scrollable-list'),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    children: [
                      for (final player in _visibleBatters)
                        RadioListTile<String>(
                          value: player.id,
                          groupValue: _selectedId,
                          title: Text(player.name),
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _selectedId = value),
                        ),
                      if (_batters.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                              'No eligible batter is currently available.'),
                        )
                      else if (_visibleBatters.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No batters match your search.'),
                        ),
                      if (widget.onAddNewBatter != null)
                        TextButton.icon(
                          onPressed: _saving
                              ? null
                              : () async {
                                  final player = await widget.onAddNewBatter!();
                                  if (player != null && mounted) {
                                    setState(() {
                                      _batters
                                        ..add(player)
                                        ..sort(comparePlayersByName);
                                      _selectedId = player.id;
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  }
                                },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add New Batter'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  key: const ValueKey('next-batter-sticky-footer'),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppCtaStyle.height,
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
                ),
              ],
            ),
          ),
        ),
      );
}
