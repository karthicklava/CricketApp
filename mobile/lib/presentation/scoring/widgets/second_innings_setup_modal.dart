import 'package:flutter/material.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../../core/theme.dart';

class SecondInningsSetupModal extends StatefulWidget {
  final MatchState matchState;
  final Function(String strikerId, String nonStrikerId, String bowlerId)
      onStartSecondInnings;
  final VoidCallback onEndMatch;

  const SecondInningsSetupModal({
    super.key,
    required this.matchState,
    required this.onStartSecondInnings,
    required this.onEndMatch,
  });

  @override
  State<SecondInningsSetupModal> createState() =>
      _SecondInningsSetupModalState();
}

class _SecondInningsSetupModalState extends State<SecondInningsSetupModal> {
  String? _strikerId;
  String? _nonStrikerId;
  String? _bowlerId;

  @override
  void initState() {
    super.initState();
    final firstInnings = widget.matchState.innings[0];
    final secondBattingTeam =
        firstInnings.bowlingTeamId == widget.matchState.teamA.id
            ? widget.matchState.teamA
            : widget.matchState.teamB;
    final secondBowlingTeam = secondBattingTeam.id == widget.matchState.teamA.id
        ? widget.matchState.teamB
        : widget.matchState.teamA;

    if (secondBattingTeam.players.length >= 2) {
      _strikerId = secondBattingTeam.players[0].id;
      _nonStrikerId = secondBattingTeam.players[1].id;
    }
    if (secondBowlingTeam.players.isNotEmpty) {
      _bowlerId = secondBowlingTeam.players[0].id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.matchState;
    final inn1 = state.innings[0];
    final inn1Team =
        inn1.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final inn2BattingTeam =
        inn1.bowlingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final inn2BowlingTeam =
        inn2BattingTeam.id == state.teamA.id ? state.teamB : state.teamA;

    final target = inn1.totalRuns + 1;

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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'FIRST INNINGS COMPLETE',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 12),

            // 1st Innings Summary Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                        '${inn1Team.name}: ${inn1.totalRuns}/${inn1.totalWickets} in ${inn1.oversFormatted} ov',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Target for ${inn2BattingTeam.name}: $target Runs in ${state.config.totalOvers} Overs',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Second Innings Openers Setup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Striker Selection
            Text('Opening Striker (${inn2BattingTeam.name})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _strikerId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: inn2BattingTeam.players
                  .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _strikerId = val),
            ),
            const SizedBox(height: 12),

            // Non-Striker Selection
            Text('Opening Non-Striker (${inn2BattingTeam.name})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _nonStrikerId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: inn2BattingTeam.players
                  .where((p) => p.id != _strikerId)
                  .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _nonStrikerId = val),
            ),
            const SizedBox(height: 12),

            // Bowler Selection
            Text('Opening Bowler (${inn2BowlingTeam.name})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _bowlerId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: inn2BowlingTeam.players
                  .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _bowlerId = val),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (_strikerId == null ||
                      _nonStrikerId == null ||
                      _bowlerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please select striker, non-striker, and opening bowler.')));
                    return;
                  }
                  if (_strikerId == _nonStrikerId) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Striker and non-striker must be different players.')));
                    return;
                  }
                  widget.onStartSecondInnings(
                      _strikerId!, _nonStrikerId!, _bowlerId!);
                  Navigator.pop(context);
                },
                child: const Text('START SECOND INNINGS',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onEndMatch();
              },
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
              label:
                  const Text('END MATCH', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
