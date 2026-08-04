import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../../core/theme.dart';
import '../../core/services/scorecard_pdf_service.dart';
import '../common/widgets/match_awards_section.dart';
import '../scorecard/widgets/responsive_scorecard_tables.dart';
import '../../core/utils/match_datetime_formatter.dart';

class CompletedMatchDetailsScreen extends StatefulWidget {
  final MatchState matchState;

  const CompletedMatchDetailsScreen({
    super.key,
    required this.matchState,
  });

  @override
  State<CompletedMatchDetailsScreen> createState() =>
      _CompletedMatchDetailsScreenState();
}

class _CompletedMatchDetailsScreenState
    extends State<CompletedMatchDetailsScreen> {
  int _selectedInnings = 0;
  MatchState get matchState => widget.matchState;

  @override
  Widget build(BuildContext context) {
    final pagePadding = MediaQuery.sizeOf(context).width < 360 ? 8.0 : 16.0;
    final engine = CricketScoringEngine(matchState);
    final res = matchState.result;
    final timestamp = MatchDateTimeFormatter.summary(matchState);

    final inn1 = matchState.innings.isNotEmpty ? matchState.innings[0] : null;
    final inn2 = matchState.innings.length > 1 ? matchState.innings[1] : null;

    final team1 = inn1 != null
        ? (inn1.battingTeamId == matchState.teamA.id
            ? matchState.teamA
            : matchState.teamB)
        : matchState.teamA;
    final team2 = inn2 != null
        ? (inn2.battingTeamId == matchState.teamA.id
            ? matchState.teamA
            : matchState.teamB)
        : matchState.teamB;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${matchState.teamA.shortName} vs ${matchState.teamB.shortName} Scorecard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Scorecard',
            onPressed: () {
              context.push('/matches/history/${matchState.matchId}/pdf',
                  extra: matchState);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: () async {
              final file = await ScorecardPdfService.savePdfLocally(matchState);
              await Share.shareXFiles([XFile(file.path)],
                  text:
                      '${matchState.teamA.name} vs ${matchState.teamB.name} Scorecard');
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(pagePadding),
        children: [
          // Header Winner Banner Card
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${matchState.teamA.name} vs ${matchState.teamB.name}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (timestamp.hasPersistedMatchTime)
                    Text(
                      '${MatchDateTimeFormatter.date(timestamp.matchDateTime)} · ${MatchDateTimeFormatter.time(timestamp.matchDateTime)} · ${timestamp.timeZoneLabel}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  if (matchState.venueName?.trim().isNotEmpty == true)
                    Text(
                      matchState.venueName!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  const SizedBox(height: 8),
                  if (res != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        res.resultString,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          MatchAwardsSection(
            awards: matchState.awards,
            compact: true,
            matchState: matchState,
          ),
          const SizedBox(height: 16),

          if (inn1 != null && inn2 != null) ...[
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(
                      '${team1.shortName} ${inn1.totalRuns}/${inn1.totalWickets}'),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(
                      '${team2.shortName} ${inn2.totalRuns}/${inn2.totalWickets}'),
                ),
              ],
              selected: {_selectedInnings},
              onSelectionChanged: (selection) =>
                  setState(() => _selectedInnings = selection.first),
            ),
            const SizedBox(height: 12),
          ],
          if (inn1 != null && (_selectedInnings == 0 || inn2 == null))
            _buildInningsCard(
              title: '1st Innings: ${team1.name}',
              innings: inn1,
              team: team1,
              bowlingTeam: matchState.teamA.id == team1.id
                  ? matchState.teamB
                  : matchState.teamA,
              engine: engine,
            ),
          if (inn2 != null && _selectedInnings == 1)
            _buildInningsCard(
              title: '2nd Innings: ${team2.name}',
              innings: inn2,
              team: team2,
              bowlingTeam: matchState.teamA.id == team2.id
                  ? matchState.teamB
                  : matchState.teamA,
              engine: engine,
            ),
          const SizedBox(height: 24),

          // Action Buttons Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('GENERATE & PREVIEW PDF SCORECARD',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        context.push(
                            '/matches/history/${matchState.matchId}/pdf',
                            extra: matchState);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44)),
                    icon: const Icon(Icons.share),
                    label: const Text('SHARE MATCH RESULT TEXT'),
                    onPressed: () {
                      final text =
                          '${matchState.teamA.name} vs ${matchState.teamB.name}\n${res?.resultString ?? ""}\nGenerated by Cricket Scorer App';
                      Share.share(text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInningsCard({
    required String title,
    required InningsState innings,
    required Team team,
    required Team bowlingTeam,
    required CricketScoringEngine engine,
  }) {
    final batters =
        engine.getBatterScorecards(team, inningsId: innings.inningsId);
    final batted = batters.where((batter) => batter.hasBatted).toList();
    final didNotBat = batters.where((batter) => !batter.hasBatted).toList();
    final bowlers = engine.getBowlerScorecards(
      bowlingTeam,
      inningsId: innings.inningsId,
    );
    final events = engine.state.events
        .where((event) => event.inningsId == innings.inningsId)
        .toList();
    final extras = ExtrasSummary(
      wides: events.fold(0, (sum, event) => sum + event.wideRuns),
      noBalls: events.fold(0, (sum, event) => sum + event.noBallRuns),
      byes: events.fold(0, (sum, event) => sum + event.byeRuns),
      legByes: events.fold(0, (sum, event) => sum + event.legByeRuns),
      penalty: events.fold(0, (sum, event) => sum + event.penaltyRuns),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(
                'Score: ${innings.totalRuns}/${innings.totalWickets} in ${innings.oversFormatted} ov${innings.completionReason == 'All Out' ? ' - All Out' : ''} (CRR: ${innings.runRate.toStringAsFixed(2)})',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 20),
            const Text('Batting Scorecard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ResponsiveBattingTable(
              rows: batted,
              didNotBat: didNotBat,
              isCompleted: true,
              displayName: (id, name) => matchState.displayNameFor(
                team.id,
                id,
                name,
              ),
              playerDetail: (id) => battingStyleAbbreviation(
                team.players
                    .firstWhere((player) => player.id == id,
                        orElse: () => Player(id: id, name: ''))
                    .battingStyle,
              ),
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
            const SizedBox(height: 16),
            const Text('Bowling Scorecard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ResponsiveBowlingTable(
              rows: bowlers,
              displayName: (id, name) => matchState.displayNameFor(
                bowlingTeam.id,
                id,
                name,
              ),
              playerDetail: (id) => bowlingStyleLabel(
                bowlingTeam.players
                    .firstWhere((player) => player.id == id,
                        orElse: () => Player(id: id, name: ''))
                    .bowlingStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
