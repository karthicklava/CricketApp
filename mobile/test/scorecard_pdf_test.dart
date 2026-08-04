import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/core/services/scorecard_pdf_service.dart';

void main() {
  test('completed-match PDF contains persisted innings and delivery data',
      () async {
    const batting = Team(
      id: 'a',
      name: 'Alpha',
      shortName: 'ALP',
      players: [
        Player(id: 'a1', name: 'A One'),
        Player(id: 'a2', name: 'A Two'),
      ],
    );
    const bowling = Team(
      id: 'b',
      name: 'Beta',
      shortName: 'BET',
      players: [
        Player(id: 'b1', name: 'B One'),
        Player(id: 'b2', name: 'B Two'),
      ],
    );
    const config = MatchConfig(
      format: MatchFormat.custom,
      totalOvers: 1,
      maxOversPerBowler: 1,
      maxWickets: 1,
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'pdf-match',
      config: config,
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: batting.id,
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
      teamRoleSnapshots: const [
        MatchTeamRoleSnapshot(
          teamId: 'a',
          captainPlayerId: 'a1',
          wicketkeeperPlayerId: 'a2',
        ),
        MatchTeamRoleSnapshot(
          teamId: 'b',
          captainPlayerId: 'b1',
          wicketkeeperPlayerId: 'b1',
        ),
      ],
      scheduledAt: DateTime(2026, 8, 3, 9).millisecondsSinceEpoch,
      startedAt: DateTime(2026, 8, 3, 9, 24).millisecondsSinceEpoch,
      createdAt: DateTime(2026, 8, 3, 8, 50).millisecondsSinceEpoch,
      venueName: 'Chennai',
      matchTimeZone: 'Asia/Kolkata',
    );

    engine.recordDelivery(
      eventId: 'first-wide',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    engine.recordDelivery(
      eventId: 'first-wicket',
      scorerDeviceId: 'test',
      wicket: const WicketDetail(
        type: WicketType.bowled,
        dismissedPlayerId: 'a1',
      ),
    );
    engine.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    engine.recordDelivery(
      eventId: 'winning-runs',
      scorerDeviceId: 'test',
      runsBatter: 2,
    );

    expect(engine.state.status, MatchStatus.completed);
    final awards =
        const MatchAwardsService().calculateAwards(engine.state).awards;
    engine.setAwards(awards);
    final bytes = await ScorecardPdfService.generatePdf(
      engine.state,
      generatedAt: DateTime(2026, 8, 4, 10, 25),
    );
    expect(bytes, isNotEmpty);
    expect(engine.state.awards, hasLength(2));
    expect(engine.state.innings, hasLength(2));
    expect(engine.state.events.first.displayLabel, 'Wd');
    expect(engine.state.endedAt, isNotNull);
    expect(engine.state.displayNameFor('b', 'b1', 'B One'), 'B One (C & WK)');
  });

  test('PDF generation rejects incomplete scorecard data', () async {
    const teamA = Team(id: 'a', name: 'Alpha', shortName: 'ALP');
    const teamB = Team(id: 'b', name: 'Beta', shortName: 'BET');
    const state = MatchState(
      matchId: 'missing',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      status: MatchStatus.completed,
      innings: [
        InningsState(
          inningsId: 'i1',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
        ),
      ],
    );

    expect(
      () => ScorecardPdfService.generatePdf(state),
      throwsA(isA<StateError>()),
    );
  });

  test('abandoned partial scorecard PDF includes terminal metadata', () async {
    const teamA = Team(
      id: 'a',
      name: 'Alpha',
      shortName: 'A',
      players: [
        Player(id: 'a1', name: 'A1'),
        Player(id: 'a2', name: 'A2'),
      ],
    );
    const teamB = Team(
      id: 'b',
      name: 'Beta',
      shortName: 'B',
      players: [
        Player(id: 'b1', name: 'B1'),
        Player(id: 'b2', name: 'B2'),
      ],
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'rain-pdf',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 2,
      ),
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(
      eventId: 'four',
      scorerDeviceId: 'test',
      runsBatter: 4,
    );
    engine.endMatchManually(
      outcome: MatchEndOutcome.abandoned,
      reason: MatchEndReason.rain,
      reasonText: 'Rain',
      note: 'Heavy rain',
      endedBy: 'test',
    );

    final bytes = await ScorecardPdfService.generatePdf(engine.state);
    expect(bytes, isNotEmpty);
    expect(engine.state.endReasonText, 'Rain');
    expect(engine.state.activeInnings.totalRuns, 4);
  });
}
