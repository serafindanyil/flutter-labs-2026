import { Module } from "@nestjs/common";
import { DeviceModule } from "../device/device.module";
import { HealthController } from "./health.controller";

@Module({
  imports: [DeviceModule],
  controllers: [HealthController],
})
export class HealthModule {}
