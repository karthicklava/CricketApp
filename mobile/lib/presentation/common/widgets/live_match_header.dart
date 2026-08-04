import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

enum ScorecardHeaderState {
  liveFirstInnings,
  liveChase,
  completed,
  tied,
  abandoned,
  cancelled,
  noResult,
}

String pluralizeScore(int value, String singular, String plural) =>
    '$value ${value == 1 ? singular : plural}';

class ScorecardMatchHeader extends StatelessWidget {
  const ScorecardMatchHeader({super.key, required this.matchState});

  final MatchState matchState;

  ScorecardHeaderState get headerState {
    if (matchState.status == MatchStatus.abandoned) {
      return ScorecardHeaderState.abandoned;
    }
    if (matchState.status == MatchStatus.cancelled) {
      return ScorecardHeaderState.cancelled;
    }
    if (matchState.status == MatchStatus.noResult) {
      return ScorecardHeaderState.noResult;
    }
    if (matchState.status == MatchStatus.completed) {
      return matchState.result?.isTie == true
          ? ScorecardHeaderState.tied
          : ScorecardHeaderState.completed;
    }
    return matchState.activeInnings.targetRuns == null
        ? ScorecardHeaderState.liveFirstInnings
        : ScorecardHeaderState.liveChase;
  }

  bool get _isTerminal => switch (headerState) {
        ScorecardHeaderState.completed ||
        ScorecardHeaderState.tied ||
        ScorecardHeaderState.abandoned ||
        ScorecardHeaderState.cancelled ||
        ScorecardHeaderState.noResult =>
          true,
        _ => false,
      };

  String get _statusLabel => switch (headerState) {
        ScorecardHeaderState.completed ||
        ScorecardHeaderState.tied =>
          'COMPLETED',
        ScorecardHeaderState.abandoned => 'ABANDONED',
        ScorecardHeaderState.cancelled => 'CANCELLED',
        ScorecardHeaderState.noResult => 'NO RESULT',
        _ => 'LIVE',
      };

  String get _resultText =>
      matchState.manualResultText ??
      matchState.result?.resultString ??
      switch (headerState) {
        ScorecardHeaderState.abandoned =>
          'Match abandoned${matchState.endReasonText == null ? '' : ' — ${matchState.endReasonText}'}',
        ScorecardHeaderState.cancelled => 'Match cancelled',
        ScorecardHeaderState.noResult => 'No result',
        ScorecardHeaderState.tied => 'Match tied',
        _ => 'Match completed',
      };

  String _inningsLabel(int number) => switch (number) {
        1 => '1st Innings',
        2 => '2nd Innings',
        3 => '3rd Innings',
        _ => '${number}th Innings',
      };

  @override
  Widget build(BuildContext context) {
    if (!_isTerminal) {
      return LiveMatchHeader.fromMatchState(
        matchState,
        darkSurface: true,
      );
    }

    final innings = matchState.activeInnings;
    final battingTeam = innings.battingTeamId == matchState.teamA.id
        ? matchState.teamA
        : matchState.teamB;
    return Semantics(
      label:
          '${matchState.teamA.name} versus ${matchState.teamB.name}, $_statusLabel, ${battingTeam.name}, ${_inningsLabel(innings.inningsNumber)}, ${innings.totalRuns} for ${innings.totalWickets}, $_resultText',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  '${matchState.teamA.shortName} vs ${matchState.teamB.shortName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Text(
              '${battingTeam.shortName} · ${_inningsLabel(innings.inningsNumber)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${innings.totalRuns}/${innings.totalWickets}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${innings.oversFormatted} overs',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _resultText,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (innings.targetRuns != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target ${innings.targetRuns}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent active-innings identity for every live-match surface.
class LiveMatchHeader extends StatelessWidget {
  const LiveMatchHeader({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.inningsNumber,
    required this.currentScore,
    required this.overs,
    required this.totalOvers,
    required this.crr,
    this.target,
    this.rrr,
    this.runsNeeded,
    this.ballsRemaining,
    this.darkSurface = false,
    this.compact = false,
    this.trailing,
  });

  factory LiveMatchHeader.fromMatchState(
    MatchState state, {
    Key? key,
    bool darkSurface = false,
    bool compact = false,
    Widget? trailing,
  }) {
    final innings = state.activeInnings;
    final batting =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowling =
        innings.bowlingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final ballsPerOver = state.config.ballsPerOver;
    final ballsRemaining =
        state.config.totalOvers * ballsPerOver - innings.legalBallsBowled;
    final safeBallsRemaining = ballsRemaining < 0 ? 0 : ballsRemaining;
    final runsNeeded = innings.targetRuns == null
        ? null
        : innings.targetRuns! - innings.totalRuns;
    final safeRunsNeeded =
        runsNeeded == null || runsNeeded < 0 ? 0 : runsNeeded;
    final crr = innings.legalBallsBowled == 0
        ? 0.0
        : innings.totalRuns / (innings.legalBallsBowled / ballsPerOver);
    final rrr = innings.targetRuns == null
        ? null
        : safeBallsRemaining == 0 || safeRunsNeeded == 0
            ? 0.0
            : safeRunsNeeded / (safeBallsRemaining / ballsPerOver);
    return LiveMatchHeader(
      key: key,
      teamA: state.teamA,
      teamB: state.teamB,
      battingTeam: batting,
      bowlingTeam: bowling,
      inningsNumber: innings.inningsNumber,
      currentScore: '${innings.totalRuns}/${innings.totalWickets}',
      overs:
          '${innings.legalBallsBowled ~/ ballsPerOver}.${innings.legalBallsBowled % ballsPerOver}',
      totalOvers: state.config.totalOvers,
      target: innings.targetRuns,
      crr: crr,
      rrr: rrr,
      runsNeeded: innings.targetRuns == null ? null : safeRunsNeeded,
      ballsRemaining: innings.targetRuns == null ? null : safeBallsRemaining,
      darkSurface: darkSurface,
      compact: compact,
      trailing: trailing,
    );
  }

  final Team teamA;
  final Team teamB;
  final Team battingTeam;
  final Team bowlingTeam;
  final int inningsNumber;
  final String currentScore;
  final String overs;
  final int totalOvers;
  final int? target;
  final double crr;
  final double? rrr;
  final int? runsNeeded;
  final int? ballsRemaining;
  final bool darkSurface;
  final bool compact;
  final Widget? trailing;

  String get _inningsLabel => inningsNumber == 1
      ? '1st Innings'
      : inningsNumber == 2
          ? '2nd Innings'
          : inningsNumber == 3
              ? '3rd Innings'
              : '${inningsNumber}th Innings';

  @override
  Widget build(BuildContext context) {
    final primaryText = darkSurface ? Colors.white : AppColors.textPrimary;
    final secondaryText =
        darkSurface ? Colors.white70 : AppColors.textSecondary;
    final accent = darkSurface ? AppColors.accent : AppColors.primary;
    return Semantics(
      label:
          '${battingTeam.name} batting against ${bowlingTeam.name}, $_inningsLabel, $currentScore after $overs overs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.sports_cricket_rounded,
                color: accent, size: compact ? 18 : 22),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${battingTeam.shortName} Batting',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: primaryText,
                          fontSize: compact ? 15 : 18,
                          fontWeight: FontWeight.w900)),
                  Text('vs ${bowlingTeam.shortName} · Bowling',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: secondaryText,
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w600)),
                ])),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ]),
          SizedBox(height: compact ? 7 : 10),
          Wrap(
            spacing: 16,
            runSpacing: 5,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(currentScore,
                  style: TextStyle(
                      color: primaryText,
                      fontSize: compact ? 25 : 40,
                      height: 1,
                      fontWeight: FontWeight.w900)),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_inningsLabel,
                    style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Overs $overs / $totalOvers',
                    style: TextStyle(
                        color: primaryText,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w700)),
              ]),
            ],
          ),
          SizedBox(height: compact ? 4 : 7),
          Text(
              'CRR ${crr.toStringAsFixed(2)}${rrr == null ? '' : ' · RRR ${rrr!.toStringAsFixed(2)}'}',
              style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          if (target != null) ...[
            const SizedBox(height: 4),
            Text(
                'Target $target · Need ${pluralizeScore(runsNeeded!, 'run', 'runs')} from ${pluralizeScore(ballsRemaining!, 'ball', 'balls')}',
                style: TextStyle(
                    color: accent, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}
