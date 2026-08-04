import 'package:meta/meta.dart';
import 'player.dart';

@immutable
class Team {
  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
  final List<Player> players;

  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
    this.players = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'logoUrl': logoUrl,
        'players': players.map((p) => p.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String,
        name: json['name'] as String,
        shortName: json['shortName'] as String,
        logoUrl: json['logoUrl'] as String?,
        players: (json['players'] as List<dynamic>?)
                ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
