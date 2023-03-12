// ignore: file_names
enum DeviceValType {
  temperature,
  humidity,
  npk,
  // HUMIDITY_IN_SOIL
}

class DeviceType {
  final properties = {
    'temperature': {
      'min': 0.0,
      'max': 100.0,
      'unit': 'celsius',
    },
    'humidity': {
      'min': 0.0,
      'max': 100.0,
      'unit': 'percent',
    },
    'npk': {
      'min': 0.0,
      'max': 2000.0,
      'unit': 'mg/kg',
    },
    'light': {
      'min': 0.0,
      'max': 100000.0,
      'unit': 'lx',
    },
  };

  getProps(String type) => properties[type];
}
