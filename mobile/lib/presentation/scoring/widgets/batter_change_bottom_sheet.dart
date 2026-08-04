import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

class BatterChangeSelection {
  final Player player;
  final bool replaceStriker;
  final String reason;

  const BatterChangeSelection({
    required this.player,
    required this.replaceStriker,
    required this.reason,
  });
}

class BatterChangeBottomSheet extends StatefulWidget {
  final List<Player> eligiblePlayers;
  final bool replaceStriker;

  const BatterChangeBottomSheet({
    super.key,
    required this.eligiblePlayers,
    required this.replaceStriker,
  });

  @override
  State<BatterChangeBottomSheet> createState() =>
      _BatterChangeBottomSheetState();
}

class _BatterChangeBottomSheetState extends State<BatterChangeBottomSheet> {
  Player? _selected;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              widget.replaceStriker ? 'Change Striker' : 'Change Non-Striker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (widget.eligiblePlayers.isEmpty)
              const Text('No eligible batters are available.')
            else
              DropdownButtonFormField<Player>(
                decoration: const InputDecoration(
                  labelText: 'Eligible batter',
                  border: OutlineInputBorder(),
                ),
                items: widget.eligiblePlayers
                    .map((player) => DropdownMenuItem(
                          value: player,
                          child: Text(player.name),
                        ))
                    .toList(),
                onChanged: (player) => setState(() => _selected = player),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () {
                        final reason = _reasonController.text.trim();
                        if (reason.isEmpty) return;
                        Navigator.pop(
                          context,
                          BatterChangeSelection(
                            player: _selected!,
                            replaceStriker: widget.replaceStriker,
                            reason: reason,
                          ),
                        );
                      },
                child: const Text('Confirm Change'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
