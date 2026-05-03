import { Inject, Injectable, Logger, OnModuleDestroy, OnModuleInit } from "@nestjs/common";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@prisma/client";
import type { AppConfig } from "../config/app-config.types";
import { APP_CONFIG_TOKEN } from "../tokens/di.tokens";

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(@Inject(APP_CONFIG_TOKEN) config: AppConfig) {
    super({
      adapter: new PrismaPg(config.databaseUrl),
    });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log("Prisma connected successfully");
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
