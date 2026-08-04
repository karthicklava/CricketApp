import { Controller, Post, Param, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { SyncService, DeliveryPayload } from './sync.service';

@Controller('api/v1/matches')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post(':matchId/events/sync')
  @HttpCode(HttpStatus.OK)
  async syncEvents(
    @Param('matchId') matchId: string,
    @Body() body: { deviceId: string; events: DeliveryPayload[] },
  ) {
    return this.syncService.syncBatchEvents(matchId, body.deviceId, body.events);
  }
}
