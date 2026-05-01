import { BadRequestException, ConflictException, Inject, Injectable, OnModuleDestroy } from "@nestjs/common";
import { EventEmitter2 } from "@nestjs/event-emitter";
import {
  DEVICE_COMMAND_RETRY_INTERVAL_MS,
  DEVICE_COMMAND_RETRY_TIMEOUT_MS,
  MAX_TURBO_DURATION_SECONDS,
  MIN_TURBO_DURATION_SECONDS,
  SECONDS_IN_MS,
} from "../../../shared/constants/app.constants";
import { DEVICE_MESSAGE_TYPE, DEVICE_MODE, DEVICE_POWER_STATE } from "../../../shared/constants/realtime.constants";
import { EVENT_NAMES } from "../../../shared/events/event-names";
import { DEVICE_ACTIVITY_READER_TOKEN, DEVICE_COMMAND_SENDER_TOKEN } from "../../../shared/tokens/di.tokens";
import type { DeviceClientStatePayload, DeviceMode, DevicePowerState } from "../../../shared/types/realtime.types";
import type { DeviceActivityReader, DeviceCommandSender } from "./device-ports";
import { DeviceStateService } from "./device-state.service";

@Injectable()
export class DeviceControlService implements OnModuleDestroy {
  private turboTimer: NodeJS.Timeout | null = null;

  constructor(
    @Inject(DEVICE_COMMAND_SENDER_TOKEN) private readonly commandSender: DeviceCommandSender,
    @Inject(DEVICE_ACTIVITY_READER_TOKEN) private readonly activityReader: DeviceActivityReader,
    @Inject(DeviceStateService) private readonly state: DeviceStateService,
    @Inject(EventEmitter2) private readonly events: EventEmitter2,
  ) {}

  onModuleDestroy(): void {
    this.clearTurboTimer();
  }

  getState(): DeviceClientStatePayload {
    return this.state.getClientStatePayload();
  }

  async changePowerState(value: DevicePowerState): Promise<void> {
    await this.ensureEsp32Online();
    const enabled = this.toSwitchState(value);
    this.state.setSwitchState(enabled);
    this.commandSender.sendSwitchState(enabled);
    this.broadcastUpdateStatus();
  }

  async changeMode(mode: DeviceMode, turboDurationSec: number | undefined): Promise<void> {
    await this.ensureEsp32Online();

    if (mode !== DEVICE_MODE.TURBO) {
      this.clearTurboTimer();
      this.state.setTurboEndsAt(null);
      this.state.setMode(mode);
      this.commandSender.sendMode(mode);
      this.broadcastUpdateStatus();
      return;
    }

    const duration = this.normalizeTurboDuration(turboDurationSec);
    const turboEndsAt = new Date(Date.now() + duration * SECONDS_IN_MS);

    this.clearTurboTimer();
    this.state.setMode(DEVICE_MODE.TURBO);
    this.state.setTurboEndsAt(turboEndsAt);
    this.commandSender.sendMode(DEVICE_MODE.TURBO);
    this.broadcastUpdateStatus();

    this.turboTimer = setTimeout(() => {
      this.state.setMode(DEVICE_MODE.MANUAL);
      this.state.setTurboEndsAt(null);
      this.commandSender.sendMode(DEVICE_MODE.MANUAL);
      this.broadcastUpdateStatus();
      this.turboTimer = null;
    }, duration * SECONDS_IN_MS);
  }

  private normalizeTurboDuration(value: number | undefined): number {
    if (value === undefined || !Number.isInteger(value)) {
      throw new BadRequestException("turboDurationSec is required for turbo mode");
    }

    if (value < MIN_TURBO_DURATION_SECONDS || value > MAX_TURBO_DURATION_SECONDS) {
      throw new BadRequestException(
        `turboDurationSec must be between ${MIN_TURBO_DURATION_SECONDS} and ${MAX_TURBO_DURATION_SECONDS}`,
      );
    }

    return value;
  }

  private toSwitchState(value: DevicePowerState): boolean {
    return value === DEVICE_POWER_STATE.ON;
  }

  private async ensureEsp32Online(): Promise<void> {
    if (this.activityReader.hasActiveEsp32()) return;

    const deadline = Date.now() + DEVICE_COMMAND_RETRY_TIMEOUT_MS;

    while (Date.now() < deadline) {
      await this.delay(DEVICE_COMMAND_RETRY_INTERVAL_MS);
      if (this.activityReader.hasActiveEsp32()) return;
    }

    throw new ConflictException("ESP32 is offline");
  }

  private delay(durationMs: number): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, durationMs);
    });
  }

  private broadcastUpdateStatus(): void {
    this.events.emit(EVENT_NAMES.FRONTEND_BROADCAST, {
      type: DEVICE_MESSAGE_TYPE.UPDATE_STATUS,
      data: this.state.getClientStatePayload(),
    });
  }

  private clearTurboTimer(): void {
    if (this.turboTimer === null) return;
    clearTimeout(this.turboTimer);
    this.turboTimer = null;
  }
}
