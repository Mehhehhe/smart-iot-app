import 'package:shared_preferences/shared_preferences.dart';

class HistoryCache {
  late SharedPreferences _prefs;
  Future<void> init() async => _prefs = await SharedPreferences.getInstance();
  //
  Future<void> saveHistory(List<Map> hist) async {
    // convert map
    List<String> conv = [];
    for (var m in hist) {
      conv.add(m.toString());
    }
    await _prefs.setStringList("history", conv);
  }
}
