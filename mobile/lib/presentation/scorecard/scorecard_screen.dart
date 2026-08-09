import 'dart:math' as math;

import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'widgets/scorecard_dashboard_widgets.dart';
import 'widgets/responsive_scorecard_tables.dart';
import '../common/widgets/live_match_header.dart';
import '../common/widgets/sports_ui.dart';

class ScorecardScreen extends StatefulWidget {
  final CricketScoringEngine engine;

  const ScorecardScreen({super.key, required this.engine});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final pagePadding = MediaQuery.sizeOf(context).width < 360 ? 8.0 : 16.0;
    final state = engine.state;
    final orderedInnings = [...state.innings]
      ..sort((a, b) => a.inningsNumber.compareTo(b.inningsNumber));
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leaveScorecard(context, state);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _leaveScorecard(context, state),
          ),
          title: Text('${state.teamA.shortName} vs ${state.teamB.shortName}'),
        ),
        body: SelectionArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        color: AppColors.primary,
                        child: ScorecardMatchHeader(matchState: state),
                      ),
                      const SizedBox(height: 12),
                      for (var index = 0;
                          index < orderedInnings.length;
                          index++) ...[
                        _buildInningsSection(
                          engine: engine,
                          state: state,
                          innings: orderedInnings[index],
                          initiallyExpanded: index == orderedInnings.length - 1,
                        ),
                        if (index != orderedInnings.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _leaveScorecard(BuildContext context, MatchState state) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    final terminal = state.status == MatchStatus.completed ||
        state.status == MatchStatus.abandoned ||
        state.status == MatchStatus.cancelled ||
        state.status == MatchStatus.noResult;
    if (terminal) {
      context.go('/matches/history/${state.matchId}');
    } else {
      context.go('/matches/${state.matchId}/scoring', extra: state);
    }
  }

  Widget _buildInningsSection({
    required CricketScoringEngine engine,
    required MatchState state,
    required InningsState innings,
    required bool initiallyExpanded,
  }) {
    final battingTeam =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowlingTeam =
        innings.bowlingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final events = state.events
        .where((event) => event.inningsId == innings.inningsId)
        .toList()
      ..sort((a, b) => a.eventSequence.compareTo(b.eventSequence));
    final allBatters = engine.getBatterScorecards(
      battingTeam,
      inningsId: innings.inningsId,
    );
    final batters = allBatters.where((batter) => batter.hasBatted).toList();
    final waitingBatters =
        allBatters.where((batter) => !batter.hasBatted).toList();
    final participatingBowlerIds = events
        .map((event) => event.bowlerId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final bowlers = engine
        .getBowlerScorecards(bowlingTeam, inningsId: innings.inningsId)
        .where((bowler) => participatingBowlerIds.contains(bowler.playerId))
        .toList();
    final extras = _extras(events);
    final partnership = _partnership(events, state.config.ballsPerOver);
    final wickets = _fallOfWickets(events, battingTeam, state);
    final statistics = _matchStatistics(state, innings);

    return InningsScorecardSection(
      key: ValueKey('innings-scorecard-${innings.inningsId}'),
      teamName: battingTeam.shortName,
      inningsNumber: innings.inningsNumber,
      score: '${innings.totalRuns}/${innings.totalWickets}',
      overs: innings.oversFormatted,
      runRate: innings.runRate,
      initiallyExpanded: initiallyExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Batting',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          AppCard(
            padding: EdgeInsets.zero,
            elevated: false,
            child: Column(children: [
              ResponsiveBattingTable(
                rows: batters,
                didNotBat: waitingBatters,
                isCompleted: innings.isCompleted,
                displayName: (id, name) =>
                    state.displayNameFor(battingTeam.id, id, name),
              ),
              ScorecardSummaryRow(
                label: 'Extras',
                value: '${extras.total}',
                detail:
                    'Wd ${extras.wides} · Nb ${extras.noBalls} · B ${extras.byes} · LB ${extras.legByes}',
              ),
              const Divider(height: 1),
              ScorecardSummaryRow(
                label: 'Total',
                value: '${innings.totalRuns}/${innings.totalWickets}',
                detail:
                    '${innings.oversFormatted} ov · RR ${innings.runRate.toStringAsFixed(2)}',
                emphasized: true,
              ),
            ]),
          ),
          const SizedBox(height: 12),
          if (bowlers.isEmpty)
            const EmptyStateCard(
              icon: Icons.sports_baseball_outlined,
              title: 'No bowler has bowled yet',
              message: 'Bowling figures will appear after the first delivery.',
            )
          else ...[
            const Text('Bowling',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            AppCard(
              padding: EdgeInsets.zero,
              elevated: false,
              child: ResponsiveBowlingTable(
                rows: bowlers,
                displayName: (id, name) =>
                    state.displayNameFor(bowlingTeam.id, id, name),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ResponsiveScoreStatTiles(children: [
            if (events.isEmpty)
              const CompactScoreStatTile(
                title: 'Partnership',
                primaryContent: Text('No active partnership'),
                secondaryContent: Text('Partnership details will appear here.'),
              )
            else
              PartnershipCard(
                runs: partnership.runs,
                balls: partnership.balls,
                boundaries: partnership.boundaries,
                runRate: partnership.runRate,
              ),
            ExtrasCard(
              wides: extras.wides,
              noBalls: extras.noBalls,
              byes: extras.byes,
              legByes: extras.legByes,
              penalty: extras.penalty,
            ),
          ]),
          const SizedBox(height: 12),
          CollapsibleScorecardSection(
            title: 'Fall of wickets',
            count: wickets.length,
            child: FallOfWicketCard(wickets: wickets),
          ),
          const SizedBox(height: 12),
          CollapsibleScorecardSection(
            title: 'Match summary',
            count: statistics.length,
            child: MatchStatisticsCard(statistics: statistics),
          ),
        ],
      ),
    );
  }

  static ExtrasSummary _extras(List<DeliveryEvent> events) => ExtrasSummary(
        wides: events.fold(0, (sum, event) => sum + event.wideRuns),
        noBalls: events.fold(0, (sum, event) => sum + event.noBallRuns),
        byes: events.fold(0, (sum, event) => sum + event.byeRuns),
        legByes: events.fold(0, (sum, event) => sum + event.legByeRuns),
        penalty: events.fold(0, (sum, event) => sum + event.penaltyRuns),
      );

  static _PartnershipView _partnership(
    List<DeliveryEvent> events,
    int ballsPerOver,
  ) {
    var lastWicketIndex = -1;
    for (var index = 0; index < events.length; index++) {
      final wicket = events[index].wicket;
      if (wicket != null && WicketHandler.countsAsTeamWicket(wicket.type)) {
        lastWicketIndex = index;
      }
    }
    final partnershipEvents = events.skip(lastWicketIndex + 1);
    final runs = partnershipEvents.fold<int>(
      0,
      (sum, event) => sum + event.totalRuns,
    );
    final balls = partnershipEvents.where((event) => event.isLegal).length;
    final boundaries = partnershipEvents
        .where((event) => event.isBoundaryFour || event.isBoundarySix)
        .length;
    final runRate = balls == 0 ? 0.0 : runs / (balls / ballsPerOver);
    return _PartnershipView(runs, balls, boundaries, runRate);
  }

  static List<FallOfWicketEntry> _fallOfWickets(
    List<DeliveryEvent> events,
    Team battingTeam,
    MatchState state,
  ) {
    var cumulativeRuns = 0;
    var wicketNumber = 0;
    final result = <FallOfWicketEntry>[];
    for (final event in events) {
      cumulativeRuns += event.totalRuns;
      final wicket = event.wicket;
      if (wicket == null || !WicketHandler.countsAsTeamWicket(wicket.type)) {
        continue;
      }
      wicketNumber++;
      final player = battingTeam.players
          .where((candidate) => candidate.id == wicket.dismissedPlayerId);
      result.add(FallOfWicketEntry(
        score: '$wicketNumber-$cumulativeRuns',
        batter: player.isEmpty
            ? 'Batter'
            : state.displayNameFor(
                battingTeam.id,
                player.first.id,
                player.first.name,
              ),
        over: event.ballReference,
      ));
    }
    return result;
  }

  static double? _requiredRunRate(MatchState state, InningsState innings) {
    if (innings.targetRuns == null) return null;
    final ballsRemaining = math.max(
      0,
      state.config.totalOvers * state.config.ballsPerOver -
          innings.legalBallsBowled,
    );
    final runsNeeded = math.max(0, innings.targetRuns! - innings.totalRuns);
    if (ballsRemaining == 0 || runsNeeded == 0) return 0;
    return runsNeeded / (ballsRemaining / state.config.ballsPerOver);
  }

  static List<StatisticData> _matchStatistics(
    MatchState state,
    InningsState innings,
  ) {
    final ballsRemaining = math.max(
      0,
      state.config.totalOvers * state.config.ballsPerOver -
          innings.legalBallsBowled,
    );
    final isTerminal = state.status == MatchStatus.completed ||
        state.status == MatchStatus.abandoned ||
        state.status == MatchStatus.cancelled ||
        state.status == MatchStatus.noResult;
    if (isTerminal) {
      return [
        StatisticData('Innings', '${innings.inningsNumber}'),
        StatisticData(
            'Final score', '${innings.totalRuns}/${innings.totalWickets}'),
        StatisticData('Overs', innings.oversFormatted),
        if (innings.targetRuns != null)
          StatisticData('Target', '${innings.targetRuns}',
              color: AppColors.accent),
      ];
    }
    if (innings.targetRuns != null) {
      final need = math.max(0, innings.targetRuns! - innings.totalRuns);
      return [
        StatisticData('Target', '${innings.targetRuns}',
            color: AppColors.accent),
        StatisticData('Need', pluralizeScore(need, 'run', 'runs')),
        StatisticData('Balls remaining', '$ballsRemaining'),
        StatisticData(
          'Required run rate',
          (_requiredRunRate(state, innings) ?? 0).toStringAsFixed(2),
        ),
      ];
    }
    return [
      StatisticData('Innings', '${innings.inningsNumber}'),
      StatisticData('Overs limit', '${state.config.totalOvers}'),
      StatisticData('Maximum wickets', '${innings.maximumWickets}'),
      StatisticData('Balls remaining', '$ballsRemaining'),
    ];
  }
}

class InningsScorecardSection extends StatelessWidget {
  const InningsScorecardSection({
    super.key,
    required this.teamName,
    required this.inningsNumber,
    required this.score,
    required this.overs,
    required this.runRate,
    required this.initiallyExpanded,
    required this.child,
  });

  final String teamName;
  final int inningsNumber;
  final String score;
  final String overs;
  final double runRate;
  final bool initiallyExpanded;
  final Widget child;

  String get _inningsLabel => switch (inningsNumber) {
        1 => '1st Innings',
        2 => '2nd Innings',
        3 => '3rd Innings',
        _ => '${inningsNumber}th Innings',
      };

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        elevated: false,
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            key: PageStorageKey<String>('innings-$inningsNumber'),
            initiallyExpanded: initiallyExpanded,
            maintainState: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '$_inningsLabel · $overs overs · CRR ${runRate.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
            children: [child],
          ),
        ),
      );
}

class _PartnershipView {
  final int runs;
  final int balls;
  final int boundaries;
  final double runRate;

  const _PartnershipView(this.runs, this.balls, this.boundaries, this.runRate);
}
