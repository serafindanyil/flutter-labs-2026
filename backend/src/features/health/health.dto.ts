import { ApiProperty } from "@nestjs/swagger";

export class HealthDto {
  @ApiProperty({ example: "ok" })
  status!: string;
}

export class StatusDto {
  @ApiProperty({ example: "ok" })
  status!: string;

  @ApiProperty({ example: "Online", enum: ["Online", "Offline"] })
  esp32!: string;
}
