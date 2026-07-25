abstract interface class KeyValueStore {
  bool getBool(String key, {bool defaultValue = false});
  Future<void> setBool(String key, bool value);

  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);

  List<String> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
}
