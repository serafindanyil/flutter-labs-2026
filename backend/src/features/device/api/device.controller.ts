import { BadRequestException, Body, Controller, Get, HttpCode, HttpStatus, Inject, Post, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiBody, ApiConflictResponse, ApiOkResponse, ApiTags } from "@nestjs/swagger";
import { DEVICE_MODE, DEVICE_POWER_STATE } from "../../../shared/constants/realtime.constants";
import { FirebaseAuthGuard } from "../../auth/firebase-auth.guard";
import { DeviceControlService } from "../domain/device-control.service";
import { ChangeModeDto, ChangePowerStateDto, DeviceStateDto } from "./device.dto";

@ApiTags("device")
@Controller("device")
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class DeviceController {
  constructor(
    @Inject(DeviceControlService) private readonly deviceControl: DeviceControlService,
  ) {}

  @Get()
  @ApiOkResponse({ type: DeviceStateDto })
  getState(): DeviceStateDto {
    return this.deviceControl.getState();
  }

  @Post("state")
  @HttpCode(HttpStatus.OK)
  @ApiBody({ type: ChangePowerStateDto })
  @ApiOkResponse({ description: "Command accepted" })
  @ApiConflictResponse({ description: "ESP32 is offline" })
  changePowerState(@Body() body: ChangePowerStateDto): void {
    if (body?.state !== DEVICE_POWER_STATE.ON && body?.state !== DEVICE_POWER_STATE.OFF) {
      throw new BadRequestException("state must be on or off");
    }

    this.deviceControl.changePowerState(body.state);
  }

  @Post("mode")
  @HttpCode(HttpStatus.OK)
  @ApiBody({ type: ChangeModeDto })
  @ApiOkResponse({ description: "Command accepted" })
  @ApiConflictResponse({ description: "ESP32 is offline" })
  changeMode(@Body() body: ChangeModeDto): void {
    if (body?.mode !== DEVICE_MODE.MANUAL && body?.mode !== DEVICE_MODE.AUTO && body?.mode !== DEVICE_MODE.TURBO) {
      throw new BadRequestException("mode must be manual, auto, or turbo");
    }

    this.deviceControl.changeMode(body.mode, body.turboDurationSec);
  }
}
