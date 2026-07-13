import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/data_sources/journal_api_data_source.dart';
import '../../data/dtos/journal_data_codec.dart';
import '../../data/repositories/journal_preferences_repository_impl.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entities.dart';
import '../../domain/repositories/journal_preferences_repository.dart';
import '../../domain/repositories/journal_repository.dart';

final journalApiDataSourceProvider = Provider<JournalApiDataSource>((ref) {
  return JournalAssetApiDataSource(ref.watch(apiClientProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalApiDataSourceProvider));
});

final journalPreferencesRepositoryProvider =
    FutureProvider<JournalPreferencesRepository>((ref) async {
      final store = await ref.watch(keyValueStoreProvider.future);
      return JournalPreferencesRepositoryImpl(store);
    });

final journalDataProvider =
    AsyncNotifierProvider<JournalDataController, JournalData>(
      JournalDataController.new,
    );

class MemoryDraft {
  const MemoryDraft({
    required this.title,
    required this.story,
    required this.date,
    required this.primaryTagId,
    required this.voiceMessages,
    required this.mediaGroups,
    this.locationId,
    this.newLocation,
    this.note,
    this.category = MemoryCategory.daily,
    this.phase = RelationshipPhase.year3,
  });

  final String title;
  final String story;
  final DateTime date;
  final String primaryTagId;
  final String? locationId;
  final MemoryLocationDraft? newLocation;
  final String? note;
  final List<MemoryVoiceMessage> voiceMessages;
  final List<MemoryMediaGroup> mediaGroups;
  final MemoryCategory category;
  final RelationshipPhase phase;

  factory MemoryDraft.fromMemory(Memory memory) {
    return MemoryDraft(
      title: memory.title,
      story: memory.story,
      date: memory.date,
      primaryTagId: memory.effectiveTagId,
      locationId: memory.locationId,
      note: memory.note,
      voiceMessages: memory.voiceMessages,
      mediaGroups: memory.mediaGroups,
      category: memory.category,
      phase: memory.phase,
    );
  }
}

class JournalDataController extends AsyncNotifier<JournalData> {
  static const _draftKey = 'journalDataDraft.v2';

  @override
  Future<JournalData> build() async {
    final seed = await ref.watch(journalRepositoryProvider).fetchJournal();
    final store = await ref.watch(keyValueStoreProvider.future);
    final draft = store.getString(_draftKey);
    if (draft == null || draft.isEmpty) {
      return seed;
    }
    return JournalDataDraftCodec.applyDraft(seed, draft);
  }

  Future<Memory> createMemory(MemoryDraft draft) async {
    final current = await future;
    final now = DateTime.now();
    final resolvedLocation = _resolveLocation(current, draft, now);
    final memory = _memoryFromDraft(
      id: _newId('memory', now),
      draft: draft,
      createdAt: now,
      updatedAt: now,
      isFeatured: current.visibleMemories.isEmpty,
      location: resolvedLocation.location,
    );
    final updated = _sortMemories(
      current.copyWith(
        memories: [...current.memories, memory],
        locations: resolvedLocation.locations,
      ),
    );
    await _setData(updated);
    return memory;
  }

  Future<Memory> updateMemory(String memoryId, MemoryDraft draft) async {
    final current = await future;
    final existing = current.memoryById(memoryId);
    final now = DateTime.now();
    final resolvedLocation = _resolveLocation(current, draft, now);
    final updatedMemory = _memoryFromDraft(
      id: existing.id,
      draft: draft,
      createdAt: existing.createdAt,
      updatedAt: now,
      isFeatured: existing.isFeatured,
      coverMediaId: existing.coverMediaId,
      location: resolvedLocation.location,
    );
    final updated = _sortMemories(
      current.copyWith(
        memories: [
          for (final memory in current.memories)
            if (memory.id == memoryId) updatedMemory else memory,
        ],
        locations: resolvedLocation.locations,
      ),
    );
    await _setData(updated);
    return updatedMemory;
  }

  Future<void> softDeleteMemory(String memoryId) async {
    final current = await future;
    final now = DateTime.now();
    final updatedMemories = [
      for (final memory in current.memories)
        if (memory.id == memoryId)
          memory.copyWith(deletedAt: now, updatedAt: now, isFeatured: false)
        else
          memory,
    ];
    var updated = current.copyWith(memories: updatedMemories);
    if (updated.featuredMemoryOrNull == null &&
        updated.visibleMemories.isNotEmpty) {
      final nextFeatured = updated.visibleMemories.first;
      updated = updated.copyWith(
        memories: [
          for (final memory in updated.memories)
            memory.id == nextFeatured.id
                ? memory.copyWith(isFeatured: true)
                : memory,
        ],
      );
    }
    await _setData(updated);
  }

  Future<void> setFeaturedMemory(String memoryId) async {
    final current = await future;
    final updated = current.copyWith(
      memories: [
        for (final memory in current.memories)
          memory.copyWith(
            isFeatured: memory.id == memoryId && !memory.isDeleted,
          ),
      ],
    );
    await _setData(updated);
  }

  Future<MemoryTag> createTag(String rawName) async {
    final current = await future;
    final name = rawName.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(
        rawName,
        'rawName',
        'Tag name cannot be empty.',
      );
    }

    for (final tag in current.tags) {
      if (tag.name.toLowerCase() == name.toLowerCase()) {
        return tag;
      }
    }

    final now = DateTime.now();
    final tag = MemoryTag(
      id: _newId('tag', now),
      name: name,
      colorKey: _nextTagColor(current.tags.length),
      createdAt: now,
      updatedAt: now,
    );
    await _setData(current.copyWith(tags: [...current.tags, tag]));
    return tag;
  }

  Memory _memoryFromDraft({
    required String id,
    required MemoryDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isFeatured,
    required MemoryLocation? location,
    String? coverMediaId,
  }) {
    final media = draft.mediaGroups
        .expand((group) => group.items)
        .toList(growable: false);
    final category = _categoryForTagId(draft.primaryTagId) ?? draft.category;

    return Memory(
      id: id,
      title: draft.title.trim(),
      date: draft.date,
      category: category,
      phase: draft.phase,
      primaryTagId: draft.primaryTagId,
      locationId: location?.id,
      locationName: location?.displayName,
      latitude: location?.latitude,
      longitude: location?.longitude,
      media: media,
      coverMediaId: coverMediaId ?? (media.isEmpty ? null : media.first.id),
      story: draft.story.trim(),
      note: _blankToNull(draft.note),
      voiceMessages: draft.voiceMessages,
      mediaGroups: draft.mediaGroups,
      isFeatured: isFeatured,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  _ResolvedLocation _resolveLocation(
    JournalData current,
    MemoryDraft draft,
    DateTime now,
  ) {
    final locationDraft = draft.newLocation;
    if (locationDraft != null) {
      final displayName = locationDraft.displayName.trim();
      if (displayName.isEmpty || !locationDraft.hasValidCoordinate) {
        throw ArgumentError(
          'A valid location name and coordinate are required.',
        );
      }

      final googlePlaceId = _blankToNull(locationDraft.googlePlaceId);
      if (googlePlaceId != null) {
        for (final existing in current.locations) {
          if (existing.googlePlaceId == googlePlaceId) {
            return _ResolvedLocation(
              location: existing,
              locations: current.locations,
            );
          }
        }
      }

      final location = MemoryLocation(
        id: _newId('location', now),
        displayName: displayName,
        formattedAddress: _blankToNull(locationDraft.formattedAddress),
        latitude: locationDraft.latitude,
        longitude: locationDraft.longitude,
        googlePlaceId: googlePlaceId,
        source: locationDraft.source,
        createdAt: now,
        updatedAt: now,
      );
      return _ResolvedLocation(
        location: location,
        locations: List.unmodifiable([...current.locations, location]),
      );
    }

    final locationId = _blankToNull(draft.locationId);
    if (locationId == null) {
      return _ResolvedLocation(location: null, locations: current.locations);
    }

    final location = current.locationByIdOrNull(locationId);
    if (location == null) {
      throw StateError('Unknown memory location: $locationId');
    }
    return _ResolvedLocation(location: location, locations: current.locations);
  }

  MemoryCategory? _categoryForTagId(String tagId) {
    for (final category in MemoryCategory.values) {
      if (MemoryTag.systemIdForCategory(category) == tagId) {
        return category;
      }
    }
    return null;
  }

  JournalData _sortMemories(JournalData data) {
    final memories = [...data.memories]
      ..sort((a, b) => b.date.compareTo(a.date));
    return data.copyWith(memories: List.unmodifiable(memories));
  }

  Future<void> _setData(JournalData data) async {
    final normalized = _sortMemories(data);
    state = AsyncData(normalized);
    final store = await ref.read(keyValueStoreProvider.future);
    await store.setString(_draftKey, JournalDataDraftCodec.encode(normalized));
  }

  String _newId(String prefix, DateTime now) {
    return '$prefix-${now.microsecondsSinceEpoch}';
  }

  String? _blankToNull(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String _nextTagColor(int index) {
    const colors = ['rose', 'teal', 'moss', 'amber', 'lavender'];
    return colors[index % colors.length];
  }
}

class _ResolvedLocation {
  const _ResolvedLocation({required this.location, required this.locations});

  final MemoryLocation? location;
  final List<MemoryLocation> locations;
}
