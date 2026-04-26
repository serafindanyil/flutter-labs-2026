import type { SensorUpdate } from "../../sensors/domain/sensor.types";
import type { DeviceKind, DeviceMode } from "../../../shared/types/realtime.types";

export interface DeviceClientEnvelope {
  device: DeviceKind;
  type: string;
  data?: unknown;
}

export interface DeviceInitPayload {
  switchState: boolean;
  mode: DeviceMode;
  fanInSpd: number;
  fanOutSpd: number;
}

export type DeviceSensorUpdate = SensorUpdate;
