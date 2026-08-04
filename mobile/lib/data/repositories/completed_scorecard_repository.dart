import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'match_repository.dart';

class ScorecardValidationException implements Exception {
  final String message;
  const ScorecardValidationException(this.message);

  @override
  String toString() => message;
}

class CompletedMatchScorecard {
  final String matchId;
  final MatchState matchState;
  final MatchAward? bestBatter;
  final MatchAward? bestBowler;

  const CompletedMatchScorecard({
    required this.matchId,
    required this.matchState,
    this.bestBatter,
    this.bestBowler,
  });
}

class CompletedScorecardRepository {
  final MatchRepository _matches;

  const CompletedScorecardRepository(this._matches);

  Future<CompletedMatchScorecard> loadCompletedScorecard(
    String matchId,
  ) async {
    final state = await _matches.getMatchState(matchId);
    if (state == null) {
      throw const ScorecardValidationException(
        'The selected match could not be found.',
      );
    }
    if (state.status != MatchStatus.completed &&
        state.status != MatchStatus.abandoned &&
        state.status != MatchStatus.noResult &&
        state.status != MatchStatus.cancelled) {
      throw const ScorecardValidationException(
        'A scorecard is only available after a match has ended.',
      );
    }
    if (state.innings.isEmpty ||
        (!state.endedManually && state.events.isEmpty)) {
      throw const ScorecardValidationException(
        'This match does not contain persisted innings data.',
      );
    }

    for (final innings in state.innings) {
      final events = state.events
          .where((event) => event.inningsId == innings.inningsId)
          .toList();
      final eventRuns =
          events.fold<int>(0, (total, event) => total + event.totalRuns);
      final legalBalls = events.where((event) => event.isLegal).length;
      if (eventRuns != innings.totalRuns ||
          legalBalls != innings.legalBallsBowled) {
        throw ScorecardValidationException(
          'Scorecard validation failed for innings ${innings.inningsNumber}.',
        );
      }
    }

    var awards = state.endedManually
        ? <MatchAward>[]
        : await _matches.loadMatchAwards(matchId);
    if (!state.endedManually && awards.isEmpty) {
      final recalculated = await _matches.recalculateMatchAwards(matchId);
      awards = recalculated.awards;
    }
    final stateWithAwards = state.copyWith(awards: awards);
    MatchAward? awardOfType(MatchAwardType type) {
      for (final award in awards) {
        if (award.type == type) return award;
      }
      return null;
    }

    return CompletedMatchScorecard(
      matchId: matchId,
      matchState: stateWithAwards,
      bestBatter: awardOfType(MatchAwardType.bestBatter),
      bestBowler: awardOfType(MatchAwardType.bestBowler),
    );
  }
}
