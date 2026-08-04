import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

enum LatePlayerSource { existing, create }

class LatePlayerSelection {
  final LatePlayerSource source;
  final String? existingPlayerId;
  final String name;
  final String? jerseyNumber;
  final String role;
  final BattingStyle battingStyle;
  final BowlingStyle bowlingStyle;
  final bool isEligibleBowler;
  final bool isWicketKeeper;
  final bool addPermanently;

  const LatePlayerSelection({
    required this.source,
    this.existingPlayerId,
    required this.name,
    this.jerseyNumber,
    required this.role,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.isEligibleBowler,
    required this.isWicketKeeper,
    required this.addPermanently,
  });
}

class ExistingPlayerOption {
  final String id;
  final String name;
  final String? jerseyNumber;
  final String role;
  final BattingStyle battingStyle;
  final BowlingStyle bowlingStyle;
  final bool isWicketKeeper;

  const ExistingPlayerOption({
    required this.id,
    required this.name,
    this.jerseyNumber,
    required this.role,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.isWicketKeeper,
  });
}

class LatePlayerBottomSheet extends StatefulWidget {
  final Team team;
  final bool isBattingTeam;
  final List<ExistingPlayerOption> existingPlayers;
  final bool allowPermanentAddition;

  const LatePlayerBottomSheet({
    super.key,
    required this.team,
    required this.isBattingTeam,
    required this.existingPlayers,
    required this.allowPermanentAddition,
  });

  @override
  State<LatePlayerBottomSheet> createState() => _LatePlayerBottomSheetState();
}

class _LatePlayerBottomSheetState extends State<LatePlayerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _jersey = TextEditingController();
  LatePlayerSource _source = LatePlayerSource.existing;
  ExistingPlayerOption? _existing;
  String _role = 'allRounder';
  bool _eligibleBowler = true;
  bool _wicketKeeper = false;
  bool _permanent = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlayers.isEmpty) _source = LatePlayerSource.create;
    _permanent = widget.allowPermanentAddition;
  }

  @override
  void dispose() {
    _name.dispose();
    _jersey.dispose();
    super.dispose();
  }

  void _submit() {
    if (_source == LatePlayerSource.existing) {
      if (_existing == null) return;
      Navigator.pop(
        context,
        LatePlayerSelection(
          source: _source,
          existingPlayerId: _existing!.id,
          name: _existing!.name,
          jerseyNumber: _existing!.jerseyNumber,
          role: _existing!.role,
          battingStyle: _existing!.battingStyle,
          bowlingStyle: _existing!.bowlingStyle,
          isEligibleBowler:
              _existing!.bowlingStyle != BowlingStyle.none,
          isWicketKeeper: _existing!.isWicketKeeper,
          addPermanently: true,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      LatePlayerSelection(
        source: _source,
        name: _name.text.trim(),
        jerseyNumber:
            _jersey.text.trim().isEmpty ? null : _jersey.text.trim(),
        role: _role,
        battingStyle: BattingStyle.rightHand,
        bowlingStyle:
            _eligibleBowler ? BowlingStyle.rightArmFast : BowlingStyle.none,
        isEligibleBowler: _eligibleBowler,
        isWicketKeeper: _wicketKeeper,
        addPermanently: _permanent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Player to ${widget.team.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(widget.isBattingTeam ? 'Batting team' : 'Bowling team'),
                  const SizedBox(height: 12),
                  SegmentedButton<LatePlayerSource>(
                    segments: const [
                      ButtonSegment(
                        value: LatePlayerSource.existing,
                        label: Text('Existing'),
                        icon: Icon(Icons.person_search),
                      ),
                      ButtonSegment(
                        value: LatePlayerSource.create,
                        label: Text('Create New'),
                        icon: Icon(Icons.person_add),
                      ),
                    ],
                    selected: {_source},
                    onSelectionChanged: (value) =>
                        setState(() => _source = value.first),
                  ),
                  const SizedBox(height: 16),
                  if (_source == LatePlayerSource.existing)
                    DropdownButtonFormField<ExistingPlayerOption>(
                      initialValue: _existing,
                      decoration:
                          const InputDecoration(labelText: 'Select player'),
                      items: widget.existingPlayers
                          .map((player) => DropdownMenuItem(
                                value: player,
                                child: Text(player.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _existing = value),
                    )
                  else ...[
                    TextFormField(
                      controller: _name,
                      autofocus: true,
                      decoration:
                          const InputDecoration(labelText: 'Player name *'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter a player name.'
                          : null,
                    ),
                    TextFormField(
                      controller: _jersey,
                      decoration:
                          const InputDecoration(labelText: 'Jersey number'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(
                            value: 'batter', child: Text('Batter')),
                        DropdownMenuItem(
                            value: 'bowler', child: Text('Bowler')),
                        DropdownMenuItem(
                            value: 'allRounder', child: Text('All-rounder')),
                        DropdownMenuItem(
                            value: 'wicketKeeper',
                            child: Text('Wicketkeeper')),
                      ],
                      onChanged: (value) =>
                          setState(() => _role = value ?? 'allRounder'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _eligibleBowler,
                      title: const Text('Eligible bowler'),
                      onChanged: (value) =>
                          setState(() => _eligibleBowler = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _wicketKeeper,
                      title: const Text('Wicketkeeper'),
                      onChanged: (value) =>
                          setState(() => _wicketKeeper = value),
                    ),
                    if (widget.allowPermanentAddition)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _permanent,
                        title: const Text('Add to team permanently'),
                        onChanged: (value) =>
                            setState(() => _permanent = value),
                      ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Add Player'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
