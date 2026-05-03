import { Controller, DefaultValuePipe, Get, Inject, ParseIntPipe, Query, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOkResponse, ApiTags } from "@nestjs/swagger";
import { FirebaseAuthGuard } from "../../auth/firebase-auth.guard";
import { SensorsService } from "../sensors.service";
import { SensorHistoryDto } from "./sensors.dto";

@ApiTags("sensors")
@Controller("sensors")
export class SensorsController {
    constructor(@Inject(SensorsService) private readonly sensorsService: SensorsService) {}

    @Get("history")
    @UseGuards(FirebaseAuthGuard)
    @ApiBearerAuth()
    @ApiOkResponse({ type: () => SensorHistoryDto })
    getHistory(@Query("limit", new DefaultValuePipe(20), ParseIntPipe) limit: number): Promise<SensorHistoryDto> {
        return this.sensorsService.getHistory(limit);
    }
}
