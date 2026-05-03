import { Controller, Get, Header, Inject } from "@nestjs/common";
import { ApiOkResponse, ApiTags } from "@nestjs/swagger";
import { DEVICE_STATE_READER_TOKEN } from "../../shared/tokens/di.tokens";
import type { DeviceStateReader } from "../device/domain/device-ports";
import { HealthDto, StatusDto } from "./health.dto";

@ApiTags("health")
@Controller()
export class HealthController {
  constructor(
    @Inject(DEVICE_STATE_READER_TOKEN) private readonly stateReader: DeviceStateReader,
  ) {}

  @Get()
  @Header("content-type", "text/plain")
  root(): string {
    return "SmartRecu backend alive";
  }

  @Get("health")
  @ApiOkResponse({ type: HealthDto })
  health(): HealthDto {
    return { status: "ok" };
  }

  @Get("status")
  @ApiOkResponse({ type: StatusDto })
  status(): StatusDto {
    return {
      status: "ok",
      esp32: this.stateReader.getStatus(),
    };
  }
}
