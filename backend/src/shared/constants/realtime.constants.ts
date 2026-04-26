export const DEVICE_KIND = {
  ESP32: "esp32",
  WEB: "web",
  SERVER: "server",
} as const;

export const DEVICE_STATUS = {
  ONLINE: "Online",
  OFFLINE: "Offline",
} as const;

export const DEVICE_MESSAGE_TYPE = {
  PING: "ping",
  INIT: "init",
  UPDATE: "update",
  SWITCH_STATE: "switchState",
  CHANGE_MODE: "changeMode",
  CHANGE_FAN_IN_SPEED: "changeFanInSpd",
  CHANGE_FAN_OUT_SPEED: "changeFanOutSpd",
  IDENTIFY: "identify",
  SETUP: "setup",
  STATUS: "status",
  SENSOR_HISTORY: "sensorHistory",
  PONG: "pong",
} as const;

export const DEVICE_MODE = {
  MANUAL: "manual",
  AUTO: "auto",
  TURBO: "turbo",
} as const;
