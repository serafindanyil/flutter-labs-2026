import { Injectable } from "@nestjs/common";
import { DEVICE_SWITCH_STATE_COMMAND_STALE_MS } from "../../../shared/constants/app.constants";
import { DEVICE_MODE, DEVICE_POWER_STATE, DEVICE_STATUS } from "../../../shared/constants/realtime.constants";
import type {
  DeviceClientStatePayload,
  DeviceFanSpeedRpmPayload,
  DeviceMode,
  DevicePowerState,
  DeviceSetupPayload,
  DeviceStatus,
} from "../../../shared/types/realtime.types";
import type { DeviceStateReader } from "./device-ports";
import type { DeviceInitPayload } from "./device-message.types";

@Injectable()
export class DeviceStateService implements DeviceStateReader {
  private status: DeviceStatus = DEVICE_STATUS.OFFLINE;
  private switchState: boolean | null = null;
  private mode: DeviceMode | null = null;
  private fanInSpd: number | null = null;
  private fanOutSpd: number | null = null;
  private fanInRpm: number | null = null;
  private fanOutRpm: number | null = null;
  private turboEndsAt: Date | null = null;
  private pendingSwitchStateCommand: { value: boolean; expiresAt: number } | null = null;

  getStatus(): DeviceStatus {
    return this.status;
  }

  setStatus(status: DeviceStatus): boolean {
    if (this.status === status) return false;
    this.status = status;
    return true;
  }

  applyInit(payload: DeviceInitPayload): void {
    this.pendingSwitchStateCommand = null;
    this.switchState = payload.switchState;
    this.mode = payload.mode;
    this.fanInSpd = payload.fanInSpd;
    this.fanOutSpd = payload.fanOutSpd;
  }

  setSwitchStateFromCommand(value: boolean): void {
    this.switchState = value;
    this.pendingSwitchStateCommand = {
      value,
      expiresAt: Date.now() + DEVICE_SWITCH_STATE_COMMAND_STALE_MS,
    };
  }

  setSwitchStateFromDevice(value: boolean): boolean {
    const pending = this.pendingSwitchStateCommand;

    if (pending !== null) {
      if (Date.now() > pending.expiresAt) {
        this.pendingSwitchStateCommand = null;
      } else if (value !== pending.value) {
        return false;
      } else {
        this.pendingSwitchStateCommand = null;
      }
    }

    this.switchState = value;
    return true;
  }

  setMode(value: DeviceMode): void {
    this.mode = value;
    if (value !== DEVICE_MODE.TURBO) {
      this.turboEndsAt = null;
    }
  }

  setFanInSpeed(value: number): void {
    this.fanInSpd = value;
  }

  setFanOutSpeed(value: number): void {
    this.fanOutSpd = value;
  }

  setFanSpeedRpm(value: DeviceFanSpeedRpmPayload): void {
    this.fanInRpm = value.fanInSpd;
    this.fanOutRpm = value.fanOutSpd;
  }

  setTurboEndsAt(value: Date | null): void {
    this.turboEndsAt = value;
  }

  getSetupPayload(): DeviceSetupPayload {
    return {
      switchState: this.switchState,
      mode: this.mode,
      fanInSpd: this.fanInSpd,
      fanOutSpd: this.fanOutSpd,
    };
  }

  getFanSpeedRpmPayload(): DeviceFanSpeedRpmPayload {
    return {
      fanInSpd: this.fanInRpm,
      fanOutSpd: this.fanOutRpm,
    };
  }

  getClientStatePayload(): DeviceClientStatePayload {
    return {
      deviceStatus: this.status,
      state: this.toPowerState(this.switchState),
      mode: this.mode,
      fanInSpd: this.fanInSpd,
      fanOutSpd: this.fanOutSpd,
      turboEndsAt: this.turboEndsAt?.toISOString() ?? null,
    };
  }

  private toPowerState(value: boolean | null): DevicePowerState | null {
    if (value === null) return null;
    return value ? DEVICE_POWER_STATE.ON : DEVICE_POWER_STATE.OFF;
  }
}
