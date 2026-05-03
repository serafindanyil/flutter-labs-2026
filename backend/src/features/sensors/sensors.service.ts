import { Inject, Injectable, Logger } from "@nestjs/common";
import { OnEvent } from "@nestjs/event-emitter";
import { Interval } from "@nestjs/schedule";
import { EventEmitter2 } from "@nestjs/event-emitter";
import {
  DEFAULT_HISTORY_LIMIT,
  SENSOR_PERSIST_INTERVAL_MS,
  ANALYTICS_REFRESH_INTERVAL_MS,
  DATABASE_WARNING_THROTTLE_MS,
} from "../../shared/constants/app.constants";
import { DEVICE_MESSAGE_TYPE } from "../../shared/constants/realtime.constants";
import { EVENT_NAMES } from "../../shared/events/event-names";
import {
  DEVICE_ACTIVITY_READER_TOKEN,
  DEVICE_STATE_READER_TOKEN,
  SENSOR_CACHE_TOKEN,
  SENSOR_REPOSITORY_TOKEN,
} from "../../shared/tokens/di.tokens";
import type { DeviceActivityReader, DeviceStateReader } from "../device/domain/device-ports";
import type {
  RealtimeSensorUpdate,
  SensorCache,
  SensorCacheSnapshot,
  SensorHistory,
  SensorRepository,
  SensorUpdate,
} from "./domain/sensor.types";
import { normalizeHistoryLimit } from "./domain/history-limit";

@Injectable()
export class SensorsService {
  private readonly logger = new Logger(SensorsService.name);
  private lastDatabaseWarningAt = 0;

  constructor(
    @Inject(SENSOR_REPOSITORY_TOKEN) private readonly repository: SensorRepository,
    @Inject(SENSOR_CACHE_TOKEN) private readonly cache: SensorCache,
    @Inject(DEVICE_ACTIVITY_READER_TOKEN) private readonly activityReader: DeviceActivityReader,
    @Inject(DEVICE_STATE_READER_TOKEN) private readonly stateReader: DeviceStateReader,
    @Inject(EventEmitter2) private readonly events: EventEmitter2,
  ) {}

  async getHistory(limit: number = DEFAULT_HISTORY_LIMIT): Promise<SensorHistory> {
    return this.repository.getLatestHistory(normalizeHistoryLimit(limit));
  }

  @OnEvent(EVENT_NAMES.DEVICE_SENSOR_UPDATED)
  handleSensorUpdate(data: SensorUpdate): void {
    this.cache.update(data);
    this.events.emit(EVENT_NAMES.FRONTEND_BROADCAST, {
      type: DEVICE_MESSAGE_TYPE.SENSORS,
      data: this.toRealtimeSensorUpdate(data),
    });
  }

  @Interval(SENSOR_PERSIST_INTERVAL_MS)
  async persistLatestSnapshot(): Promise<void> {
    if (!this.activityReader.hasActiveEsp32()) return;

    const snapshot = this.cache.getSnapshot();
    if (!this.hasCoreValues(snapshot)) return;

    await this.runDatabaseTask("persist sensor snapshot", () => this.repository.insertSnapshot(snapshot));
  }

  @Interval(ANALYTICS_REFRESH_INTERVAL_MS)
  async aggregateAnalytics(): Promise<void> {
    await this.runDatabaseTask("aggregate sensor analytics", () => this.repository.aggregateCurrentBucket());
  }

  private hasCoreValues(snapshot: SensorCacheSnapshot): boolean {
    return typeof snapshot.humidity === "number" && typeof snapshot.co2 === "number";
  }

  private async runDatabaseTask(operation: string, task: () => Promise<void>): Promise<void> {
    try {
      await task();
    } catch (error: unknown) {
      this.warnDatabaseFailure(operation, error);
    }
  }

  private warnDatabaseFailure(operation: string, error: unknown): void {
    const now = Date.now();
    if (now - this.lastDatabaseWarningAt < DATABASE_WARNING_THROTTLE_MS) return;

    this.lastDatabaseWarningAt = now;
    const message = error instanceof Error ? error.message : "Unknown database error";
    this.logger.warn(`Failed to ${operation}: ${message}`);
  }

  private toRealtimeSensorUpdate(data: SensorUpdate): RealtimeSensorUpdate {
    const rpm = this.stateReader.getFanSpeedRpmPayload();

    return {
      co2: data.co2,
      humidity: data.humidity,
      innerTemp: data.tempIn,
      outerTemp: data.tempOut,
      fanInSpd: rpm.fanInSpd,
      fanOutSpd: rpm.fanOutSpd,
    };
  }
}
