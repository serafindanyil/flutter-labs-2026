import { Module } from "@nestjs/common";
import { SharedConfigModule } from "../../shared/config/shared-config.module";
import { FIREBASE_AUTH_VERIFIER_TOKEN } from "../../shared/tokens/di.tokens";
import { FirebaseAuthGuard } from "./firebase-auth.guard";
import { FirebaseAuthService } from "./firebase-auth.service";

@Module({
  imports: [SharedConfigModule],
  providers: [
    FirebaseAuthGuard,
    FirebaseAuthService,
    {
      provide: FIREBASE_AUTH_VERIFIER_TOKEN,
      useExisting: FirebaseAuthService,
    },
  ],
  exports: [FIREBASE_AUTH_VERIFIER_TOKEN, FirebaseAuthGuard],
})
export class AuthModule {}
