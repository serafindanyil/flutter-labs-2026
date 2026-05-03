import { Injectable } from "@nestjs/common";
import { WebSocket } from "ws";
import { DEVICE_KIND, DEVICE_MESSAGE_TYPE } from "../../../shared/constants/realtime.constants";
import type { DeviceMode } from "../../../shared/types/realtime.types";
import type { DeviceActivityReader, DeviceCommandSender } from "../domain/device-ports";

@Injectable()
export class DeviceConnectionRegistry implements DeviceCommandSender, DeviceActivityReader {
  private readonly esp32Clients = new Set<WebSocket>();
  private readonly aliveClients = new WeakMap<WebSocket, boolean>();

  registerEsp32(client: WebSocket): void {
    this.esp32Clients.add(client);
    this.markHeartbeatAlive(client);
  }

  touchEsp32(client: WebSocket): void {
    this.registerEsp32(client);
    this.markHeartbeatAlive(client);
  }

  remove(client: WebSocket): void {
    this.esp32Clients.delete(client);
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
    for (const client of this.esp32Clients) {
      if (client.readyState === WebSocket.OPEN) {
        return true;
      }
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

    for (const client of this.esp32Clients) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    }
  }
}
