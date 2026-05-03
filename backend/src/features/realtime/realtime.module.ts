import { Module } from "@nestjs/common";
import { AuthModule } from "../auth/auth.module";
import { DeviceModule } from "../device/device.module";
import { RealtimeGateway } from "./realtime.gateway";

@Module({
  imports: [AuthModule, DeviceModule],
  providers: [RealtimeGateway],
})
export class RealtimeModule {}
