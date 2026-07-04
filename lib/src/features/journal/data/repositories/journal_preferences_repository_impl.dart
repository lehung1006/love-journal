import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/journal_preferences.dart';
import '../../domain/repositories/journal_preferences_repository.dart';

class JournalPreferencesRepositoryImpl implements JournalPreferencesRepository {
  const JournalPreferencesRepositoryImpl(this._store);

  static const _hasSeenOpeningKey = 'hasSeenOpening';
  static const _openedLetterIdsKey = 'openedLetterIds';
  static const _favoriteMemoryIdsKey = 'favoriteMemoryIds';
  static const _lastViewedMemoryIdKey = 'lastViewedMemoryId';

  final KeyValueStore _store;

  @override
  Future<JournalPreferences> load() async {
    return JournalPreferences(
      hasSeenOpening: _store.getBool(_hasSeenOpeningKey),
      openedLetterIds: _store.getStringList(_openedLetterIdsKey).toSet(),
      favoriteMemoryIds: _store.getStringList(_favoriteMemoryIdsKey).toSet(),
      lastViewedMemoryId: _store.getString(_lastViewedMemoryIdKey),
    );
  }

  @override
  Future<void> setHasSeenOpening(bool value) {
    return _store.setBool(_hasSeenOpeningKey, value);
  }

  @override
  Future<void> setOpenedLetterIds(Set<String> ids) {
    return _store.setStringList(_openedLetterIdsKey, ids.toList());
  }

  @override
  Future<void> setFavoriteMemoryIds(Set<String> ids) {
    return _store.setStringList(_favoriteMemoryIdsKey, ids.toList());
  }

  @override
  Future<void> setLastViewedMemoryId(String id) {
    return _store.setString(_lastViewedMemoryIdKey, id);
  }
}
