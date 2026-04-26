import { Injectable } from "@nestjs/common";
import { DEVICE_STATUS } from "../../../shared/constants/realtime.constants";
import type { DeviceMode, DeviceSetupPayload, DeviceStatus } from "../../../shared/types/realtime.types";
import type { DeviceStateReader } from "./device-ports";
import type { DeviceInitPayload } from "./device-message.types";

@Injectable()
export class DeviceStateService implements DeviceStateReader {
  private status: DeviceStatus = DEVICE_STATUS.OFFLINE;
  private switchState: boolean | null = null;
  private mode: DeviceMode | null = null;
  private fanInSpd: number | null = null;
  private fanOutSpd: number | null = null;

  getStatus(): DeviceStatus {
    return this.status;
  }

  setStatus(status: DeviceStatus): boolean {
    if (this.status === status) return false;
    this.status = status;
    return true;
  }

  applyInit(payload: DeviceInitPayload): void {
    this.switchState = payload.switchState;
    this.mode = payload.mode;
    this.fanInSpd = payload.fanInSpd;
    this.fanOutSpd = payload.fanOutSpd;
  }

  setSwitchState(value: boolean): void {
    this.switchState = value;
  }

  setMode(value: DeviceMode): void {
    this.mode = value;
  }

  setFanInSpeed(value: number): void {
    this.fanInSpd = value;
  }

  setFanOutSpeed(value: number): void {
    this.fanOutSpd = value;
  }

  getSetupPayload(): DeviceSetupPayload {
    return {
      switchState: this.switchState,
      mode: this.mode,
      fanInSpd: this.fanInSpd,
      fanOutSpd: this.fanOutSpd,
    };
  }
}
