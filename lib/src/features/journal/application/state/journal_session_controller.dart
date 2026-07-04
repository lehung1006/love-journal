import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/journal_preferences.dart';
import '../providers/journal_providers.dart';

class JournalSessionController extends AsyncNotifier<JournalPreferences> {
  @override
  Future<JournalPreferences> build() async {
    final repository = await ref.watch(
      journalPreferencesRepositoryProvider.future,
    );
    return repository.load();
  }

  Future<void> completeOpening() async {
    final current = _currentPreferences;
    final next = current.copyWith(hasSeenOpening: true);
    state = AsyncData(next);

    final repository = await ref.read(
      journalPreferencesRepositoryProvider.future,
    );
    await repository.setHasSeenOpening(true);
  }

  Future<void> markLetterOpened(String letterId) async {
    final current = _currentPreferences;
    if (current.openedLetterIds.contains(letterId)) {
      return;
    }

    final nextIds = {...current.openedLetterIds, letterId};
    state = AsyncData(current.copyWith(openedLetterIds: nextIds));

    final repository = await ref.read(
      journalPreferencesRepositoryProvider.future,
    );
    await repository.setOpenedLetterIds(nextIds);
  }

  Future<void> toggleFavoriteMemory(String memoryId) async {
    final current = _currentPreferences;
    final nextIds = {...current.favoriteMemoryIds};
    if (!nextIds.add(memoryId)) {
      nextIds.remove(memoryId);
    }

    state = AsyncData(current.copyWith(favoriteMemoryIds: nextIds));

    final repository = await ref.read(
      journalPreferencesRepositoryProvider.future,
    );
    await repository.setFavoriteMemoryIds(nextIds);
  }

  Future<void> markLastViewedMemory(String memoryId) async {
    final current = _currentPreferences;
    state = AsyncData(current.copyWith(lastViewedMemoryId: memoryId));

    final repository = await ref.read(
      journalPreferencesRepositoryProvider.future,
    );
    await repository.setLastViewedMemoryId(memoryId);
  }

  JournalPreferences get _currentPreferences {
    return state.value ?? const JournalPreferences.empty();
  }
}

final journalSessionControllerProvider =
    AsyncNotifierProvider<JournalSessionController, JournalPreferences>(
      JournalSessionController.new,
    );
