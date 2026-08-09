import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/core/navigation/match_destination.dart';
import 'package:flutter_test/flutter_test.dart';

MatchState validLiveState({MatchStatus status = MatchStatus.live}) =>
    MatchState(
      matchId: 'persisted-id',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 1,
      ),
      teamA: const Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [
          Player(id: 'a1', name: 'A One'),
          Player(id: 'a2', name: 'A Two'),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'Beta',
        shortName: 'B',
        players: [Player(id: 'b1', name: 'B One')],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      status: status,
      innings: const [
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

void main() {
  test('draft setup statuses open setup with the selected draft ID', () {
    for (final status in ['draft', 'setupInProgress']) {
      expect(
        MatchDestinationResolver.resolveStatus(status),
        MatchDestination.setup,
      );
      expect(
        MatchDestinationResolver.routeFor(
          matchId: 'selected',
          status: status,
        ),
        '/matches/create?draftId=selected',
      );
    }
  });

  test('all active statuses route to persisted live scoring ID', () {
    for (final status in [
      'ready',
      'setupCompleted',
      'tossCompleted',
      'live',
      'inningsReview',
      'inProgress',
      'awaitingNextBatter',
      'awaitingNextBowler',
      'secondInningsSetup',
      'resultPending',
      'matchReview',
      'paused',
      'secondInnings',
    ]) {
      expect(
        MatchDestinationResolver.resolveStatus(status),
        MatchDestination.liveScoring,
      );
      expect(
        MatchDestinationResolver.routeFor(
          matchId: 'selected',
          status: status,
        ),
        '/matches/selected/scoring',
      );
    }
  });

  test('terminal statuses bypass resumable live-state handling', () {
    for (final status in const [
      MatchStatus.completed,
      MatchStatus.abandoned,
      MatchStatus.noResult,
      MatchStatus.cancelled,
    ]) {
      expect(MatchDestinationResolver.isReadOnlyStatus(status), isTrue);
    }
    expect(
        MatchDestinationResolver.isReadOnlyStatus(MatchStatus.live), isFalse);
  });

  test('innings break routes to continuation and completed to scorecard', () {
    expect(
      MatchDestinationResolver.resolveStatus('inningsBreak'),
      MatchDestination.inningsBreak,
    );
    expect(
      MatchDestinationResolver.routeFor(
        matchId: 'i',
        status: 'inningsBreak',
      ),
      '/matches/i/scoring',
    );
    expect(
      MatchDestinationResolver.routeFor(
        matchId: 'c',
        status: 'completed',
      ),
      '/matches/history/c',
    );
    expect(
      MatchDestinationResolver.resolveStatus('archived'),
      MatchDestination.archivedScorecard,
    );
  });

  test('valid live state passes resume validation', () {
    expect(
      MatchDestinationResolver.validateLiveState(validLiveState()),
      isNull,
    );
  });

  test('incomplete live state opens recovery instead of setup', () {
    final invalid = validLiveState().copyWith(
      teamA: const Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [Player(id: 'a2', name: 'A Two')],
      ),
    );
    expect(
      MatchDestinationResolver.validateLiveState(invalid),
      contains('striker'),
    );
  });

  test('late-added players survive destination validation and resume', () {
    final state = validLiveState().copyWith(
      teamA: Team(
        id: 'a',
        name: 'Alpha',
        shortName: 'A',
        players: [
          ...validLiveState().teamA.players,
          const Player(
            id: 'late',
            name: 'Late Player',
            isLateAddition: true,
          ),
        ],
      ),
    );
    final restored = MatchState.fromJson(state.toJson());
    expect(MatchDestinationResolver.validateLiveState(restored), isNull);
    expect(restored.teamA.players.last.isLateAddition, isTrue);
  });
}
