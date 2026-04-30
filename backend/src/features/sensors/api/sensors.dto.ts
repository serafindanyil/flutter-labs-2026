import { ApiProperty } from "@nestjs/swagger";

export class HumidityHistoryPointDto {
    @ApiProperty({ type: Number, example: 45 })
    humidity!: number;

    @ApiProperty({ type: String, example: "12:30" })
    timestamp!: string;
}

export class Co2HistoryPointDto {
    @ApiProperty({ type: Number, example: 800 })
    co2!: number;

    @ApiProperty({ type: String, example: "12:30" })
    timestamp!: string;
}

export class SensorHistoryDto {
    @ApiProperty({ type: () => HumidityHistoryPointDto, isArray: true })
    humidity!: HumidityHistoryPointDto[];

    @ApiProperty({ type: () => Co2HistoryPointDto, isArray: true })
    co2!: Co2HistoryPointDto[];
}
