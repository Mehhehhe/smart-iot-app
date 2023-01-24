enum DEVICEVAL_TYPE {
  TEMPERATURE_IN_AIR,
  HUMIDITY_IN_AIR,
  NPK,
  HUMIDITY_IN_SOIL
}

class DeviceType {
  final properties = {
    'temperature': {'min': 0.0, 'max': 100.0, 'unit': 'celsius'},
    'humidity': {'min': 0.0, 'max': 100.0, 'unit': 'percent'},
    'npk': {}
  };
}

class Device {
  final String device_type;
  const Device._({required this.device_type});
  const Device.temperature(dynamic data, [String device_type = "temperature"])
      : this._(device_type: device_type);
}
