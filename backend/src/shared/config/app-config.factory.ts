import { DEFAULT_HOST, DEFAULT_PORT, FIREBASE_PRIVATE_KEY_NEWLINE } from "../constants/app.constants";
import type { AppConfig } from "./app-config.types";

function toNumber(value: string | undefined, fallback: number): number {
  if (value === undefined || value.trim() === "") return fallback;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function toCorsOrigin(value: string | undefined): string | boolean {
  if (value === undefined || value.trim() === "") return true;
  return value;
}

function toPrivateKey(value: string | undefined): string | undefined {
  if (value === undefined || value.trim() === "") return undefined;
  return value.replace(FIREBASE_PRIVATE_KEY_NEWLINE, "\n");
}

export function createAppConfig(): AppConfig {
  return {
    port: toNumber(process.env.PORT, DEFAULT_PORT),
    host: process.env.HOST ?? DEFAULT_HOST,
    nodeEnv: process.env.NODE_ENV ?? "development",
    corsOrigin: toCorsOrigin(process.env.CORS_ORIGIN),
    databaseUrl: process.env.DATABASE_URL ?? "",
    firebase: {
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: toPrivateKey(process.env.FIREBASE_PRIVATE_KEY),
      serviceAccountJson: process.env.FIREBASE_SERVICE_ACCOUNT_JSON,
    },
  };
}
