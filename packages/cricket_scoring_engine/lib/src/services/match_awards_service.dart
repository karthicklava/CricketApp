import '../engine.dart';
import '../models/match_award.dart';
import '../models/match_state.dart';
import '../models/scorecard.dart';
import '../models/team.dart';

class MatchAwardsService {
  const MatchAwardsService();

  MatchAwardsResult calculateAwards(MatchState state) {
    if (state.status != MatchStatus.completed ||
        state.result == null ||
        state.innings.isEmpty ||
        state.events.isEmpty) {
      return const MatchAwardsResult();
    }
    final engine = CricketScoringEngine(state);
    final createdAt = state.events
        .map((event) => event.clientTimestamp)
        .fold<int>(0, (latest, value) => value > latest ? value : latest);
    final batters = <_BatterCandidate>[];
    final bowlers = <_BowlerCandidate>[];

    for (final innings in state.innings) {
      final battingTeam = _team(state, innings.battingTeamId);
      final bowlingTeam = _team(state, innings.bowlingTeamId);
      final battingRows =
          engine.getBatterScorecards(battingTeam, inningsId: innings.inningsId);
      for (var index = 0; index < battingRows.length; index++) {
        final row = battingRows[index];
        final participated = row.hasBatted;
        if (!participated) continue;
        final won = state.result!.winnerTeamId == battingTeam.id;
        final chaseContributor =
            innings.inningsNumber == 2 && won && row.runs > 0;
        final score = row.runs * 10.0 +
            row.strikeRate * 0.20 +
            row.fours +
            row.sixes * 2.0 +
            (!row.isDismissed ? 5.0 : 0.0) +
            (won ? 8.0 : 0.0) +
            (chaseContributor ? 5.0 : 0.0);
        batters.add(_BatterCandidate(
          row: row,
          team: battingTeam,
          score: score,
          teamWon: won,
          battingPosition: index,
        ));
      }

      final bowlingRows =
          engine.getBowlerScorecards(bowlingTeam, inningsId: innings.inningsId);
      final inningsEvents =
          state.events.where((event) => event.inningsId == innings.inningsId);
      for (final row in bowlingRows.where((row) => row.legalBallsBowled > 0)) {
        final events =
            inningsEvents.where((event) => event.bowlerId == row.playerId);
        final dotBalls = events
            .where((event) => event.isLegal && event.totalRuns == 0)
            .length;
        final economy = row.legalBallsBowled == 0
            ? row.runsConceded.toDouble()
            : row.runsConceded /
                (row.legalBallsBowled / state.config.ballsPerOver);
        final won = state.result!.winnerTeamId == bowlingTeam.id;
        final score = row.wickets * 25.0 +
            row.maidens * 8.0 +
            dotBalls -
            economy * 2.0 -
            row.wides * 0.5 -
            row.noBalls +
            (won ? 8.0 : 0.0);
        bowlers.add(_BowlerCandidate(
          row: row,
          team: bowlingTeam,
          score: score,
          economy: economy,
          dotBalls: dotBalls,
          teamWon: won,
        ));
      }
    }

    batters.sort(_compareBatters);
    if (bowlers.every((candidate) => candidate.row.wickets == 0)) {
      bowlers.sort(_compareNoWicketBowlers);
    } else {
      bowlers.sort(_compareBowlers);
    }
    final batter = batters.isEmpty ? null : batters.first;
    final bowler = bowlers.isEmpty ? null : bowlers.first;
    return MatchAwardsResult(
      bestBatter: batter == null
          ? null
          : MatchAward(
              id: '${state.matchId}_${MatchAwardType.bestBatter.name}',
              matchId: state.matchId,
              type: MatchAwardType.bestBatter,
              playerId: batter.row.playerId,
              teamId: batter.team.id,
              playerNameSnapshot: batter.row.playerName,
              teamNameSnapshot: batter.team.name,
              summary:
                  '${batter.row.runs} runs from ${batter.row.ballsFaced} balls',
              secondarySummary:
                  '4s: ${batter.row.fours} · 6s: ${batter.row.sixes} · SR: ${batter.row.strikeRate.toStringAsFixed(2)}',
              rankingScore: batter.score,
              createdAt: createdAt,
            ),
      bestBowler: bowler == null
          ? null
          : MatchAward(
              id: '${state.matchId}_${MatchAwardType.bestBowler.name}',
              matchId: state.matchId,
              type: MatchAwardType.bestBowler,
              playerId: bowler.row.playerId,
              teamId: bowler.team.id,
              playerNameSnapshot: bowler.row.playerName,
              teamNameSnapshot: bowler.team.name,
              summary:
                  '${bowler.row.wickets} wickets for ${bowler.row.runsConceded} runs',
              secondarySummary:
                  'Overs: ${_overs(bowler.row.legalBallsBowled, state.config.ballsPerOver)} · Economy: ${bowler.economy.toStringAsFixed(2)}',
              rankingScore: bowler.score,
              createdAt: createdAt,
            ),
    );
  }

  static Team _team(MatchState state, String id) =>
      id == state.teamA.id ? state.teamA : state.teamB;

  static String _overs(int legalBalls, int ballsPerOver) =>
      '${legalBalls ~/ ballsPerOver}.${legalBalls % ballsPerOver}';

  static int _compareBatters(_BatterCandidate a, _BatterCandidate b) {
    var result = b.score.compareTo(a.score);
    if (result != 0) return result;
    result = b.row.runs.compareTo(a.row.runs);
    if (result != 0) return result;
    result = b.row.strikeRate.compareTo(a.row.strikeRate);
    if (result != 0) return result;
    result = b.row.sixes.compareTo(a.row.sixes);
    if (result != 0) return result;
    result = b.row.fours.compareTo(a.row.fours);
    if (result != 0) return result;
    result = (a.row.isDismissed ? 1 : 0).compareTo(b.row.isDismissed ? 1 : 0);
    if (result != 0) return result;
    result = (b.teamWon ? 1 : 0).compareTo(a.teamWon ? 1 : 0);
    if (result != 0) return result;
    result = a.row.ballsFaced.compareTo(b.row.ballsFaced);
    if (result != 0) return result;
    result = a.battingPosition.compareTo(b.battingPosition);
    if (result != 0) return result;
    return a.row.playerId.compareTo(b.row.playerId);
  }

  static int _compareBowlers(_BowlerCandidate a, _BowlerCandidate b) {
    var result = b.score.compareTo(a.score);
    if (result != 0) return result;
    result = b.row.wickets.compareTo(a.row.wickets);
    if (result != 0) return result;
    result = a.row.runsConceded.compareTo(b.row.runsConceded);
    if (result != 0) return result;
    result = a.economy.compareTo(b.economy);
    if (result != 0) return result;
    result = b.row.maidens.compareTo(a.row.maidens);
    if (result != 0) return result;
    result = b.dotBalls.compareTo(a.dotBalls);
    if (result != 0) return result;
    result = a.row.noBalls.compareTo(b.row.noBalls);
    if (result != 0) return result;
    result = a.row.wides.compareTo(b.row.wides);
    if (result != 0) return result;
    result = (b.teamWon ? 1 : 0).compareTo(a.teamWon ? 1 : 0);
    if (result != 0) return result;
    result = b.row.legalBallsBowled.compareTo(a.row.legalBallsBowled);
    if (result != 0) return result;
    return a.row.playerId.compareTo(b.row.playerId);
  }

  static int _compareNoWicketBowlers(
    _BowlerCandidate a,
    _BowlerCandidate b,
  ) {
    var result = a.economy.compareTo(b.economy);
    if (result != 0) return result;
    result = b.dotBalls.compareTo(a.dotBalls);
    if (result != 0) return result;
    result = b.row.maidens.compareTo(a.row.maidens);
    if (result != 0) return result;
    result =
        (a.row.wides + a.row.noBalls).compareTo(b.row.wides + b.row.noBalls);
    if (result != 0) return result;
    result = b.row.legalBallsBowled.compareTo(a.row.legalBallsBowled);
    if (result != 0) return result;
    return a.row.playerId.compareTo(b.row.playerId);
  }
}

class _BatterCandidate {
  final BatterScorecard row;
  final Team team;
  final double score;
  final bool teamWon;
  final int battingPosition;

  const _BatterCandidate({
    required this.row,
    required this.team,
    required this.score,
    required this.teamWon,
    required this.battingPosition,
  });
}

class _BowlerCandidate {
  final BowlerScorecard row;
  final Team team;
  final double score;
  final double economy;
  final int dotBalls;
  final bool teamWon;

  const _BowlerCandidate({
    required this.row,
    required this.team,
    required this.score,
    required this.economy,
    required this.dotBalls,
    required this.teamWon,
  });
}
