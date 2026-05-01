import { DEVICE_KIND, DEVICE_MODE } from "../../../shared/constants/realtime.constants";
import {
  MAX_FAN_SPEED_PERCENT,
  MAX_FAN_SPEED_RPM,
  MIN_FAN_SPEED_PERCENT,
  MIN_FAN_SPEED_RPM,
} from "../../../shared/constants/app.constants";
import { isRecord } from "../../../shared/utils/is-record";
import type { DeviceMode } from "../../../shared/types/realtime.types";
import type {
  DeviceClientEnvelope,
  DeviceFanSpeedRpmUpdate,
  DeviceInitPayload,
  DeviceSensorUpdate,
} from "./device-message.types";

function getFiniteNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function getFiniteNumberLike(value: unknown): number | null {
  if (typeof value === "number") return getFiniteNumber(value);
  if (typeof value !== "string" || value.trim() === "") return null;

  const parsed = Number(value);
  return getFiniteNumber(parsed);
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
  const speed = parseSpeedValue(value);
  if (speed === null) return null;
  if (!Number.isInteger(speed)) return null;
  if (speed < MIN_FAN_SPEED_PERCENT || speed > MAX_FAN_SPEED_PERCENT) return null;
  return speed;
}

function parseSpeedValue(value: unknown): number | null {
  return getFiniteNumberLike(value);
}

export function parseFanSpeedRpmPayload(value: unknown): DeviceFanSpeedRpmUpdate | null {
  if (!isRecord(value)) return null;

  const fanInSpd = parseRpmValue(value.fanInSpd ?? value.fanInRpm);
  const fanOutSpd = parseRpmValue(value.fanOutSpd ?? value.fanOutRpm);

  if (fanInSpd === null || fanOutSpd === null) return null;

  return {
    fanInSpd,
    fanOutSpd,
  };
}

function parseRpmValue(value: unknown): number | null {
  const rpm = getFiniteNumberLike(value);
  if (rpm === null) return null;
  if (!Number.isInteger(rpm)) return null;
  if (rpm < MIN_FAN_SPEED_RPM || rpm > MAX_FAN_SPEED_RPM) return null;
  return rpm;
}
