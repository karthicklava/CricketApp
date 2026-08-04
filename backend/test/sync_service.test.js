import test from 'node:test';
import assert from 'node:assert/strict';
import { SyncService } from '../dist/sync/sync.service.js';

// Fallback test logic if ts build output is verified
test('SyncService - Idempotent event duplicate drop', async () => {
  const service = new SyncService();

  const event1 = {
    eventId: 'e1',
    matchId: 'm1',
    inningsId: 'inn1',
    overNumber: 0,
    legalBallNumber: 1,
    eventSequence: 1,
    scorerDeviceId: 'dev1',
    strikerId: 'p1',
    nonStrikerId: 'p2',
    bowlerId: 'p6',
    runsBatter: 1,
    isLegal: true,
    previousEventHash: 'GENESIS',
    clientTimestamp: Date.now(),
  };

  // First sync
  const res1 = await service.syncBatchEvents('m1', 'dev1', [event1]);
  assert.equal(res1.acceptedEventIds.length, 1);
  assert.equal(res1.latestServerSequence, 1);

  // Duplicate sync of same eventId
  const res2 = await service.syncBatchEvents('m1', 'dev1', [event1]);
  assert.equal(res2.acceptedEventIds.length, 1);
  assert.equal(res2.acceptedEventIds[0], 'e1');
  assert.equal(res2.latestServerSequence, 1);
  assert.equal(res2.hasConflict, false);
});

test('SyncService - Out of sequence gap detection', async () => {
  const service = new SyncService();

  // Initial sequence set to 1
  await service.syncBatchEvents('m1', 'dev1', [{
    eventId: 'e1',
    matchId: 'm1',
    inningsId: 'inn1',
    overNumber: 0,
    legalBallNumber: 1,
    eventSequence: 1,
    scorerDeviceId: 'dev1',
    strikerId: 'p1',
    nonStrikerId: 'p2',
    bowlerId: 'p6',
    runsBatter: 0,
    isLegal: true,
    previousEventHash: 'GENESIS',
    clientTimestamp: Date.now(),
  }]);

  // Attempting to upload sequence 3 directly (skipping sequence 2)
  const event3 = {
    eventId: 'e3',
    matchId: 'm1',
    inningsId: 'inn1',
    overNumber: 0,
    legalBallNumber: 3,
    eventSequence: 3, // Gap!
    scorerDeviceId: 'dev1',
    strikerId: 'p1',
    nonStrikerId: 'p2',
    bowlerId: 'p6',
    runsBatter: 4,
    isLegal: true,
    previousEventHash: 'e2',
    clientTimestamp: Date.now(),
  };

  const res = await service.syncBatchEvents('m1', 'dev1', [event3]);
  assert.equal(res.rejectedEventIds.length, 1);
  assert.equal(res.hasConflict, true);
  assert.equal(res.latestServerSequence, 1);
});
