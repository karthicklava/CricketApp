import 'package:meta/meta.dart';

enum MatchAwardType { bestBatter, bestBowler }

@immutable
class MatchAward {
  final String id;
  final String matchId;
  final MatchAwardType type;
  final String playerId;
  final String teamId;
  final String playerNameSnapshot;
  final String teamNameSnapshot;
  final String summary;
  final String secondarySummary;
  final double rankingScore;
  final int createdAt;
  final bool isManualOverride;
  final String? overrideReason;

  const MatchAward({
    required this.id,
    required this.matchId,
    required this.type,
    required this.playerId,
    required this.teamId,
    required this.playerNameSnapshot,
    required this.teamNameSnapshot,
    required this.summary,
    this.secondarySummary = '',
    required this.rankingScore,
    required this.createdAt,
    this.isManualOverride = false,
    this.overrideReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'type': type.name,
        'playerId': playerId,
        'teamId': teamId,
        'playerNameSnapshot': playerNameSnapshot,
        'teamNameSnapshot': teamNameSnapshot,
        'summary': summary,
        'secondarySummary': secondarySummary,
        'rankingScore': rankingScore,
        'createdAt': createdAt,
        'isManualOverride': isManualOverride,
        'overrideReason': overrideReason,
      };

  factory MatchAward.fromJson(Map<String, dynamic> json) => MatchAward(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        type: MatchAwardType.values.firstWhere(
          (type) => type.name == json['type'],
        ),
        playerId: json['playerId'] as String,
        teamId: json['teamId'] as String,
        playerNameSnapshot: json['playerNameSnapshot'] as String,
        teamNameSnapshot: json['teamNameSnapshot'] as String,
        summary: json['summary'] as String,
        secondarySummary: json['secondarySummary'] as String? ?? '',
        rankingScore: (json['rankingScore'] as num).toDouble(),
        createdAt: json['createdAt'] as int,
        isManualOverride: json['isManualOverride'] as bool? ?? false,
        overrideReason: json['overrideReason'] as String?,
      );
}

@immutable
class MatchAwardsResult {
  final MatchAward? bestBatter;
  final MatchAward? bestBowler;

  const MatchAwardsResult({this.bestBatter, this.bestBowler});

  List<MatchAward> get awards => [
        if (bestBatter != null) bestBatter!,
        if (bestBowler != null) bestBowler!,
      ];
}
