import type {
  DeviceClientStatePayload,
  DeviceFanSpeedRpmPayload,
  DeviceMode,
  DeviceSetupPayload,
  DeviceStatus,
} from "../../../shared/types/realtime.types";

export interface DeviceCommandSender {
  sendSwitchState(data: boolean): void;
  sendMode(data: DeviceMode): void;
  sendFanInSpeed(data: number): void;
  sendFanOutSpeed(data: number): void;
}

export interface DeviceActivityReader {
  hasActiveEsp32(): boolean;
}

export interface DeviceStateReader {
  getSetupPayload(): DeviceSetupPayload;
  getFanSpeedRpmPayload(): DeviceFanSpeedRpmPayload;
  getClientStatePayload(): DeviceClientStatePayload;
  getStatus(): DeviceStatus;
}

export interface DeviceStateWriter {
  setFanInSpeed(value: number): void;
  setFanOutSpeed(value: number): void;
  setFanSpeedRpm(value: DeviceFanSpeedRpmPayload): void;
}
