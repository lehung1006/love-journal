import 'package:shared_preferences/shared_preferences.dart';

class LocalJournalStore {
  LocalJournalStore._(this._preferences);

  static const _hasSeenOpeningKey = 'hasSeenOpening';
  static const _openedLetterIdsKey = 'openedLetterIds';
  static const _favoriteMemoryIdsKey = 'favoriteMemoryIds';
  static const _lastViewedMemoryIdKey = 'lastViewedMemoryId';

  final SharedPreferences _preferences;

  static Future<LocalJournalStore> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalJournalStore._(preferences);
  }

  bool get hasSeenOpening {
    return _preferences.getBool(_hasSeenOpeningKey) ?? false;
  }

  Future<void> setHasSeenOpening(bool value) {
    return _preferences.setBool(_hasSeenOpeningKey, value);
  }

  Set<String> get openedLetterIds {
    return (_preferences.getStringList(_openedLetterIdsKey) ?? const [])
        .toSet();
  }

  Future<void> setOpenedLetterIds(Set<String> ids) {
    return _preferences.setStringList(_openedLetterIdsKey, ids.toList());
  }

  Set<String> get favoriteMemoryIds {
    return (_preferences.getStringList(_favoriteMemoryIdsKey) ?? const [])
        .toSet();
  }

  Future<void> setFavoriteMemoryIds(Set<String> ids) {
    return _preferences.setStringList(_favoriteMemoryIdsKey, ids.toList());
  }

  String? get lastViewedMemoryId {
    return _preferences.getString(_lastViewedMemoryIdKey);
  }

  Future<void> setLastViewedMemoryId(String id) {
    return _preferences.setString(_lastViewedMemoryIdKey, id);
  }
}
