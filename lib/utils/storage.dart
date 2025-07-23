import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  SharedPreferences? prefs;

  Future init() async {
    prefs = await _initPrefs();
  }

  Future<SharedPreferences> _initPrefs() async {
    return await SharedPreferences.getInstance();
  }

  void saveStringData(String key, String value) async {
    prefs!.setString(key, value);
  }

  Future<dynamic> getData(String key) async {
    final data = prefs!.get(key);
    return data;
  }

  void removeDate(String key) async {
    prefs!.remove(key);
  }

  bool hasDuplicate(String id, List list) {
    for (Map map in list) {
      if (map['id'] == id) {
        return true;
      }
    }
    return false;
  }
}
