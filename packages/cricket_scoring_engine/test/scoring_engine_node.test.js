import test from 'node:test';
import assert from 'node:assert/strict';

// Node.js implementation matching pure Dart CricketScoringEngine logic
class CricketEngineNode {
  constructor(config, teamA, teamB, tossWinnerId, tossDecision, strikerId, nonStrikerId, bowlerId) {
    this.config = config;
    this.teamA = teamA;
    this.teamB = teamB;
    this.battingTeamId = tossDecision === 'BAT' ? tossWinnerId : (tossWinnerId === teamA.id ? teamB.id : teamA.id);
    this.bowlingTeamId = this.battingTeamId === teamA.id ? teamB.id : teamA.id;

    this.innings = [{
      inningsId: 'inn_1',
      battingTeamId: this.battingTeamId,
      bowlingTeamId: this.bowlingTeamId,
      totalRuns: 0,
      totalWickets: 0,
      legalBallsBowled: 0,
      strikerId,
      nonStrikerId,
      currentBowlerId: bowlerId,
      isCompleted: false,
    }];
    this.events = [];
  }

  get activeInnings() {
    return this.innings[0];
  }

  recordDelivery({ runsBatter = 0, extrasType = 'NONE', extrasRuns = 0, isBoundaryFour = false, isBoundarySix = false, wicket = null }) {
    const inn = this.activeInnings;
    let isLegal = true;
    let teamExtras = 0;
    let bRuns = runsBatter;
    let bowlerConceded = 0;

    if (extrasType === 'WIDE') {
      isLegal = false;
      teamExtras = 1 + extrasRuns;
      bRuns = 0;
      bowlerConceded = teamExtras;
    } else if (extrasType === 'NO_BALL') {
      isLegal = false;
      teamExtras = 1 + extrasRuns;
      bowlerConceded = 1 + bRuns;
    } else if (extrasType === 'BYE' || extrasType === 'LEG_BYE') {
      isLegal = true;
      teamExtras = extrasRuns;
      bRuns = 0;
      bowlerConceded = 0;
    } else {
      isLegal = true;
      teamExtras = 0;
      bowlerConceded = bRuns;
    }

    const totalRuns = bRuns + teamExtras;
    inn.totalRuns += totalRuns;
    if (isLegal) inn.legalBallsBowled += 1;
    if (wicket) inn.totalWickets += 1;

    // Strike rotation logic
    let runningRuns = (extrasType === 'NONE' || extrasType === 'NO_BALL') ? bRuns : teamExtras;
    let shouldRotate = (runningRuns % 2 !== 0);

    if (shouldRotate) {
      const tmp = inn.strikerId;
      inn.strikerId = inn.nonStrikerId;
      inn.nonStrikerId = tmp;
    }

    // End of over rotation
    const isEndOfOver = isLegal && (inn.legalBallsBowled % this.config.ballsPerOver === 0);
    if (isEndOfOver) {
      const tmp = inn.strikerId;
      inn.strikerId = inn.nonStrikerId;
      inn.nonStrikerId = tmp;
    }

    const event = { totalRuns, isLegal, strikerId: inn.strikerId, nonStrikerId: inn.nonStrikerId };
    this.events.push(event);
    return event;
  }
}

test('Dot ball calculation', () => {
  const engine = new CricketEngineNode({ ballsPerOver: 6 }, { id: 'IND' }, { id: 'AUS' }, 'IND', 'BAT', 'p1', 'p2', 'p6');
  engine.recordDelivery({ runsBatter: 0 });
  assert.equal(engine.activeInnings.totalRuns, 0);
  assert.equal(engine.activeInnings.legalBallsBowled, 1);
  assert.equal(engine.activeInnings.strikerId, 'p1');
});

test('Single run switches strike', () => {
  const engine = new CricketEngineNode({ ballsPerOver: 6 }, { id: 'IND' }, { id: 'AUS' }, 'IND', 'BAT', 'p1', 'p2', 'p6');
  engine.recordDelivery({ runsBatter: 1 });
  assert.equal(engine.activeInnings.totalRuns, 1);
  assert.equal(engine.activeInnings.strikerId, 'p2');
  assert.equal(engine.activeInnings.nonStrikerId, 'p1');
});

test('Wide ball extra run without legal ball increment', () => {
  const engine = new CricketEngineNode({ ballsPerOver: 6 }, { id: 'IND' }, { id: 'AUS' }, 'IND', 'BAT', 'p1', 'p2', 'p6');
  engine.recordDelivery({ extrasType: 'WIDE' });
  assert.equal(engine.activeInnings.totalRuns, 1);
  assert.equal(engine.activeInnings.legalBallsBowled, 0);
});

test('End of over rotates strike automatically', () => {
  const engine = new CricketEngineNode({ ballsPerOver: 6 }, { id: 'IND' }, { id: 'AUS' }, 'IND', 'BAT', 'p1', 'p2', 'p6');
  for (let i = 0; i < 6; i++) {
    engine.recordDelivery({ runsBatter: 0 });
  }
  assert.equal(engine.activeInnings.legalBallsBowled, 6);
  assert.equal(engine.activeInnings.strikerId, 'p2');
  assert.equal(engine.activeInnings.nonStrikerId, 'p1');
});
