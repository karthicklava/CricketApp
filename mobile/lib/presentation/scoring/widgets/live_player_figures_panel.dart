import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class LivePlayerFiguresPanel extends StatelessWidget {
  final LivePlayerFigures figures;
  final VoidCallback onMorePressed;
  final VoidCallback? onBowlerPressed;
  final MatchState? matchState;

  const LivePlayerFiguresPanel({
    super.key,
    required this.figures,
    required this.onMorePressed,
    this.onBowlerPressed,
    this.matchState,
  });

  String _displayName(String playerId, String playerName) {
    final state = matchState;
    if (state == null) return playerName;
    final teamId = state.teamA.players.any((player) => player.id == playerId)
        ? state.teamA.id
        : state.teamB.id;
    return state.displayNameFor(teamId, playerId, playerName);
  }

  Player? _player(String playerId) {
    final state = matchState;
    if (state == null) return null;
    for (final player in [...state.teamA.players, ...state.teamB.players]) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Card(
        key: const ValueKey('live-players-card'),
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports_cricket,
                      color: AppColors.primary, size: 19),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('Live Match Info',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints.tightFor(width: 30, height: 24),
                    padding: EdgeInsets.zero,
                    tooltip: 'More player actions',
                    onPressed: onMorePressed,
                    icon: const Icon(Icons.more_horiz, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text('BATTERS',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 1),
              _BatterRow(
                figures: figures.striker,
                battingDetail: battingStyleAbbreviation(
                  _player(figures.striker.playerId)?.battingStyle ??
                      BattingStyle.notSet,
                ),
                displayName: _displayName(
                  figures.striker.playerId,
                  figures.striker.playerName,
                ),
              ),
              _BatterRow(
                figures: figures.nonStriker,
                battingDetail: battingStyleAbbreviation(
                  _player(figures.nonStriker.playerId)?.battingStyle ??
                      BattingStyle.notSet,
                ),
                displayName: _displayName(
                  figures.nonStriker.playerId,
                  figures.nonStriker.playerName,
                ),
              ),
              const Divider(height: 8),
              const Text('CURRENT BOWLER',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 3),
              Semantics(
                label: onBowlerPressed == null
                    ? _bowlerSemantics(
                        figures.bowler,
                        _displayName(
                          figures.bowler.playerId,
                          figures.bowler.playerName,
                        ),
                      )
                    : '${_bowlerSemantics(
                        figures.bowler,
                        _displayName(
                          figures.bowler.playerId,
                          figures.bowler.playerName,
                        ),
                      )} Tap to replace the current bowler.',
                button: onBowlerPressed != null,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onBowlerPressed,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName(
                                figures.bowler.playerId,
                                figures.bowler.playerName,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _player(figures.bowler.playerId) == null
                                  ? 'Eco ${figures.bowler.economy.toStringAsFixed(2)}'
                                  : '${bowlingStyleLabel(_player(figures.bowler.playerId)!.bowlingStyle)} · Eco ${figures.bowler.economy.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${figures.bowler.oversDisplay}–${figures.bowler.maidens}–${figures.bowler.runsConceded}–${figures.bowler.wickets}',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  static String _bowlerSemantics(
      LiveBowlingFigures bowler, String displayName) {
    final overs = bowler.legalBalls ~/ bowler.ballsPerOver;
    final balls = bowler.legalBalls % bowler.ballsPerOver;
    return '$displayName, current bowler, $overs overs and $balls '
        'balls, ${bowler.maidens} maidens, ${bowler.runsConceded} runs '
        'conceded, ${bowler.wickets} wickets, economy '
        '${bowler.economy.toStringAsFixed(2)}.';
  }
}

class _BatterRow extends StatelessWidget {
  final LiveBattingFigures figures;
  final String displayName;
  final String battingDetail;

  const _BatterRow({
    required this.figures,
    required this.displayName,
    required this.battingDetail,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        label:
            '$displayName, ${battingDetail == 'Not Set' ? '' : '$battingDetail, '}${figures.isStriker ? 'striker' : 'non-striker'}, '
            '${figures.runs} runs from ${figures.ballsFaced} balls.',
        excludeSemantics: true,
        child: SizedBox(
          height: 32,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$displayName${figures.isStriker ? '*' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        figures.isStriker ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (battingDetail != 'Not Set') ...[
                const SizedBox(width: 6),
                Text(battingDetail,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
              const SizedBox(width: 8),
              Text(
                'SR ${figures.ballsFaced == 0 ? '0.0' : (figures.runs / figures.ballsFaced * 100).toStringAsFixed(1)}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 10),
              Text(
                '${figures.runs} (${figures.ballsFaced})',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      );
}
