import 'package:shared_preferences/shared_preferences.dart';

class Threshold {
  late SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void save(Map data) {
    for (var d in data.entries) {
      switch (d.value.runtimeType) {
        case double:
          prefs.setDouble(d.key, d.value);
          break;
        case bool:
          prefs.setBool(d.key, d.value);
          break;
        case String:
          prefs.setString(d.key, d.value);
          break;
        default:
          throw ("Unknown Type. Please check the value.");
      }
    }
  }

  getThresh(String item) => prefs.get(item);
}
