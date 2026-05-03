import { ApiProperty } from "@nestjs/swagger";
import { DEVICE_STATUS } from "../../shared/constants/realtime.constants";

export class HealthDto {
  @ApiProperty({ type: String, example: "ok" })
  status!: string;
}

export class StatusDto {
  @ApiProperty({ type: String, example: "ok" })
  status!: string;

  @ApiProperty({ type: String, example: "online", enum: Object.values(DEVICE_STATUS) })
  esp32!: string;
}
