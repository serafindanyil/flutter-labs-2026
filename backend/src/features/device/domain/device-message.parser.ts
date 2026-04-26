import { DEVICE_KIND, DEVICE_MODE } from "../../../shared/constants/realtime.constants";
import { isRecord } from "../../../shared/utils/is-record";
import type { DeviceMode } from "../../../shared/types/realtime.types";
import type { DeviceClientEnvelope, DeviceInitPayload, DeviceSensorUpdate } from "./device-message.types";

function getFiniteNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

export function parseDeviceEnvelope(value: unknown): DeviceClientEnvelope | null {
  if (!isRecord(value)) return null;
  const device = value.device;
  const type = value.type;

  if (
    device !== DEVICE_KIND.ESP32 &&
    device !== DEVICE_KIND.WEB &&
    device !== DEVICE_KIND.SERVER
  ) {
    return null;
  }

  if (typeof type !== "string" || type.trim() === "") return null;

  return {
    device,
    type,
    data: value.data,
  };
}

export function parseSensorUpdate(value: unknown): DeviceSensorUpdate | null {
  if (!isRecord(value)) return null;

  const co2 = getFiniteNumber(value.co2);
  const humidity = getFiniteNumber(value.humidity);
  const tempIn = getFiniteNumber(value.tempIn);
  const tempOut = getFiniteNumber(value.tempOut);

  if (co2 === null || humidity === null || tempIn === null || tempOut === null) {
    return null;
  }

  return { co2, humidity, tempIn, tempOut };
}

export function parseInitPayload(value: unknown): DeviceInitPayload | null {
  if (!isRecord(value)) return null;

  const switchState = value.switchState;
  const mode = parseModePayload(value.mode);
  const fanInSpd = getFiniteNumber(value.fanInSpd);
  const fanOutSpd = getFiniteNumber(value.fanOutSpd);

  if (typeof switchState !== "boolean" || mode === null || fanInSpd === null || fanOutSpd === null) {
    return null;
  }

  return {
    switchState,
    mode,
    fanInSpd,
    fanOutSpd,
  };
}

export function parseBooleanPayload(value: unknown): boolean | null {
  return typeof value === "boolean" ? value : null;
}

export function parseModePayload(value: unknown): DeviceMode | null {
  if (
    value === DEVICE_MODE.MANUAL ||
    value === DEVICE_MODE.AUTO ||
    value === DEVICE_MODE.TURBO
  ) {
    return value;
  }

  return null;
}

export function parseSpeedPayload(value: unknown): number | null {
  return getFiniteNumber(value);
}
