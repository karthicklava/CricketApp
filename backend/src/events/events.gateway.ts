import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'live-score',
})
export class EventsGateway {
  @WebSocketServer()
  server: Server;

  @SubscribeMessage('join_match')
  handleJoinMatch(
    @MessageBody() data: { matchId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`match_${data.matchId}`);
    return { status: 'joined', matchId: data.matchId };
  }

  broadcastScoreUpdate(matchId: string, payload: any) {
    this.server.to(`match_${matchId}`).emit('score_update', payload);
  }
}
