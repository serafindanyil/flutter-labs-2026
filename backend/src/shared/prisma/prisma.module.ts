import { Module } from "@nestjs/common";
import { SharedConfigModule } from "../config/shared-config.module";
import { PRISMA_CLIENT_TOKEN } from "../tokens/di.tokens";
import { PrismaService } from "./prisma.service";

@Module({
  imports: [SharedConfigModule],
  providers: [
    PrismaService,
    {
      provide: PRISMA_CLIENT_TOKEN,
      useExisting: PrismaService,
    },
  ],
  exports: [PRISMA_CLIENT_TOKEN],
})
export class PrismaModule {}
