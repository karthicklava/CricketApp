import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/core/utils/match_datetime_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

MatchState stateWithTimes({
  int? scheduledAt,
  int? startedAt,
  int? createdAt,
  int? endedAt,
  MatchStatus status = MatchStatus.completed,
}) =>
    MatchState(
      matchId: 'time-test',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: const Team(id: 'a', name: 'Alpha', shortName: 'A'),
      teamB: const Team(id: 'b', name: 'Beta', shortName: 'B'),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      status: status,
      innings: const [
        InningsState(
          inningsId: 'i',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
        ),
      ],
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      createdAt: createdAt,
      endedAt: endedAt,
      venueName: 'Chennai',
      matchTimeZone: 'Asia/Kolkata',
    );

void main() {
  final localStart = DateTime(2026, 8, 3, 9, 24);
  final localEnd = DateTime(2026, 8, 3, 10, 18);

  test('started time has priority and completed PDF lines include end time',
      () {
    final state = stateWithTimes(
      scheduledAt: DateTime(2026, 8, 3, 9).millisecondsSinceEpoch,
      startedAt: localStart.millisecondsSinceEpoch,
      createdAt: DateTime(2026, 8, 2).millisecondsSinceEpoch,
      endedAt: localEnd.millisecondsSinceEpoch,
    );
    final summary = MatchDateTimeFormatter.summary(
      state,
      generatedAt: DateTime(2026, 8, 4, 11, 30),
    );
    final lines = MatchDateTimeFormatter.pdfLines(state, summary);

    expect(summary.source, MatchTimeSource.started);
    expect(lines, contains('Match Date: 03 Aug 2026'));
    expect(lines, contains('Start Time: 09:24 AM'));
    expect(lines, contains('End Time: 10:18 AM'));
    expect(lines, contains('Venue: Chennai'));
    expect(summary.generatedDateTime.day, 4);
  });

  test('scheduled and created timestamps are labelled as fallbacks', () {
    final scheduled = stateWithTimes(
      scheduledAt: localStart.millisecondsSinceEpoch,
      status: MatchStatus.draft,
    );
    final scheduledSummary = MatchDateTimeFormatter.summary(scheduled);
    expect(
      MatchDateTimeFormatter.pdfLines(scheduled, scheduledSummary),
      contains('Scheduled: 03 Aug 2026, 09:24 AM'),
    );

    final created =
        stateWithTimes(createdAt: localStart.millisecondsSinceEpoch);
    final createdSummary = MatchDateTimeFormatter.summary(created);
    expect(
      MatchDateTimeFormatter.pdfLines(created, createdSummary),
      contains('Match record created: 03 Aug 2026, 09:24 AM'),
    );
  });

  test('abandoned match labels its persisted end timestamp', () {
    final state = stateWithTimes(
      startedAt: localStart.millisecondsSinceEpoch,
      endedAt: localEnd.millisecondsSinceEpoch,
      status: MatchStatus.abandoned,
    );
    final summary = MatchDateTimeFormatter.summary(state);
    expect(
      MatchDateTimeFormatter.pdfLines(state, summary),
      contains('Ended: 10:18 AM'),
    );
  });
}
