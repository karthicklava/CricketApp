import 'package:meta/meta.dart';

@immutable
class LiveBattingFigures {
  final String playerId;
  final String playerName;
  final int runs;
  final int ballsFaced;
  final bool isStriker;

  const LiveBattingFigures({
    required this.playerId,
    required this.playerName,
    required this.runs,
    required this.ballsFaced,
    required this.isStriker,
  });
}

@immutable
class LiveBowlingFigures {
  final String playerId;
  final String playerName;
  final int legalBalls;
  final int ballsPerOver;
  final int maidens;
  final int runsConceded;
  final int wickets;

  const LiveBowlingFigures({
    required this.playerId,
    required this.playerName,
    required this.legalBalls,
    required this.ballsPerOver,
    required this.maidens,
    required this.runsConceded,
    required this.wickets,
  });

  String get oversDisplay =>
      '${legalBalls ~/ ballsPerOver}.${legalBalls % ballsPerOver}';

  double get economy {
    if (legalBalls == 0) return 0;
    return runsConceded / (legalBalls / ballsPerOver);
  }
}

@immutable
class LivePlayerFigures {
  final LiveBattingFigures striker;
  final LiveBattingFigures nonStriker;
  final LiveBowlingFigures bowler;

  const LivePlayerFigures({
    required this.striker,
    required this.nonStriker,
    required this.bowler,
  });
}
