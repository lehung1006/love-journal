import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

class SharedPreferencesKeyValueStore implements KeyValueStore {
  const SharedPreferencesKeyValueStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  @override
  String? getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  List<String> getStringList(String key) {
    return _preferences.getStringList(key) ?? const [];
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }
}
