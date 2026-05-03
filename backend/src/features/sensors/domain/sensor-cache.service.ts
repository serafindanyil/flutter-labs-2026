import { Injectable } from "@nestjs/common";
import type { SensorCache, SensorCacheSnapshot, SensorUpdate } from "./sensor.types";

@Injectable()
export class InMemorySensorCache implements SensorCache {
  private snapshot: SensorCacheSnapshot = {
    humidity: null,
    co2: null,
    tempIn: null,
    tempOut: null,
  };

  update(data: SensorUpdate): void {
    this.snapshot = {
      humidity: data.humidity,
      co2: data.co2,
      tempIn: data.tempIn,
      tempOut: data.tempOut,
    };
  }

  getSnapshot(): SensorCacheSnapshot {
    return { ...this.snapshot };
  }
}
