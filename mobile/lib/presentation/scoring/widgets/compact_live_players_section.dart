import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

class CompactLivePlayersSection extends StatelessWidget {
  const CompactLivePlayersSection({
    super.key,
    required this.figures,
    required this.matchState,
    required this.onMorePressed,
    this.onBowlerPressed,
  });

  final LivePlayerFigures figures;
  final MatchState matchState;
  final VoidCallback onMorePressed;
  final VoidCallback? onBowlerPressed;

  Player? _player(String id) {
    for (final player in [
      ...matchState.teamA.players,
      ...matchState.teamB.players,
    ]) {
      if (player.id == id) return player;
    }
    return null;
  }

  String _name(String id, String fallback) {
    final teamId = matchState.teamA.players.any((player) => player.id == id)
        ? matchState.teamA.id
        : matchState.teamB.id;
    return matchState.displayNameFor(teamId, id, fallback);
  }

  @override
  Widget build(BuildContext context) {
    final bowler = figures.bowler;
    final bowlerPlayer = _player(bowler.playerId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _Label('BATTERS')),
            IconButton(
              tooltip: 'More player actions',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 30, height: 24),
              padding: EdgeInsets.zero,
              onPressed: onMorePressed,
              icon:
                  const Icon(Icons.more_horiz, color: Colors.white70, size: 19),
            ),
          ],
        ),
        _BatterLine(
          figures: figures.striker,
          name: _name(figures.striker.playerId, figures.striker.playerName),
        ),
        _BatterLine(
          figures: figures.nonStriker,
          name: _name(
            figures.nonStriker.playerId,
            figures.nonStriker.playerName,
          ),
        ),
        const Divider(height: 8, color: Colors.white24),
        const _Label('CURRENT BOWLER'),
        const SizedBox(height: 2),
        Semantics(
          button: onBowlerPressed != null,
          label:
              '${_name(bowler.playerId, bowler.playerName)}, current bowler, '
              '${bowler.oversDisplay} overs, ${bowler.runsConceded} runs, '
              '${bowler.wickets} wickets.',
          child: InkWell(
            onTap: onBowlerPressed,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_name(bowler.playerId, bowler.playerName)}'
                    '${bowlerPlayer == null ? '' : ' · ${bowlingStyleLabel(bowlerPlayer.bowlingStyle)}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${bowler.oversDisplay} · ${bowler.runsConceded}R · '
                      '${bowler.wickets}W · Eco ${bowler.economy.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          letterSpacing: .8,
          fontWeight: FontWeight.w800,
        ),
      );
}

class _BatterLine extends StatelessWidget {
  const _BatterLine({required this.figures, required this.name});
  final LiveBattingFigures figures;
  final String name;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 25,
        child: Row(
          children: [
            SizedBox(
              width: 17,
              child: figures.isStriker
                  ? const Icon(Icons.star, size: 13, color: Color(0xFFFFD166))
                  : null,
            ),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      figures.isStriker ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${figures.runs} (${figures.ballsFaced}) · SR '
              '${figures.ballsFaced == 0 ? '0.0' : (figures.runs / figures.ballsFaced * 100).toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
}
