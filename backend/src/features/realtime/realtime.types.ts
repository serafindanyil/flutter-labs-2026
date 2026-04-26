import type { Socket, Server } from "socket.io";
import type { AuthUser } from "../auth/auth.types";
import type { SensorHistory, SensorUpdate } from "../sensors/domain/sensor.types";
import type { DeviceMode, DeviceSetupPayload, DeviceStatus, PongPayload } from "../../shared/types/realtime.types";

export interface FrontendClientEvents {
  identify: () => void;
  switchState: (data: boolean) => void;
  changeMode: (data: DeviceMode) => void;
  changeFanInSpd: (data: number) => void;
  changeFanOutSpd: (data: number) => void;
  ping: () => void;
}

export interface FrontendServerEvents {
  setup: (data: DeviceSetupPayload) => void;
  status: (data: DeviceStatus) => void;
  sensorHistory: (data: SensorHistory) => void;
  update: (data: SensorUpdate) => void;
  switchState: (data: boolean) => void;
  changeMode: (data: DeviceMode) => void;
  changeFanInSpd: (data: number) => void;
  changeFanOutSpd: (data: number) => void;
  pong: (data: PongPayload) => void;
}

export interface FrontendInterServerEvents {}

export interface FrontendSocketData {
  user?: AuthUser;
}

export type FrontendSocket = Socket<
  FrontendClientEvents,
  FrontendServerEvents,
  FrontendInterServerEvents,
  FrontendSocketData
>;

export type FrontendSocketServer = Server<
  FrontendClientEvents,
  FrontendServerEvents,
  FrontendInterServerEvents,
  FrontendSocketData
>;
