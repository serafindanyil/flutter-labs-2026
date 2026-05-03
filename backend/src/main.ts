import "reflect-metadata";
import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { setupSwagger } from "./features/docs/swagger.setup";
import type { AppConfig } from "./shared/config/app-config.types";
import { APP_CONFIG_TOKEN } from "./shared/tokens/di.tokens";

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  const config = app.get<AppConfig>(APP_CONFIG_TOKEN);
  const logger = new Logger("Bootstrap");

  app.enableCors({
    origin: config.corsOrigin,
    credentials: true,
  });

  setupSwagger(app);

  await app.listen(config.port, config.host);
  logger.log(`HTTP listening on http://${config.host}:${config.port}`);
}

void bootstrap();
