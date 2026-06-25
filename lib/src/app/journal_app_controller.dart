import 'package:flutter/foundation.dart';

import '../features/journal/data/local_journal_store.dart';
import '../features/journal/domain/journal_models.dart';

class JournalAppController extends ChangeNotifier {
  JournalAppController({required this.data, required LocalJournalStore store})
    : _store = store {
    _hasSeenOpening = store.hasSeenOpening;
    _openedLetterIds = store.openedLetterIds;
    _favoriteMemoryIds = store.favoriteMemoryIds;
  }

  final JournalData data;
  final LocalJournalStore _store;

  late bool _hasSeenOpening;
  late Set<String> _openedLetterIds;
  late Set<String> _favoriteMemoryIds;

  bool get hasSeenOpening => _hasSeenOpening;
  Set<String> get openedLetterIds => Set.unmodifiable(_openedLetterIds);
  Set<String> get favoriteMemoryIds => Set.unmodifiable(_favoriteMemoryIds);

  Future<void> completeOpening() async {
    _hasSeenOpening = true;
    notifyListeners();
    await _store.setHasSeenOpening(true);
  }

  Future<void> markLetterOpened(String letterId) async {
    if (_openedLetterIds.contains(letterId)) {
      return;
    }
    _openedLetterIds = {..._openedLetterIds, letterId};
    notifyListeners();
    await _store.setOpenedLetterIds(_openedLetterIds);
  }

  Future<void> toggleFavoriteMemory(String memoryId) async {
    final next = {..._favoriteMemoryIds};
    if (!next.add(memoryId)) {
      next.remove(memoryId);
    }
    _favoriteMemoryIds = next;
    notifyListeners();
    await _store.setFavoriteMemoryIds(_favoriteMemoryIds);
  }

  Future<void> markLastViewedMemory(String memoryId) {
    return _store.setLastViewedMemoryId(memoryId);
  }

  bool isFavoriteMemory(String memoryId) {
    return _favoriteMemoryIds.contains(memoryId);
  }

  bool isLetterOpened(String letterId) {
    return _openedLetterIds.contains(letterId);
  }
}
