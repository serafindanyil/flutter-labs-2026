export interface SensorUpdate {
  co2: number;
  humidity: number;
  tempIn: number;
  tempOut: number;
}

export interface RealtimeSensorUpdate {
  co2: number;
  humidity: number;
  innerTemp: number;
  outerTemp: number;
  fanInSpd: number | null;
  fanOutSpd: number | null;
}

export interface SensorCacheSnapshot {
  humidity: number | null;
  co2: number | null;
  tempIn: number | null;
  tempOut: number | null;
}

export interface HumidityHistoryPoint {
  humidity: number;
  timestamp: string;
}

export interface Co2HistoryPoint {
  co2: number;
  timestamp: string;
}

export interface SensorHistory {
  humidity: HumidityHistoryPoint[];
  co2: Co2HistoryPoint[];
}

export interface SensorRepository {
  getLatestHistory(limit: number): Promise<SensorHistory>;
  insertSnapshot(snapshot: SensorCacheSnapshot): Promise<void>;
  aggregateCurrentBucket(): Promise<void>;
}

export interface SensorCache {
  update(data: SensorUpdate): void;
  getSnapshot(): SensorCacheSnapshot;
}
