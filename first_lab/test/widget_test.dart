import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/home/mode_widget.dart';
import 'package:first_lab/modules/home/state_widget.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  test('applies updateStatus payload', () {
    final cubit = DeviceControlCubit();

    cubit.applyUpdateStatus({
      'deviceStatus': 'online',
      'state': 'on',
      'mode': 'auto',
      'fanInSpd': 45,
      'fanOutSpd': 55,
      'turboEndsAt': '2026-04-30T12:15:00.000Z',
    });

    expect(cubit.state.hasInitialStatus, isTrue);
    expect(cubit.state.deviceStatus, DeviceStatus.online);
    expect(cubit.state.state, DevicePowerState.on);
    expect(cubit.state.mode, DeviceMode.auto);
    expect(cubit.state.fanInSpd, 45);
    expect(cubit.state.fanOutSpd, 55);
    expect(cubit.state.turboEndsAt, isNotNull);

    cubit.close();
  });

  test('defaults malformed updateStatus payload safely', () {
    final cubit = DeviceControlCubit();

    cubit.applyUpdateStatus({
      'deviceStatus': 'unknown',
      'state': 'bad',
      'mode': 'bad',
      'fanInSpd': 'fast',
      'fanOutSpd': null,
      'turboEndsAt': 'bad-date',
    });

    expect(cubit.state.hasInitialStatus, isTrue);
    expect(cubit.state.deviceStatus, DeviceStatus.offline);
    expect(cubit.state.state, isNull);
    expect(cubit.state.mode, isNull);
    expect(cubit.state.fanInSpd, isNull);
    expect(cubit.state.fanOutSpd, isNull);
    expect(cubit.state.turboEndsAt, isNull);

    cubit.close();
  });

  test('centralized availability blocks controls for unavailable states', () {
    const onlineState = DeviceControlState(
      deviceStatus: DeviceStatus.online,
      hasInitialStatus: true,
    );
    const offlineState = DeviceControlState(hasInitialStatus: true);

    expect(
      DeviceControlAvailability.isDisabled(
        networkStatus: NetworkStatus.online,
        deviceControl: onlineState,
      ),
      isFalse,
    );
    expect(
      DeviceControlAvailability.isDisabled(
        networkStatus: NetworkStatus.offline,
        deviceControl: onlineState,
      ),
      isTrue,
    );
    expect(
      DeviceControlAvailability.isDisabled(
        networkStatus: NetworkStatus.online,
        deviceControl: offlineState,
      ),
      isTrue,
    );
    expect(
      DeviceControlAvailability.isDisabled(
        networkStatus: NetworkStatus.online,
        deviceControl: const DeviceControlState(),
      ),
      isTrue,
    );
  });

  testWidgets('mode widget renders socket mode as read-only', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModeWidget(mode: DeviceMode.auto, isDisabled: false),
        ),
      ),
    );

    expect(find.text('Режим'), findsOneWidget);
    expect(find.text('Авто'), findsNWidgets(2));
  });

  testWidgets('state widget uses disabled grey accent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StateWidget(state: DevicePowerState.on, isDisabled: true),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(LucideIcons.power));

    expect(find.text('Увімк.'), findsOneWidget);
    expect(icon.color, AppColors.white);
  });
}
