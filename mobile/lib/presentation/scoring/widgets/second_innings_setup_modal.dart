import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils/player_sorting.dart';
import '../../common/widgets/sports_ui.dart';

class SecondInningsSetupModal extends StatefulWidget {
  const SecondInningsSetupModal({
    super.key,
    required this.matchState,
    required this.onStartSecondInnings,
    required this.onEndMatch,
    this.onUndoLastBall,
  });

  final MatchState matchState;
  final Function(String strikerId, String nonStrikerId, String bowlerId)
      onStartSecondInnings;
  final VoidCallback onEndMatch;
  final Future<bool> Function()? onUndoLastBall;

  @override
  State<SecondInningsSetupModal> createState() =>
      _SecondInningsSetupModalState();
}

class _SecondInningsSetupModalState extends State<SecondInningsSetupModal> {
  String? _strikerId;
  String? _nonStrikerId;
  String? _bowlerId;
  bool _undoing = false;

  InningsState get _firstInnings => widget.matchState.innings.first;

  Team get _secondBattingTeam =>
      _firstInnings.bowlingTeamId == widget.matchState.teamA.id
          ? widget.matchState.teamA
          : widget.matchState.teamB;

  Team get _secondBowlingTeam =>
      _secondBattingTeam.id == widget.matchState.teamA.id
          ? widget.matchState.teamB
          : widget.matchState.teamA;

  List<Player> get _availableBatters => sortPlayersByName(
        _secondBattingTeam.players.where((player) => player.isAvailable),
      );

  List<Player> get _availableBowlers => sortPlayersByName(
        _secondBowlingTeam.players.where((player) =>
            player.isAvailable &&
            player.isEligibleBowler &&
            widget.matchState.config.isBowlerConfigured(player.id)),
      );

  bool get _hasValidSelection {
    if (_strikerId == null || _nonStrikerId == null || _bowlerId == null) {
      return false;
    }
    if (_strikerId == _nonStrikerId) return false;
    return _availableBatters.any((player) => player.id == _strikerId) &&
        _availableBatters.any((player) => player.id == _nonStrikerId) &&
        _availableBowlers.any((player) => player.id == _bowlerId);
  }

  @override
  void initState() {
    super.initState();
    final batters = _availableBatters;
    final bowlers = _availableBowlers;
    if (batters.isNotEmpty) _strikerId = batters.first.id;
    if (batters.length > 1) _nonStrikerId = batters[1].id;
    if (bowlers.isNotEmpty) _bowlerId = bowlers.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.matchState;
    final innings = _firstInnings;
    final firstBattingTeam =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final target = innings.totalRuns + 1;
    final requiredRunRate = target / state.config.totalOvers;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            height: screenHeight * .9,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAF9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('second-innings-setup-scroll'),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5DDDA),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _CompletionHeader(),
                        const SizedBox(height: 14),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 260),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: _InningsSummaryCard(
                            teamName: firstBattingTeam.name,
                            score:
                                '${innings.totalRuns}/${innings.totalWickets}',
                            overs: innings.oversFormatted,
                            runRate: innings.runRate,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 320),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: child,
                          ),
                          child: _TargetPanel(
                            target: target,
                            overs: state.config.totalOvers,
                            requiredRunRate: requiredRunRate,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Second Innings Setup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Select the opening batters and bowler.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _selector(
                          key: 'second-innings-opening-batter',
                          label: 'Opening Batter',
                          icon: Icons.sports_cricket,
                          value: _strikerId,
                          players: _availableBatters,
                          onChanged: (value) {
                            setState(() {
                              _strikerId = value;
                              if (_nonStrikerId == value) {
                                _nonStrikerId = _availableBatters
                                    .where((player) => player.id != value)
                                    .firstOrNull
                                    ?.id;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _selector(
                          key: 'second-innings-non-striker',
                          label: 'Non-Striker',
                          icon: Icons.sports_cricket_outlined,
                          value: _nonStrikerId,
                          players: _availableBatters
                              .where((player) => player.id != _strikerId)
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _nonStrikerId = value),
                        ),
                        const SizedBox(height: 10),
                        _selector(
                          key: 'second-innings-opening-bowler',
                          label: 'Opening Bowler',
                          icon: Icons.sports_baseball,
                          value: _bowlerId,
                          players: _availableBowlers,
                          onChanged: (value) =>
                              setState(() => _bowlerId = value),
                        ),
                        if (_availableBatters.length < 2 ||
                            _availableBowlers.isEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _availableBatters.length < 2
                                ? 'Two available batters are required to start the innings.'
                                : 'No available eligible bowler can start the innings.',
                            key: const ValueKey(
                                'second-innings-validation-message'),
                            style: const TextStyle(
                              color: AppColors.wicketRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _ActionFooter(
                  canStart: _hasValidSelection && !_undoing,
                  canUndo: widget.onUndoLastBall != null && !_undoing,
                  undoing: _undoing,
                  onUndo: _undoLastBall,
                  onStart: _startSecondInnings,
                  onEndMatch: () {
                    Navigator.pop(context);
                    widget.onEndMatch();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selector({
    required String key,
    required String label,
    required IconData icon,
    required String? value,
    required List<Player> players,
    required ValueChanged<String?> onChanged,
  }) =>
      KeyedSubtree(
        key: ValueKey(key),
        child: DropdownButtonFormField<String>(
          key: ValueKey('$key-$value'),
          initialValue:
              players.any((player) => player.id == value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDCE4E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDCE4E1)),
            ),
          ),
          items: players
              .map((player) => DropdownMenuItem(
                    value: player.id,
                    child: Text(player.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: players.isEmpty ? null : onChanged,
        ),
      );

  Future<void> _undoLastBall() async {
    final undo = widget.onUndoLastBall;
    if (undo == null || _undoing) return;
    setState(() => _undoing = true);
    final undone = await undo();
    if (!mounted) return;
    if (undone) {
      Navigator.pop(context);
    } else {
      setState(() => _undoing = false);
    }
  }

  void _startSecondInnings() {
    if (!_hasValidSelection) return;
    widget.onStartSecondInnings(_strikerId!, _nonStrikerId!, _bowlerId!);
    Navigator.pop(context);
  }
}

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader();

  @override
  Widget build(BuildContext context) => const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SuccessIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Innings Complete',
                  key: ValueKey('first-innings-complete-title'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Prepare the second innings.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Color(0xFFE3F3EC),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_cricket, color: AppColors.primary),
      );
}

class _InningsSummaryCard extends StatelessWidget {
  const _InningsSummaryCard({
    required this.teamName,
    required this.score,
    required this.overs,
    required this.runRate,
  });

  final String teamName;
  final String score;
  final String overs;
  final double runRate;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('first-innings-summary-card'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDE7E3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(score,
                      style: const TextStyle(
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary)),
                ],
              ),
            ),
            _SummaryMetric(label: 'OVERS', value: overs),
            const SizedBox(width: 18),
            _SummaryMetric(label: 'CRR', value: runRate.toStringAsFixed(2)),
          ],
        ),
      );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      );
}

class _TargetPanel extends StatelessWidget {
  const _TargetPanel({
    required this.target,
    required this.overs,
    required this.requiredRunRate,
  });

  final int target;
  final int overs;
  final double requiredRunRate;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('second-innings-target-panel'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0D48B)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TARGET',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF806313))),
                  const SizedBox(height: 2),
                  Text('$target Runs',
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            _TargetMetric(label: 'OVERS', value: '$overs'),
            const SizedBox(width: 18),
            _TargetMetric(
                label: 'REQUIRED RR',
                value: requiredRunRate.toStringAsFixed(2)),
          ],
        ),
      );
}

class _TargetMetric extends StatelessWidget {
  const _TargetMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF806313))),
          const SizedBox(height: 3),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      );
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({
    required this.canStart,
    required this.canUndo,
    required this.undoing,
    required this.onUndo,
    required this.onStart,
    required this.onEndMatch,
  });

  final bool canStart;
  final bool canUndo;
  final bool undoing;
  final VoidCallback onUndo;
  final VoidCallback onStart;
  final VoidCallback onEndMatch;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('second-innings-sticky-footer'),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8E5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    key: const ValueKey('innings-break-undo-last-ball'),
                    onPressed: canUndo ? onUndo : null,
                    icon: Icons.undo_rounded,
                    label: undoing ? 'Undoing…' : 'Undo Last Ball',
                    compact: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    key: const ValueKey('innings-break-end-match'),
                    label: 'End Match',
                    icon: Icons.stop_circle_outlined,
                    foregroundColor: AppColors.wicketRed,
                    backgroundColor: AppColors.wicketRedLight,
                    onPressed: onEndMatch,
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: AppCtaStyle.height,
              child: FilledButton(
                key: const ValueKey('start-second-innings-button'),
                onPressed: canStart ? onStart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'START SECOND INNINGS',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      );
}
