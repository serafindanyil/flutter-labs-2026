import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/device_sensors/bloc/device_sensors_state.dart';

class DeviceSensorsCubit extends Cubit<DeviceSensorsState> {
  DeviceSensorsCubit() : super(const DeviceSensorsState());

  void applySensors(Map<String, Object?> payload) {
    emit(
      DeviceSensorsState(
        co2: _parseNumber(payload['co2']),
        humidity: _parseNumber(payload['humidity']),
        innerTemp: _parseTemperature(payload['innerTemp']),
        outerTemp: _parseTemperature(payload['outerTemp']),
        fanInSpd: _parseNumber(payload['fanInSpd']),
        fanOutSpd: _parseNumber(payload['fanOutSpd']),
      ),
    );
  }

  void reset() {
    emit(const DeviceSensorsState());
  }

  num? _parseNumber(Object? value) {
    if (value is num && value.isFinite) return value;
    return null;
  }

  num? _parseTemperature(Object? value) {
    final temperature = _parseNumber(value);
    if (temperature == null) return null;
    if (temperature == DeviceSensorsState.invalidTemperatureValue) return null;
    return temperature;
  }
}
