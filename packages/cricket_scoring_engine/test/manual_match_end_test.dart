import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:test/test.dart';

CricketScoringEngine engine() => CricketScoringEngine.createMatch(
      matchId: 'manual-end',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 2,
      ),
      teamA: const Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [
          Player(id: 'a1', name: 'A1'),
          Player(id: 'a2', name: 'A2'),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'Beta',
        shortName: 'B',
        players: [
          Player(id: 'b1', name: 'B1'),
          Player(id: 'b2', name: 'B2'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

void main() {
  test('rain abandonment preserves score and has no winner', () {
    final scoring = engine();
    scoring.recordDelivery(
      eventId: 'ball',
      scorerDeviceId: 'device',
      runsBatter: 4,
    );
    scoring.endMatchManually(
      outcome: MatchEndOutcome.abandoned,
      reason: MatchEndReason.rain,
      reasonText: 'Rain',
      note: 'Heavy rain',
      endedBy: 'device',
    );

    expect(scoring.state.status, MatchStatus.abandoned);
    expect(scoring.state.activeInnings.totalRuns, 4);
    expect(scoring.state.events, hasLength(1));
    expect(scoring.state.result, isNull);
    expect(scoring.state.manualResultText, contains('rain'));
    expect(
      () => scoring.recordDelivery(eventId: 'later', scorerDeviceId: 'device'),
      throwsStateError,
    );
  });

  test('no result and cancelled outcomes have no winner', () {
    for (final outcome in [
      MatchEndOutcome.noResult,
      MatchEndOutcome.cancelled,
    ]) {
      final scoring = engine();
      scoring.endMatchManually(
        outcome: outcome,
        reason: MatchEndReason.unsafeGround,
        reasonText: 'Unsafe ground',
        endedBy: 'device',
      );
      expect(scoring.state.result, isNull);
      expect(scoring.state.endedManually, isTrue);
    }
  });

  test('forfeit requires teams and stores correct winner', () {
    final scoring = engine();
    expect(
      () => scoring.endMatchManually(
        outcome: MatchEndOutcome.teamForfeit,
        reason: MatchEndReason.teamWithdrawal,
        reasonText: 'Team withdrawal',
        endedBy: 'device',
      ),
      throwsArgumentError,
    );
    scoring.endMatchManually(
      outcome: MatchEndOutcome.teamForfeit,
      reason: MatchEndReason.teamWithdrawal,
      reasonText: 'Team withdrawal',
      endedBy: 'device',
      forfeitingTeamId: 'b',
      winnerTeamId: 'a',
    );
    expect(scoring.state.status, MatchStatus.completed);
    expect(scoring.state.result!.winnerTeamId, 'a');
    expect(scoring.state.result!.resultString, contains('forfeit'));
  });

  test('other requires note and manual completion requires winner or tie', () {
    expect(
      () => engine().endMatchManually(
        outcome: MatchEndOutcome.abandoned,
        reason: MatchEndReason.other,
        reasonText: 'Other',
        endedBy: 'device',
      ),
      throwsArgumentError,
    );
    expect(
      () => engine().endMatchManually(
        outcome: MatchEndOutcome.manuallyCompleted,
        reason: MatchEndReason.timeLimit,
        reasonText: 'Time limit',
        endedBy: 'device',
      ),
      throwsArgumentError,
    );
  });

  test('reopen restores exact live scoring state', () {
    final scoring = engine();
    scoring.recordDelivery(
      eventId: 'ball',
      scorerDeviceId: 'device',
      runsBatter: 2,
    );
    final events = scoring.state.events;
    scoring.endMatchManually(
      outcome: MatchEndOutcome.noResult,
      reason: MatchEndReason.rain,
      reasonText: 'Rain',
      endedBy: 'device',
    );
    scoring.reopenManuallyEndedMatch();
    expect(scoring.state.status, MatchStatus.live);
    expect(scoring.state.events, events);
    expect(scoring.state.activeInnings.totalRuns, 2);
    expect(scoring.state.endedManually, isFalse);
  });
}
