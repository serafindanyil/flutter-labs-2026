import { Inject, Injectable } from "@nestjs/common";
import { OnEvent } from "@nestjs/event-emitter";
import { Interval } from "@nestjs/schedule";
import { EventEmitter2 } from "@nestjs/event-emitter";
import {
  DEFAULT_HISTORY_LIMIT,
  SENSOR_PERSIST_INTERVAL_MS,
  ANALYTICS_REFRESH_INTERVAL_MS,
} from "../../shared/constants/app.constants";
import { DEVICE_MESSAGE_TYPE } from "../../shared/constants/realtime.constants";
import { EVENT_NAMES } from "../../shared/events/event-names";
import {
  DEVICE_ACTIVITY_READER_TOKEN,
  SENSOR_CACHE_TOKEN,
  SENSOR_REPOSITORY_TOKEN,
} from "../../shared/tokens/di.tokens";
import type { DeviceActivityReader } from "../device/domain/device-ports";
import type { SensorCache, SensorCacheSnapshot, SensorHistory, SensorRepository, SensorUpdate } from "./domain/sensor.types";
import { normalizeHistoryLimit } from "./domain/history-limit";

@Injectable()
export class SensorsService {
  constructor(
    @Inject(SENSOR_REPOSITORY_TOKEN) private readonly repository: SensorRepository,
    @Inject(SENSOR_CACHE_TOKEN) private readonly cache: SensorCache,
    @Inject(DEVICE_ACTIVITY_READER_TOKEN) private readonly activityReader: DeviceActivityReader,
    private readonly events: EventEmitter2,
  ) {}

  async getHistory(limit: number = DEFAULT_HISTORY_LIMIT): Promise<SensorHistory> {
    return this.repository.getLatestHistory(normalizeHistoryLimit(limit));
  }

  @OnEvent(EVENT_NAMES.DEVICE_SENSOR_UPDATED)
  handleSensorUpdate(data: SensorUpdate): void {
    this.cache.update(data);
    this.events.emit(EVENT_NAMES.FRONTEND_BROADCAST, {
      type: DEVICE_MESSAGE_TYPE.UPDATE,
      data,
    });
  }

  @Interval(SENSOR_PERSIST_INTERVAL_MS)
  async persistLatestSnapshot(): Promise<void> {
    if (!this.activityReader.hasActiveEsp32()) return;

    const snapshot = this.cache.getSnapshot();
    if (!this.hasCoreValues(snapshot)) return;

    await this.repository.insertSnapshot(snapshot);
    const history = await this.repository.getLatestHistory(DEFAULT_HISTORY_LIMIT);

    this.events.emit(EVENT_NAMES.SENSOR_HISTORY_REFRESHED, history);
    this.events.emit(EVENT_NAMES.FRONTEND_BROADCAST, {
      type: DEVICE_MESSAGE_TYPE.SENSOR_HISTORY,
      data: history,
    });
  }

  @Interval(ANALYTICS_REFRESH_INTERVAL_MS)
  async aggregateAnalytics(): Promise<void> {
    await this.repository.aggregateCurrentBucket();
  }

  private hasCoreValues(snapshot: SensorCacheSnapshot): boolean {
    return typeof snapshot.humidity === "number" && typeof snapshot.co2 === "number";
  }
}
