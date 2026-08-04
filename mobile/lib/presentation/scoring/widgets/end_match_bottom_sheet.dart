import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

class EndMatchSelection {
  final MatchEndOutcome outcome;
  final MatchEndReason reason;
  final String reasonText;
  final String? note;
  final String? forfeitingTeamId;
  final String? winnerTeamId;
  final String? resultType;
  final String? resultText;
  final bool isTie;

  const EndMatchSelection({
    required this.outcome,
    required this.reason,
    required this.reasonText,
    this.note,
    this.forfeitingTeamId,
    this.winnerTeamId,
    this.resultType,
    this.resultText,
    this.isTie = false,
  });
}

class EndMatchBottomSheet extends StatefulWidget {
  final MatchState matchState;
  final Future<bool> Function(EndMatchSelection selection) onConfirm;

  const EndMatchBottomSheet({
    super.key,
    required this.matchState,
    required this.onConfirm,
  });

  @override
  State<EndMatchBottomSheet> createState() => _EndMatchBottomSheetState();
}

class _EndMatchBottomSheetState extends State<EndMatchBottomSheet> {
  MatchEndOutcome? _outcome;
  MatchEndReason? _reason;
  String? _forfeitingTeamId;
  String? _winnerTeamId;
  String? _manualResultType;
  bool _isTie = false;
  bool _reviewing = false;
  bool _saving = false;
  String? _error;
  final _noteController = TextEditingController();
  final _marginController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  String _words(String name) => name
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .trim()
      .split(' ')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  String get _reasonText => _reason == null ? '' : _words(_reason!.name);
  String get _outcomeText => _outcome == null ? '' : _words(_outcome!.name);

  bool _validate() {
    if (_outcome == null) {
      _error = 'Choose a match outcome.';
    } else if (_reason == null) {
      _error = 'Choose why the match is ending.';
    } else if (_reason == MatchEndReason.other &&
        _noteController.text.trim().isEmpty) {
      _error = 'Enter a note for Other.';
    } else if (_outcome == MatchEndOutcome.teamForfeit &&
        (_forfeitingTeamId == null ||
            _winnerTeamId == null ||
            _forfeitingTeamId == _winnerTeamId)) {
      _error = 'Select different forfeiting and winning teams.';
    } else if (_outcome == MatchEndOutcome.manuallyCompleted &&
        !_isTie &&
        _winnerTeamId == null) {
      _error = 'Select a winner or mark the match tied.';
    } else if (_outcome == MatchEndOutcome.manuallyCompleted &&
        (_manualResultType == null || _noteController.text.trim().isEmpty)) {
      _error = 'Choose a result type and provide an explanation.';
    } else {
      _error = null;
      return true;
    }
    setState(() {});
    return false;
  }

  String? _manualResultText() {
    if (_outcome != MatchEndOutcome.manuallyCompleted) return null;
    if (_isTie) return 'Match tied. ${_noteController.text.trim()}';
    final winner = _winnerTeamId == widget.matchState.teamA.id
        ? widget.matchState.teamA.name
        : widget.matchState.teamB.name;
    final margin = _marginController.text.trim();
    return '$winner won${margin.isEmpty ? '' : ' by $margin'}. ${_noteController.text.trim()}';
  }

  EndMatchSelection _selection() => EndMatchSelection(
        outcome: _outcome!,
        reason: _reason!,
        reasonText: _reasonText,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        forfeitingTeamId: _forfeitingTeamId,
        winnerTeamId: _winnerTeamId,
        resultType: _manualResultType,
        resultText: _manualResultText(),
        isTie: _isTie,
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: _reviewing ? _buildReview() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('End this match?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'The current score and scorecard will be saved. Choose why the match is being ended.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MatchEndOutcome>(
            initialValue: _outcome,
            decoration: const InputDecoration(
              labelText: 'Outcome',
              border: OutlineInputBorder(),
            ),
            items: MatchEndOutcome.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(_words(value.name)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _outcome = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MatchEndReason>(
            initialValue: _reason,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
            items: MatchEndReason.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(_words(value.name)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _reason = value),
          ),
          if (_outcome == MatchEndOutcome.teamForfeit) ...[
            const SizedBox(height: 12),
            _teamSelector('Team that forfeited', _forfeitingTeamId,
                (value) => setState(() => _forfeitingTeamId = value)),
            const SizedBox(height: 12),
            _teamSelector('Winning team', _winnerTeamId,
                (value) => setState(() => _winnerTeamId = value)),
          ],
          if (_outcome == MatchEndOutcome.manuallyCompleted) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Match tied'),
              value: _isTie,
              onChanged: (value) => setState(() {
                _isTie = value ?? false;
                if (_isTie) _winnerTeamId = null;
              }),
            ),
            if (!_isTie)
              _teamSelector('Winning team', _winnerTeamId,
                  (value) => setState(() => _winnerTeamId = value)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _manualResultType,
              decoration: const InputDecoration(
                labelText: 'Result type',
                border: OutlineInputBorder(),
              ),
              items: const ['Runs', 'Wickets', 'Tie', 'Local Rule', 'Other']
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _manualResultType = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _marginController,
              decoration: const InputDecoration(
                labelText: 'Winning margin (when applicable)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLength: 240,
            decoration: InputDecoration(
              labelText: _outcome == MatchEndOutcome.manuallyCompleted
                  ? 'Explanation'
                  : 'Note${_reason == MatchEndReason.other ? ' *' : ' (optional)'}',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Scoring'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (_validate()) setState(() => _reviewing = true);
                },
                child: const Text('Continue'),
              ),
            ),
          ]),
        ],
      );

  Widget _teamSelector(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        items: [widget.matchState.teamA, widget.matchState.teamB]
            .map((team) =>
                DropdownMenuItem(value: team.id, child: Text(team.name)))
            .toList(),
        onChanged: onChanged,
      );

  Widget _buildReview() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('End Match',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(
              '${widget.matchState.teamA.name} vs ${widget.matchState.teamB.name}'),
          const SizedBox(height: 16),
          const Text('Current score:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.matchState.innings.map((innings) {
            final team = innings.battingTeamId == widget.matchState.teamA.id
                ? widget.matchState.teamA
                : widget.matchState.teamB;
            return Text(
              '${team.name}: ${innings.totalRuns}/${innings.totalWickets} in ${innings.oversFormatted} overs',
            );
          }),
          const SizedBox(height: 12),
          Text('Outcome: $_outcomeText'),
          Text('Reason: $_reasonText'),
          if (_noteController.text.trim().isNotEmpty)
            Text('Note: ${_noteController.text.trim()}'),
          const SizedBox(height: 12),
          const Text(
            'The match score and delivery history will remain saved.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _saving ? null : () => setState(() => _reviewing = false),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        final saved = await widget.onConfirm(_selection());
                        if (saved && mounted) Navigator.pop(context);
                        if (!saved && mounted) {
                          setState(() {
                            _saving = false;
                            _error = 'Could not save the match outcome.';
                          });
                        }
                      },
                child: Text(_saving ? 'Saving…' : 'Confirm and End Match'),
              ),
            ),
          ]),
        ],
      );
}
