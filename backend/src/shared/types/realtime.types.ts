import type {
  DEVICE_KIND,
  DEVICE_MESSAGE_TYPE,
  DEVICE_MODE,
  DEVICE_POWER_STATE,
  DEVICE_STATUS,
} from "../constants/realtime.constants";
import type { RealtimeSensorUpdate } from "../../features/sensors/domain/sensor.types";

export type DeviceKind = (typeof DEVICE_KIND)[keyof typeof DEVICE_KIND];
export type DeviceStatus = (typeof DEVICE_STATUS)[keyof typeof DEVICE_STATUS];
export type DevicePowerState = (typeof DEVICE_POWER_STATE)[keyof typeof DEVICE_POWER_STATE];
export type DeviceMode = (typeof DEVICE_MODE)[keyof typeof DEVICE_MODE];

export interface DeviceSetupPayload {
  switchState: boolean | null;
  mode: DeviceMode | null;
  fanInSpd: number | null;
  fanOutSpd: number | null;
}

export interface DeviceFanSpeedRpmPayload {
  fanInSpd: number | null;
  fanOutSpd: number | null;
}

export interface DeviceClientStatePayload {
  deviceStatus: DeviceStatus;
  state: DevicePowerState | null;
  mode: DeviceMode | null;
  fanInSpd: number | null;
  fanOutSpd: number | null;
  turboEndsAt: string | null;
}

export type DeviceUpdateStatusPayload = DeviceClientStatePayload;

export interface PongPayload {
  time: number;
}

export type FrontendBroadcast =
  | { type: typeof DEVICE_MESSAGE_TYPE.UPDATE_STATUS; data: DeviceUpdateStatusPayload }
  | { type: typeof DEVICE_MESSAGE_TYPE.SENSORS; data: RealtimeSensorUpdate }
  | { type: typeof DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED; data: number }
  | { type: typeof DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED; data: number }
  | { type: typeof DEVICE_MESSAGE_TYPE.PONG; data: PongPayload };
