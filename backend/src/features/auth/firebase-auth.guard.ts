import { CanActivate, ExecutionContext, Inject, Injectable, UnauthorizedException } from "@nestjs/common";
import type { Request } from "express";
import { FIREBASE_AUTH_VERIFIER_TOKEN } from "../../shared/tokens/di.tokens";
import { isRecord } from "../../shared/utils/is-record";
import type { AuthUser, FirebaseAuthVerifier } from "./auth.types";

const FIREBASE_AUTH_ERROR_CODE = {
  ID_TOKEN_EXPIRED: "auth/id-token-expired",
} as const;

const AUTH_ERROR_MESSAGE = {
  MISSING_BEARER: "Firebase Bearer token is required",
  ID_TOKEN_EXPIRED: "Firebase ID token has expired",
  ID_TOKEN_INVALID: "Firebase ID token is invalid",
} as const;

export interface AuthenticatedRequest extends Request {
  firebaseUser?: AuthUser;
}

function extractBearerToken(value: string | undefined): string | null {
  if (value === undefined) return null;
  const [scheme, token] = value.split(" ");
  if (scheme !== "Bearer" || token === undefined || token.trim() === "") return null;
  return token;
}

function getFirebaseAuthErrorCode(error: unknown): string | null {
  if (!isRecord(error)) return null;

  const errorInfo = error.errorInfo;
  if (isRecord(errorInfo) && typeof errorInfo.code === "string") {
    return errorInfo.code;
  }

  return typeof error.code === "string" ? error.code : null;
}

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    @Inject(FIREBASE_AUTH_VERIFIER_TOKEN) private readonly verifier: FirebaseAuthVerifier,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const token = extractBearerToken(request.headers.authorization);

    if (token === null) {
      throw new UnauthorizedException(AUTH_ERROR_MESSAGE.MISSING_BEARER);
    }

    try {
      request.firebaseUser = await this.verifier.verifyToken(token);
    } catch (error: unknown) {
      const code = getFirebaseAuthErrorCode(error);

      if (code === FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_EXPIRED) {
        throw new UnauthorizedException(AUTH_ERROR_MESSAGE.ID_TOKEN_EXPIRED);
      }

      throw new UnauthorizedException(AUTH_ERROR_MESSAGE.ID_TOKEN_INVALID);
    }

    return true;
  }
}
