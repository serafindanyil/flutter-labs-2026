import { Injectable } from "@nestjs/common";
import { WebSocket } from "ws";
import { ESP32_TIMEOUT_MS } from "../../../shared/constants/app.constants";
import { DEVICE_KIND, DEVICE_MESSAGE_TYPE } from "../../../shared/constants/realtime.constants";
import type { DeviceMode } from "../../../shared/types/realtime.types";
import type { DeviceActivityReader, DeviceCommandSender } from "../domain/device-ports";

@Injectable()
export class DeviceConnectionRegistry implements DeviceCommandSender, DeviceActivityReader {
  private readonly esp32LastUpdate = new Map<WebSocket, number>();
  private readonly aliveClients = new WeakMap<WebSocket, boolean>();

  registerEsp32(client: WebSocket): void {
    if (!this.esp32LastUpdate.has(client)) {
      this.esp32LastUpdate.set(client, 0);
    }
    this.markHeartbeatAlive(client);
  }

  touchEsp32(client: WebSocket): void {
    this.esp32LastUpdate.set(client, Date.now());
    this.markHeartbeatAlive(client);
  }

  remove(client: WebSocket): void {
    this.esp32LastUpdate.delete(client);
  }

  markHeartbeatAlive(client: WebSocket): void {
    this.aliveClients.set(client, true);
  }

  markHeartbeatPending(client: WebSocket): void {
    this.aliveClients.set(client, false);
  }

  isHeartbeatAlive(client: WebSocket): boolean {
    return this.aliveClients.get(client) !== false;
  }

  hasActiveEsp32(): boolean {
    const currentTime = Date.now();

    for (const [client, lastUpdate] of this.esp32LastUpdate.entries()) {
      const isOpen = client.readyState === WebSocket.OPEN;
      const isRecent = currentTime - lastUpdate < ESP32_TIMEOUT_MS;
      if (isOpen && isRecent) return true;
    }

    return false;
  }

  sendSwitchState(data: boolean): void {
    this.sendToAll(DEVICE_MESSAGE_TYPE.SWITCH_STATE, data);
  }

  sendMode(data: DeviceMode): void {
    this.sendToAll(DEVICE_MESSAGE_TYPE.CHANGE_MODE, data);
  }

  sendFanInSpeed(data: number): void {
    this.sendToAll(DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED, data);
  }

  sendFanOutSpeed(data: number): void {
    this.sendToAll(DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED, data);
  }

  private sendToAll(type: string, data: unknown): void {
    const message = JSON.stringify({
      device: DEVICE_KIND.SERVER,
      type,
      data,
    });

    for (const client of this.esp32LastUpdate.keys()) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    }
  }
}
