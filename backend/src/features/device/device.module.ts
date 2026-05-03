import { Module } from "@nestjs/common";
import {
  DEVICE_ACTIVITY_READER_TOKEN,
  DEVICE_COMMAND_SENDER_TOKEN,
  DEVICE_STATE_READER_TOKEN,
  DEVICE_STATE_WRITER_TOKEN,
} from "../../shared/tokens/di.tokens";
import { AuthModule } from "../auth/auth.module";
import { DeviceController } from "./api/device.controller";
import { DeviceControlService } from "./domain/device-control.service";
import { DeviceStateService } from "./domain/device-state.service";
import { DeviceConnectionRegistry } from "./infrastructure/device-connection.registry";
import { RawDeviceWebSocketService } from "./infrastructure/raw-device-websocket.service";

@Module({
  imports: [AuthModule],
  controllers: [DeviceController],
  providers: [
    DeviceConnectionRegistry,
    DeviceControlService,
    DeviceStateService,
    RawDeviceWebSocketService,
    {
      provide: DEVICE_COMMAND_SENDER_TOKEN,
      useExisting: DeviceConnectionRegistry,
    },
    {
      provide: DEVICE_ACTIVITY_READER_TOKEN,
      useExisting: DeviceConnectionRegistry,
    },
    {
      provide: DEVICE_STATE_READER_TOKEN,
      useExisting: DeviceStateService,
    },
    {
      provide: DEVICE_STATE_WRITER_TOKEN,
      useExisting: DeviceStateService,
    },
  ],
  exports: [
    DEVICE_COMMAND_SENDER_TOKEN,
    DEVICE_ACTIVITY_READER_TOKEN,
    DEVICE_STATE_READER_TOKEN,
    DEVICE_STATE_WRITER_TOKEN,
  ],
})
export class DeviceModule {}
