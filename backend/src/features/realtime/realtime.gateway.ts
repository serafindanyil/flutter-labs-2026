import { Inject, Injectable, Logger } from "@nestjs/common";
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayInit,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from "@nestjs/websockets";
import { OnEvent } from "@nestjs/event-emitter";
import type { ExtendedError } from "socket.io";
import { DEVICE_MESSAGE_TYPE, DEVICE_MODE } from "../../shared/constants/realtime.constants";
import { EVENT_NAMES } from "../../shared/events/event-names";
import {
  DEVICE_ACTIVITY_READER_TOKEN,
  DEVICE_COMMAND_SENDER_TOKEN,
  DEVICE_STATE_READER_TOKEN,
  DEVICE_STATE_WRITER_TOKEN,
  FIREBASE_AUTH_VERIFIER_TOKEN,
} from "../../shared/tokens/di.tokens";
import { isRecord } from "../../shared/utils/is-record";
import type { FrontendBroadcast } from "../../shared/types/realtime.types";
import type { FirebaseAuthVerifier } from "../auth/auth.types";
import {
  FIREBASE_AUTH_ERROR_CODE,
  FirebaseAuthErrorCode,
  getFirebaseAuthErrorMessage,
  mapFirebaseAuthErrorCode,
} from "../auth/firebase-auth-errors";
import { parseSpeedPayload } from "../device/domain/device-message.parser";
import type {
  DeviceActivityReader,
  DeviceCommandSender,
  DeviceStateReader,
  DeviceStateWriter,
} from "../device/domain/device-ports";
import type { FrontendSocket, FrontendSocketServer } from "./realtime.types";

function extractBearerToken(value: string | undefined): string | null {
  if (value === undefined) return null;
  const [scheme, token] = value.split(" ");
  if (scheme !== "Bearer" || token === undefined || token.trim() === "") return null;
  return token;
}

function extractHandshakeToken(client: FrontendSocket): string | null {
  const headerToken = extractBearerToken(client.handshake.headers.authorization);
  if (headerToken !== null) return headerToken;

  const auth = client.handshake.auth;

  if (isRecord(auth) && typeof auth.token === "string" && auth.token.trim() !== "") {
    return auth.token;
  }

  return null;
}

function isAuthenticated(client: FrontendSocket): boolean {
  return client.data.user !== undefined;
}

interface RealtimeAuthErrorData {
  code: FirebaseAuthErrorCode;
}

class RealtimeAuthError extends Error implements ExtendedError {
  readonly data: RealtimeAuthErrorData;

  constructor(code: FirebaseAuthErrorCode) {
    super(getFirebaseAuthErrorMessage(code));
    this.data = { code };
  }
}

@Injectable()
@WebSocketGateway({
  cors: { origin: true },
  perMessageDeflate: false,
  httpCompression: false,
})
export class RealtimeGateway implements OnGatewayInit, OnGatewayConnection {
  private readonly logger = new Logger(RealtimeGateway.name);
  private lastUpdateStatusPayload: string | null = null;

  @WebSocketServer()
  private server!: FrontendSocketServer;

  constructor(
    @Inject(FIREBASE_AUTH_VERIFIER_TOKEN) private readonly verifier: FirebaseAuthVerifier,
    @Inject(DEVICE_COMMAND_SENDER_TOKEN) private readonly commandSender: DeviceCommandSender,
    @Inject(DEVICE_ACTIVITY_READER_TOKEN) private readonly activityReader: DeviceActivityReader,
    @Inject(DEVICE_STATE_READER_TOKEN) private readonly stateReader: DeviceStateReader,
    @Inject(DEVICE_STATE_WRITER_TOKEN) private readonly stateWriter: DeviceStateWriter,
  ) {}

  afterInit(server: FrontendSocketServer): void {
    server.use(async (client, next) => {
      const token = extractHandshakeToken(client);

      if (token === null) {
        next(new RealtimeAuthError(FIREBASE_AUTH_ERROR_CODE.MISSING_BEARER));
        return;
      }

      try {
        client.data.user = await this.verifier.verifyToken(token);
        next();
      } catch (error: unknown) {
        const code = mapFirebaseAuthErrorCode(error);
        this.logger.warn(`Socket.IO client rejected by Firebase auth: ${code}`);
        next(new RealtimeAuthError(code));
      }
    });
  }

  handleConnection(client: FrontendSocket): void {
    const token = extractHandshakeToken(client);

    if (token === null) {
      client.disconnect(true);
      return;
    }

    client.emit(DEVICE_MESSAGE_TYPE.UPDATE_STATUS, this.stateReader.getClientStatePayload());
  }

  @SubscribeMessage(DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED)
  handleFanInSpeed(
    @ConnectedSocket() client: FrontendSocket,
    @MessageBody() data: unknown,
  ): void {
    if (!isAuthenticated(client)) return;
    const payload = parseSpeedPayload(data);
    if (payload === null) return;
    if (!this.activityReader.hasActiveEsp32()) {
      client.emit(DEVICE_MESSAGE_TYPE.UPDATE_STATUS, this.stateReader.getClientStatePayload());
      return;
    }
    if (!this.isManualMode()) return;
    this.stateWriter.setFanInSpeed(payload);
    this.commandSender.sendFanInSpeed(payload);
    this.emitToAuthenticated((socket) => socket.emit(DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED, payload));
    this.emitCurrentUpdateStatus();
  }

  @SubscribeMessage(DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED)
  handleFanOutSpeed(
    @ConnectedSocket() client: FrontendSocket,
    @MessageBody() data: unknown,
  ): void {
    if (!isAuthenticated(client)) return;
    const payload = parseSpeedPayload(data);
    if (payload === null) return;
    if (!this.activityReader.hasActiveEsp32()) {
      client.emit(DEVICE_MESSAGE_TYPE.UPDATE_STATUS, this.stateReader.getClientStatePayload());
      return;
    }
    if (!this.isManualMode()) return;
    this.stateWriter.setFanOutSpeed(payload);
    this.commandSender.sendFanOutSpeed(payload);
    this.emitToAuthenticated((socket) => socket.emit(DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED, payload));
    this.emitCurrentUpdateStatus();
  }

  @SubscribeMessage(DEVICE_MESSAGE_TYPE.PING)
  handlePing(@ConnectedSocket() client: FrontendSocket): void {
    if (!isAuthenticated(client)) return;
    client.emit(DEVICE_MESSAGE_TYPE.PONG, { time: Date.now() });
  }

  @OnEvent(EVENT_NAMES.FRONTEND_BROADCAST)
  handleBroadcast(payload: FrontendBroadcast): void {
    switch (payload.type) {
      case DEVICE_MESSAGE_TYPE.UPDATE_STATUS:
        this.emitUpdateStatusPayload(payload.data);
        break;
      case DEVICE_MESSAGE_TYPE.SENSORS:
        this.emitToAuthenticated((client) => client.emit(DEVICE_MESSAGE_TYPE.SENSORS, payload.data));
        break;
      case DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED:
        this.emitToAuthenticated((client) => client.emit(DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED, payload.data));
        break;
      case DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED:
        this.emitToAuthenticated((client) => client.emit(DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED, payload.data));
        break;
      case DEVICE_MESSAGE_TYPE.PONG:
        this.emitToAuthenticated((client) => client.emit(DEVICE_MESSAGE_TYPE.PONG, payload.data));
        break;
    }
  }

  private emitToAuthenticated(handler: (client: FrontendSocket) => void): void {
    for (const client of this.server.sockets.sockets.values()) {
      if (isAuthenticated(client)) {
        handler(client);
      }
    }
  }

  private emitCurrentUpdateStatus(): void {
    const payload = this.stateReader.getClientStatePayload();
    this.emitUpdateStatusPayload(payload);
  }

  private emitUpdateStatusPayload(payload: FrontendBroadcast["data"]): void {
    if (!this.isUpdateStatusPayload(payload)) return;

    const snapshot = JSON.stringify(payload);
    if (snapshot === this.lastUpdateStatusPayload) return;

    this.lastUpdateStatusPayload = snapshot;
    this.emitToAuthenticated((client) => client.emit(DEVICE_MESSAGE_TYPE.UPDATE_STATUS, payload));
  }

  private isUpdateStatusPayload(payload: FrontendBroadcast["data"]): payload is Extract<
    FrontendBroadcast,
    { type: typeof DEVICE_MESSAGE_TYPE.UPDATE_STATUS }
  >["data"] {
    return isRecord(payload) && "deviceStatus" in payload;
  }

  private isManualMode(): boolean {
    return this.stateReader.getClientStatePayload().mode === DEVICE_MODE.MANUAL;
  }
}
