import type { Socket, Server } from "socket.io";
import type { AuthUser } from "../auth/auth.types";
import type { RealtimeSensorUpdate } from "../sensors/domain/sensor.types";
import type { DeviceUpdateStatusPayload, PongPayload } from "../../shared/types/realtime.types";

export interface FrontendClientEvents {
  changeFanInSpd: (data: number) => void;
  changeFanOutSpd: (data: number) => void;
  ping: () => void;
}

export interface FrontendServerEvents {
  updateStatus: (data: DeviceUpdateStatusPayload) => void;
  sensors: (data: RealtimeSensorUpdate) => void;
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
