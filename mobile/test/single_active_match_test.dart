import 'package:cricket_scorer/data/local/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  MatchesTableCompanion match(String id, String status) =>
      MatchesTableCompanion.insert(
        id: id,
        teamAId: 'a',
        teamBId: 'b',
        scheduledAt: 1,
        status: Value(status),
        currentScorerDeviceId: 'offline-device',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  test('database rejects a second active match offline', () async {
    await database.createMatch(match('first', 'live'));

    await expectLater(
      database.createMatch(match('second', 'live')),
      throwsStateError,
    );
    expect(await database.hasActiveMatch(), isTrue);
    expect((await database.getAllMatches()), hasLength(1));
  });

  test('all resumable workflow statuses hold the active lock', () async {
    var index = 0;
    for (final status in const [
      'setupCompleted',
      'ready',
      'tossCompleted',
      'live',
      'inProgress',
      'inningsBreak',
      'awaitingNextBatter',
      'awaitingNextBowler',
      'paused',
      'secondInnings',
      'secondInningsSetup',
    ]) {
      final id = 'match-${index++}-$status';
      await database.createMatch(match(id, status));
      expect(await database.hasActiveMatch(), isTrue, reason: status);
      await database.updateMatchStatus(id, 'abandoned');
    }
  });

  test('completed and abandoned matches release the lock', () async {
    await database.createMatch(match('first', 'live'));
    await database.updateMatchStatus('first', 'completed');
    expect(await database.hasActiveMatch(), isFalse);
    await database.createMatch(match('second', 'live'));
    await database.updateMatchStatus('second', 'abandoned');
    expect(await database.hasActiveMatch(), isFalse);
    await database.createMatch(match('third', 'live'));
    expect((await database.getActiveMatch())!.id, 'third');
  });

  test('promoting an existing draft is blocked by another active match',
      () async {
    await database.createMatch(match('draft', 'draft'));
    await database.createMatch(match('live', 'live'));
    await expectLater(
      database.updateMatchStatus('draft', 'live'),
      throwsStateError,
    );
  });
}
