import '../engine.dart';
import '../models/live_figures.dart';
import '../models/match_state.dart';
import '../models/player.dart';
import '../models/scorecard.dart';

class LiveFiguresService {
  const LiveFiguresService();

  LivePlayerFigures calculate(MatchState state) {
    final innings = state.activeInnings;
    final battingTeam =
        innings.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowlingTeam =
        innings.bowlingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final engine = CricketScoringEngine(state);
    final batting = engine.getBatterScorecards(
      battingTeam,
      inningsId: innings.inningsId,
    );
    final bowling = engine.getBowlerScorecards(
      bowlingTeam,
      inningsId: innings.inningsId,
    );
    final strikerPlayer = _player(
      battingTeam.players,
      innings.strikerId,
      'Striker',
    );
    final nonStrikerPlayer = _player(
      battingTeam.players,
      innings.nonStrikerId,
      'Non-striker',
    );
    final bowlerPlayer = _player(
      bowlingTeam.players,
      innings.currentBowlerId ?? innings.previousOverBowlerId ?? '',
      innings.currentBowlerId == null ? 'Awaiting next bowler' : 'Bowler',
    );
    final strikerRow = _batterRow(batting, strikerPlayer);
    final nonStrikerRow = _batterRow(batting, nonStrikerPlayer);
    final bowlerRow = bowling.firstWhere(
      (row) => row.playerId == bowlerPlayer.id,
      orElse: () => BowlerScorecard(
        playerId: bowlerPlayer.id,
        playerName: bowlerPlayer.name,
        ballsPerOver: state.config.ballsPerOver,
      ),
    );
    return LivePlayerFigures(
      striker: LiveBattingFigures(
        playerId: strikerPlayer.id,
        playerName: strikerPlayer.name,
        runs: strikerRow.runs,
        ballsFaced: strikerRow.ballsFaced,
        isStriker: true,
      ),
      nonStriker: LiveBattingFigures(
        playerId: nonStrikerPlayer.id,
        playerName: nonStrikerPlayer.name,
        runs: nonStrikerRow.runs,
        ballsFaced: nonStrikerRow.ballsFaced,
        isStriker: false,
      ),
      bowler: LiveBowlingFigures(
        playerId: bowlerPlayer.id,
        playerName: bowlerPlayer.name,
        legalBalls: bowlerRow.legalBallsBowled,
        ballsPerOver: state.config.ballsPerOver,
        maidens: bowlerRow.maidens,
        runsConceded: bowlerRow.runsConceded,
        wickets: bowlerRow.wickets,
      ),
    );
  }

  static Player _player(List<Player> players, String id, String fallback) =>
      players.firstWhere(
        (player) => player.id == id,
        orElse: () => Player(id: id, name: fallback),
      );

  static BatterScorecard _batterRow(
    List<BatterScorecard> rows,
    Player player,
  ) =>
      rows.firstWhere(
        (row) => row.playerId == player.id,
        orElse: () => BatterScorecard(
          playerId: player.id,
          playerName: player.name,
          dismissalInfo: 'yet to bat',
        ),
      );
}
