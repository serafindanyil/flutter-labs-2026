import type { DEVICE_KIND, DEVICE_MESSAGE_TYPE, DEVICE_MODE, DEVICE_STATUS } from "../constants/realtime.constants";
import type { SensorHistory, SensorUpdate } from "../../features/sensors/domain/sensor.types";

export type DeviceKind = (typeof DEVICE_KIND)[keyof typeof DEVICE_KIND];
export type DeviceStatus = (typeof DEVICE_STATUS)[keyof typeof DEVICE_STATUS];
export type DeviceMode = (typeof DEVICE_MODE)[keyof typeof DEVICE_MODE];

export interface DeviceSetupPayload {
  switchState: boolean | null;
  mode: DeviceMode | null;
  fanInSpd: number | null;
  fanOutSpd: number | null;
}

export interface PongPayload {
  time: number;
}

export type FrontendBroadcast =
  | { type: typeof DEVICE_MESSAGE_TYPE.SETUP; data: DeviceSetupPayload }
  | { type: typeof DEVICE_MESSAGE_TYPE.STATUS; data: DeviceStatus }
  | { type: typeof DEVICE_MESSAGE_TYPE.SENSOR_HISTORY; data: SensorHistory }
  | { type: typeof DEVICE_MESSAGE_TYPE.UPDATE; data: SensorUpdate }
  | { type: typeof DEVICE_MESSAGE_TYPE.SWITCH_STATE; data: boolean }
  | { type: typeof DEVICE_MESSAGE_TYPE.CHANGE_MODE; data: DeviceMode }
  | { type: typeof DEVICE_MESSAGE_TYPE.CHANGE_FAN_IN_SPEED; data: number }
  | { type: typeof DEVICE_MESSAGE_TYPE.CHANGE_FAN_OUT_SPEED; data: number }
  | { type: typeof DEVICE_MESSAGE_TYPE.PONG; data: PongPayload };
