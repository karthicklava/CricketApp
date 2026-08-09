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

enum LiveMatchCardVariant {
  homeFeatured,
  historyCompact,
  scorecardHeader,
  liveScoreHeader,
  liveScoringCompact,
}

enum MatchConnectionState { online, savedOffline }

class LiveMatchSummaryCard extends StatelessWidget {
  const LiveMatchSummaryCard({
    super.key,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.inningsNumber,
    required this.score,
    required this.overs,
    required this.totalOvers,
    required this.currentRunRate,
    required this.variant,
    this.requiredRunRate,
    this.target,
    this.runsRequired,
    this.ballsRemaining,
    this.connectionState = MatchConnectionState.online,
    this.isCompleted = false,
    this.resultText,
    this.darkSurface = true,
    this.onResume,
  });

  factory LiveMatchSummaryCard.fromMatchState(
    MatchState state, {
    Key? key,
    required LiveMatchCardVariant variant,
    MatchConnectionState connectionState = MatchConnectionState.online,
    bool darkSurface = true,
    VoidCallback? onResume,
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
    final rawRunsRequired = innings.targetRuns == null
        ? null
        : innings.targetRuns! - innings.totalRuns;
    final runsRequired = rawRunsRequired == null
        ? null
        : rawRunsRequired < 0
            ? 0
            : rawRunsRequired;
    final crr = innings.legalBallsBowled == 0
        ? 0.0
        : innings.totalRuns / (innings.legalBallsBowled / ballsPerOver);
    final rrr = innings.targetRuns == null
        ? null
        : safeBallsRemaining == 0 || runsRequired == 0
            ? 0.0
            : runsRequired! / (safeBallsRemaining / ballsPerOver);
    final terminal = state.status == MatchStatus.completed ||
        state.status == MatchStatus.abandoned ||
        state.status == MatchStatus.cancelled ||
        state.status == MatchStatus.noResult;
    return LiveMatchSummaryCard(
      key: key,
      battingTeamName: batting.shortName,
      bowlingTeamName: bowling.shortName,
      inningsNumber: innings.inningsNumber,
      score: '${innings.totalRuns}/${innings.totalWickets}',
      overs: innings.oversFormatted,
      totalOvers: state.config.totalOvers,
      currentRunRate: crr,
      requiredRunRate: rrr,
      target: innings.targetRuns,
      runsRequired: runsRequired,
      ballsRemaining: innings.targetRuns == null ? null : safeBallsRemaining,
      variant: variant,
      connectionState: connectionState,
      isCompleted: terminal,
      resultText: state.manualResultText ?? state.result?.resultString,
      darkSurface: darkSurface,
      onResume: terminal ? null : onResume,
    );
  }

  final String battingTeamName;
  final String bowlingTeamName;
  final int inningsNumber;
  final String score;
  final String overs;
  final int totalOvers;
  final double currentRunRate;
  final double? requiredRunRate;
  final int? target;
  final int? runsRequired;
  final int? ballsRemaining;
  final LiveMatchCardVariant variant;
  final MatchConnectionState connectionState;
  final bool isCompleted;
  final String? resultText;
  final bool darkSurface;
  final VoidCallback? onResume;

  bool get _compact =>
      variant == LiveMatchCardVariant.historyCompact ||
      variant == LiveMatchCardVariant.liveScoringCompact;
  String get _inningsLabel => switch (inningsNumber) {
        1 => '1st Innings',
        2 => '2nd Innings',
        3 => '3rd Innings',
        _ => '${inningsNumber}th Innings',
      };

  @override
  Widget build(BuildContext context) {
    final primary = darkSurface ? Colors.white : AppColors.textPrimary;
    final secondary = darkSurface ? Colors.white70 : AppColors.textSecondary;
    final accent = darkSurface ? AppColors.accent : AppColors.primary;
    final chase = !isCompleted && target != null;
    final semantics = isCompleted
        ? '$battingTeamName versus $bowlingTeamName. Match completed. Score $score after $overs overs. ${resultText ?? ''}'
        : 'Live match. $battingTeamName batting against $bowlingTeamName. $_inningsLabel. Score $score. $overs overs of $totalOvers. '
            '${chase ? 'Target $target. Need $runsRequired runs from $ballsRemaining balls. ' : ''}'
            'Current run rate ${currentRunRate.toStringAsFixed(2)}.'
            '${requiredRunRate == null ? '' : ' Required run rate ${requiredRunRate!.toStringAsFixed(2)}.'}';
    return Semantics(
      container: true,
      label: semantics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCompleted)
            Text('COMPLETED',
                style: TextStyle(
                    color: secondary,
                    fontSize: 11,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w900))
          else
            Row(
              key: const ValueKey('live-summary-header-row'),
              children: [
                const LiveMatchStatusBadge(),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    key: const ValueKey('live-summary-header-meta'),
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _inningsLabel,
                            maxLines: 1,
                            style: TextStyle(
                              color: primary,
                              fontSize: _compact ? 11 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            connectionState == MatchConnectionState.online
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                            size: 15,
                            color: secondary,
                          ),
                          if (connectionState ==
                              MatchConnectionState.savedOffline) ...[
                            const SizedBox(width: 4),
                            Text(
                              'Saved offline',
                              style: TextStyle(color: secondary, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: _compact ? 8 : 10),
          Text(isCompleted ? battingTeamName : '$battingTeamName batting',
              key: const ValueKey('live-summary-batting-team'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: primary,
                  fontSize: _compact ? 14 : 17,
                  fontWeight: FontWeight.w800)),
          Text('vs $bowlingTeamName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondary, fontSize: 12)),
          SizedBox(height: _compact ? 7 : 10),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: FittedBox(
                    key: ValueKey('live-summary-score-$score'),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(score,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: primary,
                            fontSize: _compact ? 27 : 42,
                            height: 1,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text('$overs / $totalOvers overs',
                    key: const ValueKey('live-summary-overs'),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: primary,
                        fontSize: _compact ? 12 : 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
          if (isCompleted) ...[
            const SizedBox(height: 10),
            Text(resultText ?? 'Match completed',
                style: TextStyle(
                    color: accent,
                    fontSize: _compact ? 14 : 17,
                    fontWeight: FontWeight.w900)),
          ] else ...[
            if (chase) ...[
              SizedBox(height: _compact ? 7 : 10),
              Text(
                'Need ${pluralizeScore(runsRequired!, 'run', 'runs')} from ${pluralizeScore(ballsRemaining!, 'ball', 'balls')}',
                style: TextStyle(
                    color: accent,
                    fontSize: _compact ? 12 : 14,
                    fontWeight: FontWeight.w800),
              ),
              if (!_compact)
                Text('Target $target',
                    style: TextStyle(color: secondary, fontSize: 11)),
            ],
            SizedBox(height: _compact ? 6 : 9),
            Row(children: [
              Expanded(
                  child: Text('CRR ${currentRunRate.toStringAsFixed(2)}',
                      key: const ValueKey('live-summary-crr'),
                      style: TextStyle(
                          color: secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700))),
              if (chase)
                Expanded(
                    child: Text('RRR ${requiredRunRate!.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700))),
            ]),
          ],
          if (onResume != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: AppCtaStyle.height,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary),
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded, size: 19),
                label: const Text('Resume Match'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LiveMatchStatusBadge extends StatefulWidget {
  const LiveMatchStatusBadge({super.key});

  @override
  State<LiveMatchStatusBadge> createState() => _LiveMatchStatusBadgeState();
}

class _LiveMatchStatusBadgeState extends State<LiveMatchStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _opacity =
      Tween<double>(begin: .45, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Live match',
        child: Container(
          key: const ValueKey('live-match-status-badge'),
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE MATCH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: .45,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}

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

  @override
  Widget build(BuildContext context) => LiveMatchSummaryCard(
        battingTeamName: battingTeam.shortName,
        bowlingTeamName: bowlingTeam.shortName,
        inningsNumber: inningsNumber,
        score: currentScore,
        overs: overs,
        totalOvers: totalOvers,
        currentRunRate: crr,
        requiredRunRate: rrr,
        target: target,
        runsRequired: runsNeeded,
        ballsRemaining: ballsRemaining,
        variant: compact
            ? LiveMatchCardVariant.historyCompact
            : LiveMatchCardVariant.scorecardHeader,
        darkSurface: darkSurface,
      );
}
