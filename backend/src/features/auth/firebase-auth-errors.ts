import { isRecord } from "../../shared/utils/is-record";

export const FIREBASE_AUTH_ERROR_CODE = {
  MISSING_BEARER: "auth/missing-bearer",
  ID_TOKEN_EXPIRED: "auth/id-token-expired",
  ID_TOKEN_INVALID: "auth/id-token-invalid",
} as const;

export const FIREBASE_AUTH_ERROR_MESSAGE = {
  MISSING_BEARER: "Firebase Bearer token is required",
  ID_TOKEN_EXPIRED: "Firebase ID token has expired",
  ID_TOKEN_INVALID: "Firebase ID token is invalid",
} as const;

export type FirebaseAuthErrorCode = typeof FIREBASE_AUTH_ERROR_CODE[keyof typeof FIREBASE_AUTH_ERROR_CODE];

export function getFirebaseAuthErrorCode(error: unknown): string | null {
  if (!isRecord(error)) return null;

  const errorInfo = error.errorInfo;
  if (isRecord(errorInfo) && typeof errorInfo.code === "string") {
    return errorInfo.code;
  }

  return typeof error.code === "string" ? error.code : null;
}

export function mapFirebaseAuthErrorCode(error: unknown): FirebaseAuthErrorCode {
  const code = getFirebaseAuthErrorCode(error);

  if (code === FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_EXPIRED) {
    return FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_EXPIRED;
  }

  return FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_INVALID;
}

export function getFirebaseAuthErrorMessage(code: FirebaseAuthErrorCode): string {
  switch (code) {
    case FIREBASE_AUTH_ERROR_CODE.MISSING_BEARER:
      return FIREBASE_AUTH_ERROR_MESSAGE.MISSING_BEARER;
    case FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_EXPIRED:
      return FIREBASE_AUTH_ERROR_MESSAGE.ID_TOKEN_EXPIRED;
    case FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_INVALID:
      return FIREBASE_AUTH_ERROR_MESSAGE.ID_TOKEN_INVALID;
  }
}
