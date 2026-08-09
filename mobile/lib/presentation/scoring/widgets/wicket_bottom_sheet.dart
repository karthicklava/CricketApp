import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';
import '../../../core/utils/player_sorting.dart';

class WicketBottomSheet extends StatefulWidget {
  final Player striker;
  final Player nonStriker;
  final Player bowler;
  final List<Player> fieldingTeamPlayers;
  final List<Player> remainingBatters;
  final Function(WicketDetail detail, String? newBatterId) onConfirm;
  final Future<Player?> Function()? onAddNewBatter;

  const WicketBottomSheet({
    super.key,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.fieldingTeamPlayers,
    required this.remainingBatters,
    required this.onConfirm,
    this.onAddNewBatter,
  });

  @override
  State<WicketBottomSheet> createState() => _WicketBottomSheetState();
}

class _WicketBottomSheetState extends State<WicketBottomSheet> {
  WicketType _selectedType = WicketType.bowled;
  late String _dismissedPlayerId;
  String? _selectedFielderId;
  int _runsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _dismissedPlayerId = widget.striker.id;
  }

  @override
  Widget build(BuildContext context) {
    final fielders = sortPlayersByName(widget.fieldingTeamPlayers);
    return Container(
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

            const Text(
              'WICKET DISMISSAL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.wicketRed,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Wicket Type Selector Chips
            const Text('Dismissal Type:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                WicketType.bowled,
                WicketType.caught,
                WicketType.lbw,
                WicketType.runOut,
                WicketType.stumped,
                WicketType.hitWicket,
                WicketType.retiredHurt,
                WicketType.retiredOut,
              ].map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: isSelected,
                  selectedColor: AppColors.wicketRed,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Dismissed Player Selector
            const Text('Dismissed Batter:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<String>(
              title: Text('${widget.striker.name} (Striker)'),
              value: widget.striker.id,
              groupValue: _dismissedPlayerId,
              onChanged: (val) => setState(() => _dismissedPlayerId = val!),
            ),
            RadioListTile<String>(
              title: Text('${widget.nonStriker.name} (Non-Striker)'),
              value: widget.nonStriker.id,
              groupValue: _dismissedPlayerId,
              onChanged: (val) => setState(() => _dismissedPlayerId = val!),
            ),

            // Fielder Selector (For Caught / Run Out / Stumped)
            if (_selectedType == WicketType.caught ||
                _selectedType == WicketType.runOut ||
                _selectedType == WicketType.stumped) ...[
              const SizedBox(height: 8),
              const Text('Fielder:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              DropdownButtonFormField<String>(
                value: _selectedFielderId,
                hint: const Text('Select Fielder'),
                items: fielders.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedFielderId = val),
              ),
            ],

            if (_selectedType == WicketType.runOut) ...[
              const SizedBox(height: 16),
              const Text(
                'Completed Runs:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0, 1, 2, 3].map((runs) {
                  return ChoiceChip(
                    label: Text('$runs'),
                    selected: _runsCompleted == runs,
                    onSelected: (_) => setState(() => _runsCompleted = runs),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: AppCtaStyle.height,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wicketRed,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final detail = WicketDetail(
                    type: _selectedType,
                    dismissedPlayerId: _dismissedPlayerId,
                    fielderId: _selectedFielderId,
                    runsCompletedBeforeDismissal: _runsCompleted,
                  );
                  widget.onConfirm(detail, null);
                  Navigator.pop(context);
                },
                child: const Text('CONFIRM WICKET',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
