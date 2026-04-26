import { Module } from "@nestjs/common";
import { PrismaModule } from "../../shared/prisma/prisma.module";
import { AuthModule } from "../auth/auth.module";
import { SENSOR_CACHE_TOKEN, SENSOR_REPOSITORY_TOKEN } from "../../shared/tokens/di.tokens";
import { DeviceModule } from "../device/device.module";
import { SensorsController } from "./api/sensors.controller";
import { InMemorySensorCache } from "./domain/sensor-cache.service";
import { PrismaSensorRepository } from "./infrastructure/prisma-sensor.repository";
import { SensorsService } from "./sensors.service";

@Module({
    imports: [PrismaModule, DeviceModule, AuthModule],
    controllers: [SensorsController],
    providers: [
        SensorsService,
        {
            provide: SENSOR_CACHE_TOKEN,
            useClass: InMemorySensorCache,
        },
        {
            provide: SENSOR_REPOSITORY_TOKEN,
            useClass: PrismaSensorRepository,
        },
    ],
    exports: [SensorsService],
})
export class SensorsModule {}
