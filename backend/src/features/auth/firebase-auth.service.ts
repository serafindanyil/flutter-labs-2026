import { Inject, Injectable } from "@nestjs/common";
import {
  App,
  AppOptions,
  ServiceAccount,
  cert,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import type { AppConfig } from "../../shared/config/app-config.types";
import { FIREBASE_PRIVATE_KEY_NEWLINE } from "../../shared/constants/app.constants";
import { APP_CONFIG_TOKEN } from "../../shared/tokens/di.tokens";
import { isRecord } from "../../shared/utils/is-record";
import type { AuthUser, FirebaseAuthVerifier } from "./auth.types";

function parseServiceAccountJson(value: string | undefined): ServiceAccount | null {
  if (value === undefined || value.trim() === "") return null;

  try {
    const parsed = JSON.parse(value) as unknown;
    if (!isRecord(parsed)) return null;

    const projectId = parsed.project_id ?? parsed.projectId;
    const clientEmail = parsed.client_email ?? parsed.clientEmail;
    const privateKey = parsed.private_key ?? parsed.privateKey;

    if (typeof projectId !== "string" || typeof clientEmail !== "string" || typeof privateKey !== "string") {
      return null;
    }

    return {
      projectId,
      clientEmail,
      privateKey: privateKey.replace(FIREBASE_PRIVATE_KEY_NEWLINE, "\n"),
    };
  } catch {
    return null;
  }
}

function createServiceAccount(config: AppConfig): ServiceAccount | null {
  const fromJson = parseServiceAccountJson(config.firebase.serviceAccountJson);
  if (fromJson !== null) return fromJson;

  if (
    config.firebase.projectId === undefined ||
    config.firebase.clientEmail === undefined ||
    config.firebase.privateKey === undefined
  ) {
    return null;
  }

  return {
    projectId: config.firebase.projectId,
    clientEmail: config.firebase.clientEmail,
    privateKey: config.firebase.privateKey,
  };
}

@Injectable()
export class FirebaseAuthService implements FirebaseAuthVerifier {
  private readonly app: App;

  constructor(@Inject(APP_CONFIG_TOKEN) config: AppConfig) {
    const existingApp = getApps()[0];

    if (existingApp !== undefined) {
      this.app = existingApp;
      return;
    }

    const serviceAccount = createServiceAccount(config);
    const options: AppOptions = {
      projectId: config.firebase.projectId,
      credential: serviceAccount === null ? undefined : cert(serviceAccount),
    };

    this.app = initializeApp(options);
  }

  async verifyToken(token: string): Promise<AuthUser> {
    const decoded = await getAuth(this.app).verifyIdToken(token);

    return {
      uid: decoded.uid,
      email: decoded.email,
      name: typeof decoded.name === "string" ? decoded.name : undefined,
    };
  }
}
