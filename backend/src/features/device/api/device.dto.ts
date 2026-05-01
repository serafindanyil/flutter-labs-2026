import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  MAX_FAN_SPEED_PERCENT,
  MAX_TURBO_DURATION_SECONDS,
  MIN_FAN_SPEED_PERCENT,
  MIN_TURBO_DURATION_SECONDS,
} from "../../../shared/constants/app.constants";
import { DEVICE_MODE, DEVICE_POWER_STATE, DEVICE_STATUS } from "../../../shared/constants/realtime.constants";
import type { DeviceClientStatePayload, DeviceMode, DevicePowerState, DeviceStatus } from "../../../shared/types/realtime.types";

export class DeviceStateDto implements DeviceClientStatePayload {
  @ApiProperty({ type: String, example: "online", enum: Object.values(DEVICE_STATUS) })
  deviceStatus!: DeviceStatus;

  @ApiProperty({ type: String, example: "on", enum: Object.values(DEVICE_POWER_STATE), nullable: true })
  state!: DevicePowerState | null;

  @ApiProperty({ type: String, example: "auto", enum: Object.values(DEVICE_MODE), nullable: true })
  mode!: DeviceMode | null;

  @ApiProperty({
    type: Number,
    example: 60,
    minimum: MIN_FAN_SPEED_PERCENT,
    maximum: MAX_FAN_SPEED_PERCENT,
    nullable: true,
  })
  fanInSpd!: number | null;

  @ApiProperty({
    type: Number,
    example: 60,
    minimum: MIN_FAN_SPEED_PERCENT,
    maximum: MAX_FAN_SPEED_PERCENT,
    nullable: true,
  })
  fanOutSpd!: number | null;

  @ApiProperty({ type: String, example: "2026-04-30T12:15:00.000Z", nullable: true })
  turboEndsAt!: string | null;
}

export class ChangePowerStateDto {
  @ApiProperty({ type: String, example: "on", enum: Object.values(DEVICE_POWER_STATE) })
  state!: DevicePowerState;
}

export class ChangeModeDto {
  @ApiProperty({ type: String, example: "turbo", enum: Object.values(DEVICE_MODE) })
  mode!: DeviceMode;

  @ApiPropertyOptional({
    type: Number,
    example: 60,
    minimum: MIN_TURBO_DURATION_SECONDS,
    maximum: MAX_TURBO_DURATION_SECONDS,
    description: "Required only when mode is turbo",
  })
  turboDurationSec?: number;
}

export class ChangeModeResponseDto {
  @ApiProperty({ type: String, example: "2026-04-30T12:15:00.000Z", nullable: true })
  turboEndsAt!: string | null;
}
