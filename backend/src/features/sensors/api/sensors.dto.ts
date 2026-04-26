import { ApiProperty } from "@nestjs/swagger";

export class HumidityHistoryPointDto {
    @ApiProperty({ example: 45 })
    humidity!: number;

    @ApiProperty({ example: "12:30" })
    timestamp!: string;
}

export class Co2HistoryPointDto {
    @ApiProperty({ example: 800 })
    co2!: number;

    @ApiProperty({ example: "12:30" })
    timestamp!: string;
}

export class SensorHistoryDto {
    @ApiProperty({ type: () => HumidityHistoryPointDto, isArray: true })
    humidity!: HumidityHistoryPointDto[];

    @ApiProperty()
    co2!: Co2HistoryPointDto[];
}
