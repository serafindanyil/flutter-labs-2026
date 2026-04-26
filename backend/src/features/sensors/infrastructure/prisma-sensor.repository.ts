import { Inject, Injectable } from "@nestjs/common";
import dayjs from "dayjs";
import { PrismaClient } from "@prisma/client";
import { PRISMA_CLIENT_TOKEN } from "../../../shared/tokens/di.tokens";
import type { SensorCacheSnapshot, SensorHistory, SensorRepository } from "../domain/sensor.types";

function toHistoryTimestamp(value: Date): string {
  return dayjs(value).format("HH:mm");
}

function hasNumber(value: number | null): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

@Injectable()
export class PrismaSensorRepository implements SensorRepository {
  constructor(@Inject(PRISMA_CLIENT_TOKEN) private readonly prisma: PrismaClient) {}

  async getLatestHistory(limit: number): Promise<SensorHistory> {
    const [humidityRows, co2Rows] = await Promise.all([
      this.prisma.humidity.findMany({
        orderBy: { timestamp: "desc" },
        take: limit,
        select: {
          humidity: true,
          timestamp: true,
        },
      }),
      this.prisma.co2.findMany({
        orderBy: { timestamp: "desc" },
        take: limit,
        select: {
          co2: true,
          timestamp: true,
        },
      }),
    ]);

    return {
      humidity: humidityRows.map((row) => ({
        humidity: row.humidity,
        timestamp: toHistoryTimestamp(row.timestamp),
      })),
      co2: co2Rows.map((row) => ({
        co2: row.co2,
        timestamp: toHistoryTimestamp(row.timestamp),
      })),
    };
  }

  async insertSnapshot(snapshot: SensorCacheSnapshot): Promise<void> {
    if (hasNumber(snapshot.humidity)) {
      await this.prisma.humidity.create({
        data: { humidity: snapshot.humidity },
      });
    }

    if (hasNumber(snapshot.co2)) {
      await this.prisma.co2.create({
        data: { co2: Math.trunc(snapshot.co2) },
      });
    }

    if (hasNumber(snapshot.tempIn)) {
      await this.prisma.tempInside.create({
        data: { tempInside: snapshot.tempIn },
      });
    }

    if (hasNumber(snapshot.tempOut)) {
      await this.prisma.tempOutside.create({
        data: { tempOutside: snapshot.tempOut },
      });
    }
  }

  async aggregateCurrentBucket(): Promise<void> {
    await this.prisma.$executeRaw`
      WITH bucket AS (
        SELECT date_trunc('minute', now()) - ((extract(minute from now())::int % 5) * interval '1 minute') AS bucket_start
      ),
      aggregate_values AS (
        SELECT
          bucket.bucket_start,
          (SELECT AVG(humidity) FROM humidity WHERE timestamp >= bucket.bucket_start AND timestamp < bucket.bucket_start + interval '5 minute') AS avg_humidity,
          (SELECT AVG(co2) FROM co2 WHERE timestamp >= bucket.bucket_start AND timestamp < bucket.bucket_start + interval '5 minute') AS avg_co2,
          (SELECT AVG(temp_inside) FROM temp_inside WHERE timestamp >= bucket.bucket_start AND timestamp < bucket.bucket_start + interval '5 minute') AS avg_temp_inside,
          (SELECT AVG(temp_outside) FROM temp_outside WHERE timestamp >= bucket.bucket_start AND timestamp < bucket.bucket_start + interval '5 minute') AS avg_temp_outside,
          (SELECT COUNT(*) FROM humidity WHERE timestamp >= bucket.bucket_start AND timestamp < bucket.bucket_start + interval '5 minute') AS samples
        FROM bucket
      )
      INSERT INTO sensor_analytics (
        bucket_start,
        avg_humidity,
        avg_co2,
        avg_temp_inside,
        avg_temp_outside,
        samples
      )
      SELECT
        bucket_start,
        avg_humidity,
        avg_co2,
        avg_temp_inside,
        avg_temp_outside,
        samples
      FROM aggregate_values
      ON CONFLICT (bucket_start)
      DO UPDATE SET
        avg_humidity = EXCLUDED.avg_humidity,
        avg_co2 = EXCLUDED.avg_co2,
        avg_temp_inside = EXCLUDED.avg_temp_inside,
        avg_temp_outside = EXCLUDED.avg_temp_outside,
        samples = EXCLUDED.samples,
        updated_at = now()
    `;
  }
}
