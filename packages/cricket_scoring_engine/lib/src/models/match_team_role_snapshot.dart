import 'package:meta/meta.dart';

@immutable
class MatchTeamRoleSnapshot {
  final String teamId;
  final String captainPlayerId;
  final String? wicketkeeperPlayerId;

  const MatchTeamRoleSnapshot({
    required this.teamId,
    required this.captainPlayerId,
    this.wicketkeeperPlayerId,
  });

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'captainPlayerId': captainPlayerId,
        'wicketkeeperPlayerId': wicketkeeperPlayerId,
      };

  factory MatchTeamRoleSnapshot.fromJson(Map<String, dynamic> json) =>
      MatchTeamRoleSnapshot(
        teamId: json['teamId'] as String,
        captainPlayerId: json['captainPlayerId'] as String,
        wicketkeeperPlayerId: json['wicketkeeperPlayerId'] as String?,
      );
}

String formatPlayerDisplayName({
  required String playerName,
  required bool isCaptain,
  required bool isWicketkeeper,
}) {
  if (isCaptain && isWicketkeeper) return '$playerName (C & WK)';
  if (isCaptain) return '$playerName (C)';
  if (isWicketkeeper) return '$playerName (WK)';
  return playerName;
}
