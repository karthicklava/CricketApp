import 'package:meta/meta.dart';

@immutable
class BatterScorecard {
  final String playerId;
  final String playerName;
  final int runs;
  final int ballsFaced;
  final int fours;
  final int sixes;
  final String
      dismissalInfo; // e.g., "b Bowler", "c Fielder b Bowler", "not out"
  final bool isDismissed;
  final int? battingPosition;
  final bool hasBatted;

  const BatterScorecard({
    required this.playerId,
    required this.playerName,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.dismissalInfo = 'not out',
    this.isDismissed = false,
    this.battingPosition,
    this.hasBatted = false,
  });

  double get strikeRate =>
      ballsFaced == 0 ? 0.0 : ((runs / ballsFaced) * 100).toDouble();

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'runs': runs,
        'ballsFaced': ballsFaced,
        'fours': fours,
        'sixes': sixes,
        'dismissalInfo': dismissalInfo,
        'isDismissed': isDismissed,
        'battingPosition': battingPosition,
        'hasBatted': hasBatted,
        'strikeRate': strikeRate,
      };
}

@immutable
class BowlerScorecard {
  final String playerId;
  final String playerName;
  final int legalBallsBowled;
  final int maidens;
  final int runsConceded;
  final int wickets;
  final int wides;
  final int noBalls;
  final int ballsPerOver;
  final int? bowlingPosition;

  const BowlerScorecard({
    required this.playerId,
    required this.playerName,
    this.legalBallsBowled = 0,
    this.maidens = 0,
    this.runsConceded = 0,
    this.wickets = 0,
    this.wides = 0,
    this.noBalls = 0,
    this.ballsPerOver = 6,
    this.bowlingPosition,
  });

  String get oversFormatted {
    final overs = legalBallsBowled ~/ ballsPerOver;
    final balls = legalBallsBowled % ballsPerOver;
    return '$overs.$balls';
  }

  double get economyRate {
    if (legalBallsBowled == 0) return 0.0;
    final overs = legalBallsBowled / ballsPerOver;
    return (runsConceded / overs);
  }

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'legalBallsBowled': legalBallsBowled,
        'oversFormatted': oversFormatted,
        'maidens': maidens,
        'runsConceded': runsConceded,
        'wickets': wickets,
        'wides': wides,
        'noBalls': noBalls,
        'ballsPerOver': ballsPerOver,
        'economyRate': economyRate,
        'bowlingPosition': bowlingPosition,
      };
}

@immutable
class ExtrasSummary {
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;
  final int penalty;

  const ExtrasSummary({
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
    this.penalty = 0,
  });

  int get total => wides + noBalls + byes + legByes + penalty;

  Map<String, dynamic> toJson() => {
        'wides': wides,
        'noBalls': noBalls,
        'byes': byes,
        'legByes': legByes,
        'penalty': penalty,
        'total': total,
      };
}
