import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from "@nestjs/common";
import { EventEmitter2 } from "@nestjs/event-emitter";
import { HttpAdapterHost } from "@nestjs/core";
import type { Server } from "http";
import { RawData, WebSocket, WebSocketServer } from "ws";
import {
  HEARTBEAT_INTERVAL_MS,
  RAW_WS_PATH,
  STATUS_CHECK_INTERVAL_MS,
} from "../../../shared/constants/app.constants";
import { DEVICE_KIND, DEVICE_MESSAGE_TYPE, DEVICE_STATUS } from "../../../shared/constants/realtime.constants";
import { EVENT_NAMES } from "../../../shared/events/event-names";
import type { FrontendBroadcast } from "../../../shared/types/realtime.types";
import {
  parseBooleanPayload,
  parseDeviceEnvelope,
  parseInitPayload,
  parseModePayload,
  parseSensorUpdate,
  parseSpeedPayload,
} from "../domain/device-message.parser";
import { DeviceStateService } from "../domain/device-state.service";
import { DeviceConnectionRegistry } from "./device-connection.registry";

@Injectable()
export class RawDeviceWebSocketService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RawDeviceWebSocketService.name);
  private webSocketServer: WebSocketServer | null = null;
  private statusInterval: NodeJS.Timeout | null = null;
  private heartbeatInterval: NodeJS.Timeout | null = null;

  constructor(
    private readonly adapterHost: HttpAdapterHost,
    private readonly registry: DeviceConnectionRegistry,
    private readonly state: DeviceStateService,
    private readonly events: EventEmitter2,
  ) {}

  onModuleInit(): void {
    const httpServer = this.adapterHost.httpAdapter.getHttpServer() as Server;
    this.webSocketServer = new WebSocketServer({ server: httpServer, path: RAW_WS_PATH });

    this.webSocketServer.on("connection", (client, request) => {
      this.logger.log(`Client connected to raw websocket: ${request.socket.remoteAddress ?? "unknown"}`);
      this.handleConnection(client);
    });

    this.statusInterval = setInterval(() => this.checkAndBroadcastStatus(), STATUS_CHECK_INTERVAL_MS);
    this.heartbeatInterval = setInterval(() => this.checkHeartbeat(), HEARTBEAT_INTERVAL_MS);
    this.logger.log(`Raw ESP32 websocket available on ${RAW_WS_PATH}`);
  }

  onModuleDestroy(): void {
    if (this.statusInterval !== null) clearInterval(this.statusInterval);
    if (this.heartbeatInterval !== null) clearInterval(this.heartbeatInterval);
    this.webSocketServer?.close();
  }

  private handleConnection(client: WebSocket): void {
    this.registry.markHeartbeatAlive(client);

    client.on("pong", () => {
      this.registry.markHeartbeatAlive(client);
    });

    client.on("message", (message) => {
      this.handleMessage(client, message);
    });

    client.on("close", () => {
      this.handleDisconnect(client);
    });

    client.on("error", () => {
      this.handleDisconnect(client);
    });
  }

  private handleMessage(client: WebSocket, message: RawData): void {
    const parsed = this.parseJson(message);
    const envelope = parseDeviceEnvelope(parsed);

    if (envelope === null || envelope.device !== DEVICE_KIND.ESP32) return;

    this.registry.registerEsp32(client);

    switch (envelope.type) {
      case DEVICE_MESSAGE_TYPE.PING:
        client.send(JSON.stringify({ type: DEVICE_MESSAGE_TYPE.PONG, time: Date.now() }));
        break;
      case DEVICE_MESSAGE_TYPE.UPDATE:
        this.handleSensorUpdate(client, envelope.data);
        break;
      case DEVICE_MESSAGE_TYPE.SWITCH_STATE:
        this.handleSwitchState(client, envelope.data);
        break;
      case DEVICE_MESSAGE_TYPE.CHANGE_MODE:
        this.handleMode(client, envelope.data);
        break;
      case DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED:
        this.handleFanInSpeed(client, envelope.data);
        break;
      case DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED:
        this.handleFanOutSpeed(client, envelope.data);
        break;
      case DEVICE_MESSAGE_TYPE.INIT:
        this.handleInit(client, envelope.data);
        break;
      default:
        this.logger.warn(`Unknown ESP32 message type: ${envelope.type}`);
        break;
    }
  }

  private handleSensorUpdate(client: WebSocket, data: unknown): void {
    const payload = parseSensorUpdate(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.events.emit(EVENT_NAMES.DEVICE_SENSOR_UPDATED, payload);
    this.checkAndBroadcastStatus();
  }

  private handleSwitchState(client: WebSocket, data: unknown): void {
    const payload = parseBooleanPayload(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.state.setSwitchState(payload);
    this.broadcast({ type: DEVICE_MESSAGE_TYPE.SWITCH_STATE, data: payload });
    this.checkAndBroadcastStatus();
  }

  private handleMode(client: WebSocket, data: unknown): void {
    const payload = parseModePayload(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.state.setMode(payload);
    this.broadcast({ type: DEVICE_MESSAGE_TYPE.CHANGE_MODE, data: payload });
    this.checkAndBroadcastStatus();
  }

  private handleFanInSpeed(client: WebSocket, data: unknown): void {
    const payload = parseSpeedPayload(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.state.setFanInSpeed(payload);
    this.broadcast({ type: DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED, data: payload });
    this.checkAndBroadcastStatus();
  }

  private handleFanOutSpeed(client: WebSocket, data: unknown): void {
    const payload = parseSpeedPayload(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.state.setFanOutSpeed(payload);
    this.broadcast({ type: DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED, data: payload });
    this.checkAndBroadcastStatus();
  }

  private handleInit(client: WebSocket, data: unknown): void {
    const payload = parseInitPayload(data);
    if (payload === null) return;
    this.registry.touchEsp32(client);
    this.state.applyInit(payload);
    this.checkAndBroadcastStatus();
  }

  private handleDisconnect(client: WebSocket): void {
    this.registry.remove(client);
    setTimeout(() => this.checkAndBroadcastStatus(), 100);
  }

  private checkAndBroadcastStatus(): void {
    const status = this.registry.hasActiveEsp32() ? DEVICE_STATUS.ONLINE : DEVICE_STATUS.OFFLINE;
    const changed = this.state.setStatus(status);

    if (!changed) return;

    this.events.emit(EVENT_NAMES.DEVICE_STATUS_CHANGED, status);
    this.broadcast({ type: DEVICE_MESSAGE_TYPE.STATUS, data: status });
  }

  private checkHeartbeat(): void {
    const server = this.webSocketServer;
    if (server === null) return;

    for (const client of server.clients) {
      if (!this.registry.isHeartbeatAlive(client)) {
        client.terminate();
        this.registry.remove(client);
        continue;
      }

      this.registry.markHeartbeatPending(client);
      client.ping();
    }
  }

  private broadcast(payload: FrontendBroadcast): void {
    this.events.emit(EVENT_NAMES.FRONTEND_BROADCAST, payload);
  }

  private parseJson(message: RawData): unknown {
    try {
      return JSON.parse(this.toText(message)) as unknown;
    } catch {
      return null;
    }
  }

  private toText(message: RawData): string {
    if (typeof message === "string") return message;
    if (message instanceof ArrayBuffer) return Buffer.from(message).toString("utf8");
    if (Array.isArray(message)) return Buffer.concat(message).toString("utf8");
    return message.toString("utf8");
  }
}
