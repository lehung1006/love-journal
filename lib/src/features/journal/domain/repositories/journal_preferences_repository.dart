import '../entities/journal_preferences.dart';

abstract interface class JournalPreferencesRepository {
  Future<JournalPreferences> load();
  Future<void> setHasSeenOpening(bool value);
  Future<void> setOpenedLetterIds(Set<String> ids);
  Future<void> setFavoriteMemoryIds(Set<String> ids);
  Future<void> setLastViewedMemoryId(String id);
}
