import { Module } from "@nestjs/common";
import { AuthModule } from "../auth/auth.module";
import { DeviceModule } from "../device/device.module";
import { SensorsModule } from "../sensors/sensors.module";
import { RealtimeGateway } from "./realtime.gateway";

@Module({
  imports: [AuthModule, DeviceModule, SensorsModule],
  providers: [RealtimeGateway],
})
export class RealtimeModule {}
