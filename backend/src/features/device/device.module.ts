import { Module } from "@nestjs/common";
import {
  DEVICE_ACTIVITY_READER_TOKEN,
  DEVICE_COMMAND_SENDER_TOKEN,
  DEVICE_STATE_READER_TOKEN,
} from "../../shared/tokens/di.tokens";
import { DeviceStateService } from "./domain/device-state.service";
import { DeviceConnectionRegistry } from "./infrastructure/device-connection.registry";
import { RawDeviceWebSocketService } from "./infrastructure/raw-device-websocket.service";

@Module({
  providers: [
    DeviceConnectionRegistry,
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
  ],
  exports: [
    DEVICE_COMMAND_SENDER_TOKEN,
    DEVICE_ACTIVITY_READER_TOKEN,
    DEVICE_STATE_READER_TOKEN,
  ],
})
export class DeviceModule {}
