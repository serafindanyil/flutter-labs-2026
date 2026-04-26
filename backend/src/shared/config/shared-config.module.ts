import { Module } from "@nestjs/common";
import { APP_CONFIG_TOKEN } from "../tokens/di.tokens";
import { createAppConfig } from "./app-config.factory";

@Module({
  providers: [
    {
      provide: APP_CONFIG_TOKEN,
      useFactory: createAppConfig,
    },
  ],
  exports: [APP_CONFIG_TOKEN],
})
export class SharedConfigModule {}
