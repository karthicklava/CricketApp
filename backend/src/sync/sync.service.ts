import { Injectable, ConflictException, BadRequestException } from '@nestjs/common';

export interface DeliveryPayload {
  eventId: string;
  matchId: string;
  inningsId: string;
  overNumber: number;
  legalBallNumber: number;
  eventSequence: number;
  scorerDeviceId: string;
  strikerId: string;
  nonStrikerId: string;
  bowlerId: string;
  runsBatter: number;
  extrasType?: string;
  extrasRuns?: number;
  isLegal: boolean;
  isBoundaryFour?: boolean;
  isBoundarySix?: boolean;
  wicketType?: string;
  dismissedPlayerId?: string;
  fielderId?: string;
  previousEventHash: string;
  clientTimestamp: number;
}

@Injectable()
export class SyncService {
  // In-memory / DB store for processed events & sequences
  private processedEvents = new Map<string, DeliveryPayload>();
  private matchSequences = new Map<string, number>();

  async syncBatchEvents(matchId: string, deviceId: string, events: DeliveryPayload[]) {
    const acceptedEventIds: string[] = [];
    const rejectedEventIds: string[] = [];
    let currentServerSeq = this.matchSequences.get(matchId) || 0;

    // Sort incoming events by sequence number
    events.sort((a, b) => a.eventSequence - b.eventSequence);

    for (const ev of events) {
      // 1. Idempotency Check: if eventId already processed, mark as accepted (idempotent duplicate drop)
      if (this.processedEvents.has(ev.eventId)) {
        acceptedEventIds.push(ev.eventId);
        continue;
      }

      // 2. Sequence Continuity Validation
      const expectedSeq = currentServerSeq + 1;
      if (ev.eventSequence !== expectedSeq && currentServerSeq !== 0) {
        // Sequence gap or conflict detected
        rejectedEventIds.push(ev.eventId);
        continue;
      }

      // 3. Accept Event
      this.processedEvents.set(ev.eventId, ev);
      currentServerSeq = ev.eventSequence;
      this.matchSequences.set(matchId, currentServerSeq);
      acceptedEventIds.push(ev.eventId);
    }

    return {
      matchId,
      acceptedEventIds,
      rejectedEventIds,
      latestServerSequence: currentServerSeq,
      hasConflict: rejectedEventIds.length > 0,
    };
  }

  getLatestSequence(matchId: string): number {
    return this.matchSequences.get(matchId) || 0;
  }
}
