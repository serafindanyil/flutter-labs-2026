import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { EventEmitterModule } from "@nestjs/event-emitter";
import { ScheduleModule } from "@nestjs/schedule";
import { AuthModule } from "./features/auth/auth.module";
import { DeviceModule } from "./features/device/device.module";
import { HealthModule } from "./features/health/health.module";
import { RealtimeModule } from "./features/realtime/realtime.module";
import { SensorsModule } from "./features/sensors/sensors.module";
import { SharedConfigModule } from "./shared/config/shared-config.module";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    EventEmitterModule.forRoot(),
    ScheduleModule.forRoot(),
    SharedConfigModule,
    AuthModule,
    DeviceModule,
    SensorsModule,
    RealtimeModule,
    HealthModule,
  ],
})
export class AppModule {}
