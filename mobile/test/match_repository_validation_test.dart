import 'dart:convert';
import 'package:cricket_scorer/core/validation/match_setup_validation.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/data/repositories/match_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

void main() {
  late AppDatabase database;
  late MatchRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(database);
    for (final team in const [
      ('a', 'Team A'),
      ('b', 'Team B'),
    ]) {
      await database.createTeam(
        TeamsTableCompanion.insert(
          id: team.$1,
          name: team.$2,
          shortName: team.$1.toUpperCase(),
          createdAt: 1,
        ),
      );
    }
  });

  tearDown(() => database.close());

  test('repository blocks live match creation with an empty team', () async {
    await expectLater(
      repository.saveMatch(
        id: 'match',
        teamAId: 'a',
        teamBId: 'b',
        format: 'custom',
        scheduledAt: 1,
        status: 'live',
        currentScorerDeviceId: 'test',
      ),
      throwsA(isA<MatchSetupValidationException>()),
    );
  });

  test('valid small squads can create a live match', () async {
    for (final entry in const [
      ('a', 'a1'),
      ('a', 'a2'),
      ('b', 'b1'),
      ('b', 'b2'),
    ]) {
      await database.createPlayer(
        PlayersTableCompanion.insert(
          id: entry.$2,
          name: entry.$2,
          createdAt: 1,
        ),
      );
      await database.addPlayerToTeam(entry.$1, entry.$2);
    }

    await repository.saveMatch(
      id: 'match',
      teamAId: 'a',
      teamBId: 'b',
      format: 'custom',
      scheduledAt: 1,
      teamASquadJson: jsonEncode(['a1', 'a2']),
      teamBSquadJson: jsonEncode(['b1', 'b2']),
      teamACaptainId: 'a1',
      teamBCaptainId: 'b1',
      teamAWicketkeeperId: 'a2',
      teamBWicketkeeperId: 'b2',
      status: 'live',
      currentScorerDeviceId: 'test',
    );

    final saved = (await database.getMatchById('match'))!;
    expect(saved.status, 'live');
    expect(saved.teamAWicketkeeperId, 'a2');
    expect(saved.teamBWicketkeeperId, 'b2');
  });

  test('saving the same draft ID updates instead of duplicating', () async {
    Future<void> save(String venue) => repository.saveMatch(
          id: 'draft-one',
          teamAId: 'a',
          teamBId: 'b',
          format: 'custom',
          venueName: venue,
          scheduledAt: 1,
          status: 'draft',
          currentScorerDeviceId: 'test',
          setupDraftJson: jsonEncode({'venue': venue, 'currentStep': 0}),
        );

    await save('First');
    await save('Updated');

    final matches = await database.getAllMatches();
    expect(matches, hasLength(1));
    expect(matches.single.venueName, 'Updated');
    expect(matches.single.setupDraftJson, contains('Updated'));
  });

  test('persisted live snapshot restores score, over and active players',
      () async {
    for (final entry in const [
      ('a', 'a1'),
      ('a', 'a2'),
      ('b', 'b1'),
      ('b', 'b2'),
    ]) {
      await database.createPlayer(
        PlayersTableCompanion.insert(
          id: entry.$2,
          name: entry.$2,
          createdAt: 1,
        ),
      );
      await database.addPlayerToTeam(entry.$1, entry.$2);
    }
    await repository.saveMatch(
      id: 'resume',
      teamAId: 'a',
      teamBId: 'b',
      format: 'custom',
      scheduledAt: 1,
      teamASquadJson: jsonEncode(['a1', 'a2']),
      teamBSquadJson: jsonEncode(['b1', 'b2']),
      teamACaptainId: 'a1',
      teamBCaptainId: 'b1',
      status: 'live',
      currentScorerDeviceId: 'test',
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'resume',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 2,
      ),
      teamA: const Team(
        id: 'a',
        name: 'A',
        shortName: 'A',
        players: [
          Player(id: 'a1', name: 'A1'),
          Player(id: 'a2', name: 'A2'),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'B',
        shortName: 'B',
        players: [
          Player(id: 'b1', name: 'B1'),
          Player(id: 'b2', name: 'B2'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(
      eventId: 'delivery',
      scorerDeviceId: 'test',
      runsBatter: 1,
    );
    engine.recordDelivery(
      eventId: 'wide',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      additionalWideRuns: 1,
    );
    await repository.persistState(engine.state);

    final restored = await repository.getMatchState('resume');
    expect(restored!.matchId, 'resume');
    expect(restored.activeInnings.totalRuns, 3);
    expect(restored.activeInnings.legalBallsBowled, 1);
    expect(restored.events.last.wideRuns, 2);
    expect(restored.events.last.additionalWideRuns, 1);
    expect(restored.events.last.displayLabel, 'Wd+1');
    expect(restored.activeInnings.strikerId, 'a1');
    expect(restored.activeInnings.nonStrikerId, 'a2');
    expect(restored.activeInnings.currentBowlerId, 'b1');
    expect(await database.getAllMatches(), hasLength(1));
  });
}
