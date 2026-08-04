import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../main.dart';

final teamRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return TeamRepository(db);
});

final activeTeamsStreamProvider = StreamProvider<List<TeamsTableData>>((ref) {
  final repo = ref.watch(teamRepositoryProvider);
  return repo.watchActiveTeams();
});

class TeamRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TeamRepository(this._db);

  Stream<List<TeamsTableData>> watchActiveTeams() => _db.watchActiveTeams();

  Stream<List<PlayersTableData>> watchTeamPlayers(String teamId) =>
      _db.watchTeamPlayers(teamId);

  Future<String> createTeam({
    required String name,
    required String shortName,
    String? city,
    String? color,
    String? logoUrl,
  }) async {
    final existing = await _db.getAllTeams();
    if (existing
        .any((t) => t.name.trim().toLowerCase() == name.trim().toLowerCase())) {
      throw Exception('A team with the name "$name" already exists.');
    }

    final id = _uuid.v4();
    await _db.createTeam(TeamsTableCompanion(
      id: Value(id),
      name: Value(name.trim()),
      shortName: Value(shortName.trim().toUpperCase()),
      city: Value(city?.trim()),
      color: Value(color),
      logoUrl: Value(logoUrl),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return id;
  }

  Future<void> updateTeam({
    required String id,
    required String name,
    required String shortName,
    String? city,
    String? color,
    String? logoUrl,
  }) async {
    final existing = await _db.getAllTeams();
    if (existing.any((t) =>
        t.id != id &&
        t.name.trim().toLowerCase() == name.trim().toLowerCase())) {
      throw Exception('Another team with the name "$name" already exists.');
    }

    await _db.updateTeam(TeamsTableCompanion(
      id: Value(id),
      name: Value(name.trim()),
      shortName: Value(shortName.trim().toUpperCase()),
      city: Value(city?.trim()),
      color: Value(color),
      logoUrl: Value(logoUrl),
      defaultCaptainId: Value(
        existing.where((team) => team.id == id).first.defaultCaptainId,
      ),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<List<TeamsTableData>> getAllTeams() => _db.getAllTeams();

  Future<List<TeamsTableData>> searchTeams(String query) =>
      query.isEmpty ? _db.getAllTeams() : _db.searchTeams(query);

  Future<TeamsTableData?> getTeamById(String id) => _db.getTeamById(id);

  Future<void> archiveTeam(String id) => _db.archiveTeam(id);

  Future<void> deleteTeam(String id) => _db.deleteTeam(id);

  Future<String> addPlayerToTeam({
    required String teamId,
    required String name,
    required String role,
    required String battingStyle,
    required String bowlingStyle,
    String? jerseyNumber,
    String? phone,
    bool isCaptain = false,
    bool isWicketKeeper = false,
  }) async {
    final playerId = _uuid.v4();
    await _db.createPlayer(PlayersTableCompanion(
      id: Value(playerId),
      name: Value(name.trim()),
      role: Value(role),
      battingStyle: Value(battingStyle),
      bowlingStyle: Value(bowlingStyle),
      jerseyNumber: Value(jerseyNumber?.trim()),
      phone: Value(phone?.trim()),
      isCaptain: Value(isCaptain),
      isWicketKeeper: Value(isWicketKeeper),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    await _db.addPlayerToTeam(teamId, playerId);
    if (isCaptain) {
      await _db.setDefaultCaptain(teamId, playerId);
    }
    return playerId;
  }

  Future<String> createPlayerForLiveMatch({
    required String name,
    required String role,
    required String battingStyle,
    required String bowlingStyle,
    String? jerseyNumber,
    bool addToPermanentTeam = true,
    required String teamId,
    bool isWicketKeeper = false,
  }) async {
    final roster = await _db.getTeamPlayers(teamId);
    final normalizedName = name.trim().toLowerCase();
    if (roster
        .any((player) => player.name.trim().toLowerCase() == normalizedName)) {
      throw StateError('$name already belongs to this team.');
    }
    final normalizedJersey = jerseyNumber?.trim();
    if (normalizedJersey != null &&
        normalizedJersey.isNotEmpty &&
        roster.any((player) => player.jerseyNumber == normalizedJersey)) {
      throw StateError('Jersey number $normalizedJersey is already in use.');
    }
    final playerId = _uuid.v4();
    await _db.createPlayer(PlayersTableCompanion(
      id: Value(playerId),
      name: Value(name.trim()),
      role: Value(role),
      battingStyle: Value(battingStyle),
      bowlingStyle: Value(bowlingStyle),
      jerseyNumber: Value(normalizedJersey),
      isWicketKeeper: Value(isWicketKeeper),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    if (addToPermanentTeam) {
      await _db.addPlayerToTeam(teamId, playerId);
    }
    return playerId;
  }

  Future<void> updatePlayer({
    String? teamId,
    required String playerId,
    required String name,
    required String role,
    required String battingStyle,
    required String bowlingStyle,
    String? jerseyNumber,
    String? phone,
    bool isCaptain = false,
    bool isWicketKeeper = false,
  }) async {
    await _db.updatePlayer(PlayersTableCompanion(
      id: Value(playerId),
      name: Value(name.trim()),
      role: Value(role),
      battingStyle: Value(battingStyle),
      bowlingStyle: Value(bowlingStyle),
      jerseyNumber: Value(jerseyNumber?.trim()),
      phone: Value(phone?.trim()),
      isCaptain: Value(isCaptain),
      isWicketKeeper: Value(isWicketKeeper),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    if (isCaptain) {
      if (teamId == null) {
        throw ArgumentError('A team is required when assigning a captain.');
      }
      await _db.setDefaultCaptain(teamId, playerId);
    }
  }

  Future<void> setDefaultCaptain(String teamId, String playerId) =>
      _db.setDefaultCaptain(teamId, playerId);

  Future<void> removePlayerFromTeam(String teamId, String playerId) =>
      _db.archivePlayerFromTeam(teamId, playerId);

  Future<void> restorePlayerToTeam(String teamId, String playerId) =>
      _db.restorePlayerToTeam(teamId, playerId);

  Future<List<PlayersTableData>> getRemovedTeamPlayers(String teamId) =>
      _db.getRemovedTeamPlayers(teamId);

  Future<List<PlayersTableData>> getTeamPlayers(String teamId) =>
      _db.getTeamPlayers(teamId);
}
