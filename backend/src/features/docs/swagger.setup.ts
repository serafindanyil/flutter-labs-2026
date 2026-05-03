import type { INestApplication } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { SWAGGER_JSON_PATH, SWAGGER_PATH } from "../../shared/constants/app.constants";

export function setupSwagger(app: INestApplication): void {
  const config = new DocumentBuilder()
    .setTitle("SmartRecu Backend")
    .setDescription("HTTP API for SmartRecu backend. Realtime contracts are documented in read.md.")
    .setVersion("1.0.0")
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);

  SwaggerModule.setup(SWAGGER_PATH, app, document, {
    jsonDocumentUrl: SWAGGER_JSON_PATH,
  });
}
