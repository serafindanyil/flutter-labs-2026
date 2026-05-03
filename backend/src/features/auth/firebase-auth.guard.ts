import { CanActivate, ExecutionContext, Inject, Injectable, UnauthorizedException } from "@nestjs/common";
import type { Request } from "express";
import { FIREBASE_AUTH_VERIFIER_TOKEN } from "../../shared/tokens/di.tokens";
import type { AuthUser, FirebaseAuthVerifier } from "./auth.types";
import {
  FIREBASE_AUTH_ERROR_CODE,
  FIREBASE_AUTH_ERROR_MESSAGE,
  mapFirebaseAuthErrorCode,
} from "./firebase-auth-errors";

export interface AuthenticatedRequest extends Request {
  firebaseUser?: AuthUser;
}

function extractBearerToken(value: string | undefined): string | null {
  if (value === undefined) return null;
  const [scheme, token] = value.split(" ");
  if (scheme !== "Bearer" || token === undefined || token.trim() === "") return null;
  return token;
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
      throw new UnauthorizedException(FIREBASE_AUTH_ERROR_MESSAGE.MISSING_BEARER);
    }

    try {
      request.firebaseUser = await this.verifier.verifyToken(token);
    } catch (error: unknown) {
      const code = mapFirebaseAuthErrorCode(error);

      if (code === FIREBASE_AUTH_ERROR_CODE.ID_TOKEN_EXPIRED) {
        throw new UnauthorizedException(FIREBASE_AUTH_ERROR_MESSAGE.ID_TOKEN_EXPIRED);
      }

      throw new UnauthorizedException(FIREBASE_AUTH_ERROR_MESSAGE.ID_TOKEN_INVALID);
    }

    return true;
  }
}
