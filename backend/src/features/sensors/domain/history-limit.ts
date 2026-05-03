import { MAX_HISTORY_LIMIT, MIN_HISTORY_LIMIT } from "../../../shared/constants/app.constants";

export function normalizeHistoryLimit(limit: number): number {
  if (!Number.isFinite(limit)) return MIN_HISTORY_LIMIT;
  return Math.max(MIN_HISTORY_LIMIT, Math.min(Math.trunc(limit), MAX_HISTORY_LIMIT));
}
