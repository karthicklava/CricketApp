import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../utils/match_datetime_formatter.dart';

class ScorecardPdfService {
  /// Generates a professional multi-page A4 PDF scorecard 100% offline
  static Future<Uint8List> generatePdf(MatchState matchState,
      {String? scorerFooterInfo, DateTime? generatedAt}) async {
    _validateScorecard(matchState);
    final pdf = pw.Document();
    final engine = CricketScoringEngine(matchState);
    final timestamp = MatchDateTimeFormatter.summary(
      matchState,
      generatedAt: generatedAt,
    );
    final timestampLines = MatchDateTimeFormatter.pdfLines(
      matchState,
      timestamp,
    );
    pw.MemoryImage? brandLogo;
    try {
      final data =
          await rootBundle.load('assets/branding/cricket_scorer_mark.png');
      brandLogo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      // PDF generation remains available in isolated tests and recovery flows.
    }

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (brandLogo != null)
                  pw.Image(brandLogo, width: 28, height: 28),
                pw.Text(
                  'TurfScore | Match ID: ${matchState.matchId}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          final footerText = scorerFooterInfo != null &&
                  scorerFooterInfo.isNotEmpty
              ? 'Page ${context.pageNumber} of ${context.pagesCount} | $scorerFooterInfo | Generated on ${MatchDateTimeFormatter.date(timestamp.generatedDateTime)} at ${MatchDateTimeFormatter.time(timestamp.generatedDateTime)}'
              : 'Page ${context.pageNumber} of ${context.pagesCount} | Generated on ${MatchDateTimeFormatter.date(timestamp.generatedDateTime)} at ${MatchDateTimeFormatter.time(timestamp.generatedDateTime)} | Offline';

          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              footerText,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Header Title Card
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green800,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${matchState.teamA.name} vs ${matchState.teamB.name}',
                    style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Format: ${matchState.config.totalOvers} Overs | Match Status: ${matchState.status.name.toUpperCase()}',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 7),
                  ...timestampLines.map(
                    (line) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Text(
                        line,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  if (matchState.result != null) ...[
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                          color: PdfColors.orange800,
                          borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Text(
                        matchState.result!.resultString,
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white),
                      ),
                    ),
                  ],
                  if (matchState.endedManually) ...[
                    pw.SizedBox(height: 10),
                    pw.Text(
                      (matchState.manualResultText ?? 'Match ended manually')
                          .toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      'Reason: ${matchState.endReasonText ?? 'Not specified'}',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.white),
                    ),
                    if (matchState.endNote?.isNotEmpty == true)
                      pw.Text(
                        'Note: ${matchState.endNote}',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.white),
                      ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('MATCH SQUADS',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800)),
            pw.SizedBox(height: 5),
            for (final team in [matchState.teamA, matchState.teamB])
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  '${team.name}: ${team.players.map((player) => matchState.displayNameFor(team.id, player.id, player.name)).join(', ')}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            pw.Text(
              'C - Captain    WK - Wicketkeeper',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
            if (matchState.awards.isNotEmpty) ...[
              pw.Text(
                'MATCH AWARDS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: matchState.awards
                    .map((award) => pw.Expanded(
                          child: pw.Container(
                            margin: const pw.EdgeInsets.only(right: 8),
                            padding: const pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  award.type == MatchAwardType.bestBatter
                                      ? 'BEST BATTER'
                                      : 'BEST BOWLER',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green800,
                                  ),
                                ),
                                pw.Text(
                                  '${matchState.displayNameFor(award.teamId, award.playerId, award.playerNameSnapshot)} - ${award.teamNameSnapshot}',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(award.summary),
                                if (award.secondarySummary.isNotEmpty)
                                  pw.Text(
                                    award.secondarySummary,
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                if (award.isManualOverride)
                                  pw.Text(
                                    'Selected manually',
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Innings 1 Scorecard
            if (inn1 != null) ...[
              _buildInningsPdfSection(
                title: '1st Innings: ${team1.name}',
                innings: inn1,
                team: team1,
                bowlingTeam: matchState.teamA.id == team1.id
                    ? matchState.teamB
                    : matchState.teamA,
                engine: engine,
              ),
              pw.SizedBox(height: 24),
            ],

            // Innings 2 Scorecard
            if (inn2 != null) ...[
              _buildInningsPdfSection(
                title: '2nd Innings: ${team2.name}',
                innings: inn2,
                team: team2,
                bowlingTeam: matchState.teamA.id == team2.id
                    ? matchState.teamB
                    : matchState.teamA,
                engine: engine,
              ),
            ],
            if ([...matchState.teamA.players, ...matchState.teamB.players]
                .any((player) => player.isLateAddition)) ...[
              pw.SizedBox(height: 24),
              pw.Text(
                'Late additions',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
              pw.SizedBox(height: 8),
              ...[matchState.teamA, matchState.teamB].expand(
                (team) =>
                    team.players.where((player) => player.isLateAddition).map(
                          (player) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Text(
                              '${player.name} – ${team.name} – joined during '
                              '${player.joinedInningsId ?? 'the match'}'
                              '${player.joinedOverNumber == null ? '' : ' at ${player.joinedOverNumber!}.${player.joinedDeliverySequence ?? 0} overs'}',
                            ),
                          ),
                        ),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInningsPdfSection({
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
    final wideRuns = events.fold<int>(0, (sum, event) => sum + event.wideRuns);
    final noBallRuns =
        events.fold<int>(0, (sum, event) => sum + event.noBallRuns);
    final byeRuns = events.fold<int>(0, (sum, event) => sum + event.byeRuns);
    final legByeRuns =
        events.fold<int>(0, (sum, event) => sum + event.legByeRuns);
    final penaltyRuns =
        events.fold<int>(0, (sum, event) => sum + event.penaltyRuns);
    String displayName(String playerId, String playerName, String teamId) =>
        engine.state.displayNameFor(teamId, playerId, playerName);
    final overNumbers = events.map((event) => event.overNumber).toSet().toList()
      ..sort();
    var runningTotal = 0;
    final fallOfWickets = <String>[];
    for (final event in events) {
      runningTotal += event.totalRuns;
      if (event.wicket != null &&
          WicketHandler.countsAsTeamWicket(event.wicket!.type)) {
        final player = team.players.firstWhere(
          (item) => item.id == event.wicket!.dismissedPlayerId,
          orElse: () => Player(
            id: event.wicket!.dismissedPlayerId,
            name: 'Unknown batter',
          ),
        );
        fallOfWickets.add(
          '$runningTotal (${displayName(player.id, player.name, team.id)}, ${event.ballReference})',
        );
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Total: ${innings.totalRuns}/${innings.totalWickets} in ${innings.oversFormatted} overs'
          '${innings.completionReason == 'All Out' ? ' - All Out' : ''} '
          '(CRR: ${innings.runRate.toStringAsFixed(2)})',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
        ),
        pw.Text(
          'Playing squad: ${innings.playingMemberCountSnapshot} | Maximum wickets: ${innings.maximumWickets}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 10),

        // Batting Table
        pw.Text('Batting',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellHeight: 22,
          headers: ['Batter', 'Dismissal', 'R', 'B', '4s', '6s', 'SR'],
          data: batted
              .map((b) => [
                    displayName(b.playerId, b.playerName, team.id),
                    b.dismissalInfo,
                    '${b.runs}',
                    '${b.ballsFaced}',
                    '${b.fours}',
                    '${b.sixes}',
                    b.strikeRate.toStringAsFixed(1),
                  ])
              .toList(),
        ),
        if (didNotBat.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            'Did Not Bat: ${didNotBat.map((batter) => displayName(batter.playerId, batter.playerName, team.id)).join(', ')}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 14),

        pw.Text('Extras',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Wides $wideRuns | No Balls $noBallRuns | Byes $byeRuns | '
          'Leg Byes $legByeRuns | Penalty $penaltyRuns | '
          'Total ${wideRuns + noBallRuns + byeRuns + legByeRuns + penaltyRuns}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 14),
        pw.Text('Fall of Wickets',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          fallOfWickets.isEmpty ? 'None' : fallOfWickets.join(' | '),
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 14),

        // Bowling Table
        pw.Text('Bowling',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellHeight: 22,
          headers: ['Bowler', 'O', 'M', 'R', 'W', 'Wd', 'NB', 'Econ'],
          data: bowlers
              .map((b) => [
                    displayName(b.playerId, b.playerName, bowlingTeam.id),
                    b.oversFormatted,
                    '${b.maidens}',
                    '${b.runsConceded}',
                    '${b.wickets}',
                    '${b.wides}',
                    '${b.noBalls}',
                    b.economyRate.toStringAsFixed(2),
                  ])
              .toList(),
        ),
        pw.SizedBox(height: 14),
        pw.Text('Over Summary',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        ...overNumbers.map((overNumber) {
          final labels = events
              .where((event) => event.overNumber == overNumber)
              .map((event) => event.displayLabel)
              .join('  ');
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(
              'Over ${overNumber + 1}: $labels',
              style: const pw.TextStyle(fontSize: 10),
            ),
          );
        }),
      ],
    );
  }

  /// Saves PDF to local application documents directory
  static Future<File> savePdfLocally(MatchState matchState) async {
    final pdfBytes = await generatePdf(matchState);
    final dir = await getApplicationDocumentsDirectory();

    final dateStr = DateTime.now().toIso8601String().split('T').first;
    final sanitizedTeamA = matchState.teamA.name
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');
    final sanitizedTeamB = matchState.teamB.name
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');

    final fileName =
        '${sanitizedTeamA}_vs_${sanitizedTeamB}_${dateStr}_Scorecard.pdf';
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(pdfBytes);
    return file;
  }

  static void _validateScorecard(MatchState state) {
    if (state.status != MatchStatus.completed &&
        state.status != MatchStatus.abandoned &&
        state.status != MatchStatus.noResult &&
        state.status != MatchStatus.cancelled) {
      throw StateError('A PDF can only be generated after a match has ended.');
    }
    if (state.innings.isEmpty ||
        (!state.endedManually && state.events.isEmpty)) {
      throw StateError(
        'The ended match does not contain persisted innings data.',
      );
    }
    for (final innings in state.innings) {
      final events = state.events
          .where((event) => event.inningsId == innings.inningsId)
          .toList();
      final runs = events.fold<int>(0, (sum, event) => sum + event.totalRuns);
      final legalBalls = events.where((event) => event.isLegal).length;
      if (runs != innings.totalRuns || legalBalls != innings.legalBallsBowled) {
        throw StateError(
          'Scorecard validation failed for innings ${innings.inningsNumber}.',
        );
      }
    }
  }
}
