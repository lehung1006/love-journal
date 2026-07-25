import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/journal_entities.dart';
import '../providers/journal_providers.dart';
import '../providers/memory_composer_providers.dart';
import 'memory_composer_state.dart';

final memoryComposerControllerProvider = NotifierProvider.family
    .autoDispose<MemoryComposerController, MemoryComposerState, String>(
      MemoryComposerController.new,
    );

class MemoryComposerController extends Notifier<MemoryComposerState> {
  MemoryComposerController(this.draftId);

  static const maxMediaGroups = 3;
  static const maxVoiceMessages = 3;
  static const maxVideos = 3;

  final String draftId;
  Timer? _saveTimer;

  @override
  MemoryComposerState build() {
    ref.onDispose(() => _saveTimer?.cancel());
    return MemoryComposerState.initial();
  }

  Future<void> initialize(MemoryComposerDraft baseDraft) async {
    if (state.isInitialized) {
      return;
    }
    final repository = await ref.read(
      memoryComposerDraftRepositoryProvider.future,
    );
    final stored = await repository.load(draftId);
    state = state.copyWith(
      draft: baseDraft,
      isInitialized: true,
      restorableDraft: stored?.hasMeaningfulContent == true ? stored : null,
      status: MemoryComposerStatus.idle,
      clearError: true,
    );
  }

  void resumeStoredDraft() {
    final stored = state.restorableDraft;
    if (stored == null) {
      return;
    }
    state = state.copyWith(
      draft: stored,
      clearRestorableDraft: true,
      status: MemoryComposerStatus.draftSaved,
    );
  }

  Future<void> discardStoredDraft() async {
    await ref
        .read(memoryComposerDraftRepositoryProvider.future)
        .then((repository) => repository.delete(draftId));
    state = state.copyWith(clearRestorableDraft: true);
  }

  void setTitle(String value) {
    _update(
      (draft, now) => draft.copyWith(
        titleOverride: value,
        clearTitleOverride: value.trim().isEmpty,
        updatedAt: now,
      ),
    );
  }

  void setStory(String value) {
    _update((draft, now) => draft.copyWith(story: value, updatedAt: now));
  }

  void setDate(DateTime value) {
    _update((draft, now) => draft.copyWith(date: value, updatedAt: now));
  }

  void setTag(String tagId) {
    _update(
      (draft, now) => draft.copyWith(primaryTagId: tagId, updatedAt: now),
    );
  }

  void setLocation(MemoryLocationSelection? selection) {
    _update(
      (draft, now) => draft.copyWith(
        locationSelection: selection,
        clearLocationSelection: selection == null,
        updatedAt: now,
      ),
    );
  }

  void addVoiceMessage(MemoryVoiceMessage message) {
    if (state.draft.voiceMessages.length >= maxVoiceMessages) {
      return;
    }
    _update(
      (draft, now) => draft.copyWith(
        voiceMessages: [...draft.voiceMessages, message],
        updatedAt: now,
      ),
    );
  }

  void removeVoiceMessage(String messageId) {
    _update(
      (draft, now) => draft.copyWith(
        voiceMessages: [
          for (final message in draft.voiceMessages)
            if (message.id != messageId) message,
        ],
        updatedAt: now,
      ),
    );
  }

  void addMediaGroup(List<MemoryMedia> items) {
    if (items.isEmpty || state.draft.mediaGroups.length >= maxMediaGroups) {
      return;
    }
    final acceptedItems = limitMemoryMediaVideos(
      incoming: items,
      existingVideoCount: state.draft.videoCount,
      maxVideos: maxVideos,
    );
    if (acceptedItems.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final groups = state.draft.mediaGroups;
    _update(
      (draft, _) => draft.copyWith(
        mediaGroups: [
          ...groups,
          MemoryMediaGroup(
            id: 'group-${now.microsecondsSinceEpoch}',
            items: acceptedItems,
            sortOrder: groups.length,
          ),
        ],
        updatedAt: now,
      ),
    );
  }

  void addMedia(String groupId, List<MemoryMedia> items) {
    if (items.isEmpty) {
      return;
    }
    final acceptedItems = limitMemoryMediaVideos(
      incoming: items,
      existingVideoCount: state.draft.videoCount,
      maxVideos: maxVideos,
    );
    if (acceptedItems.isEmpty) {
      return;
    }
    _update(
      (draft, now) => draft.copyWith(
        mediaGroups: [
          for (final group in draft.mediaGroups)
            if (group.id == groupId)
              group.copyWith(items: [...group.items, ...acceptedItems])
            else
              group,
        ],
        updatedAt: now,
      ),
    );
  }

  void updateGroupNote(String groupId, String value) {
    _update(
      (draft, now) => draft.copyWith(
        mediaGroups: [
          for (final group in draft.mediaGroups)
            if (group.id == groupId)
              group.copyWith(note: value, clearNote: value.trim().isEmpty)
            else
              group,
        ],
        updatedAt: now,
      ),
    );
  }

  void updateGroupTitle(String groupId, String value) {
    _update(
      (draft, now) => draft.copyWith(
        mediaGroups: [
          for (final group in draft.mediaGroups)
            if (group.id == groupId)
              group.copyWith(title: value, clearTitle: value.trim().isEmpty)
            else
              group,
        ],
        updatedAt: now,
      ),
    );
  }

  void removeMedia(String groupId, String mediaId) {
    _update(
      (draft, now) => draft.copyWith(
        mediaGroups: [
          for (final group in draft.mediaGroups)
            if (group.id == groupId)
              group.copyWith(
                items: [
                  for (final media in group.items)
                    if (media.id != mediaId) media,
                ],
              )
            else
              group,
        ],
        updatedAt: now,
      ),
    );
  }

  void removeMediaGroup(String groupId) {
    _update((draft, now) {
      final remaining = [
        for (final group in draft.mediaGroups)
          if (group.id != groupId) group,
      ];
      return draft.copyWith(
        mediaGroups: [
          for (var index = 0; index < remaining.length; index++)
            remaining[index].copyWith(sortOrder: index),
        ],
        updatedAt: now,
      );
    });
  }

  void moveMediaGroup(String groupId, int offset) {
    final groups = [...state.draft.mediaGroups];
    final current = groups.indexWhere((group) => group.id == groupId);
    final target = current + offset;
    if (current < 0 || target < 0 || target >= groups.length) {
      return;
    }
    final moved = groups.removeAt(current);
    groups.insert(target, moved);
    _update(
      (draft, now) => draft.copyWith(
        mediaGroups: [
          for (var index = 0; index < groups.length; index++)
            groups[index].copyWith(sortOrder: index),
        ],
        updatedAt: now,
      ),
    );
  }

  Future<Memory?> submit({
    required String title,
    required Future<Memory> Function(MemoryDraft draft) onSubmit,
  }) async {
    if (!state.canSubmit) {
      return null;
    }
    _saveTimer?.cancel();
    final draft = state.draft;
    state = state.copyWith(
      status: MemoryComposerStatus.submitting,
      clearError: true,
    );
    try {
      final selection = draft.locationSelection;
      final memory = await onSubmit(
        MemoryDraft(
          title: title,
          story: draft.story,
          date: draft.date,
          primaryTagId: draft.primaryTagId,
          locationId: selection?.existingLocationId,
          newLocation: selection?.draftLocation,
          voiceMessages: draft.voiceMessages,
          mediaGroups: draft.mediaGroups
              .where(
                (group) =>
                    group.items.isNotEmpty ||
                    group.note?.trim().isNotEmpty == true,
              )
              .toList(growable: false),
          category: draft.category,
          phase: draft.phase,
        ),
      );
      await ref
          .read(memoryComposerDraftRepositoryProvider.future)
          .then((repository) => repository.delete(draftId));
      state = state.copyWith(status: MemoryComposerStatus.idle);
      return memory;
    } catch (error) {
      state = state.copyWith(
        status: MemoryComposerStatus.failed,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    final draft = state.draft;
    if (!state.isInitialized) {
      return;
    }
    try {
      final repository = await ref.read(
        memoryComposerDraftRepositoryProvider.future,
      );
      if (draft.hasMeaningfulContent) {
        await repository.save(draftId, draft);
      } else {
        await repository.delete(draftId);
      }
      if (state.status != MemoryComposerStatus.submitting) {
        state = state.copyWith(status: MemoryComposerStatus.draftSaved);
      }
    } catch (error) {
      state = state.copyWith(
        status: MemoryComposerStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  void _update(
    MemoryComposerDraft Function(MemoryComposerDraft draft, DateTime now)
    transform,
  ) {
    if (!state.isInitialized) {
      return;
    }
    final next = transform(state.draft, DateTime.now());
    state = state.copyWith(
      draft: next,
      status: MemoryComposerStatus.savingDraft,
      clearError: true,
    );
    _scheduleSave(next);
  }

  void _scheduleSave(MemoryComposerDraft draft) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 550), () async {
      try {
        final repository = await ref.read(
          memoryComposerDraftRepositoryProvider.future,
        );
        if (draft.hasMeaningfulContent) {
          await repository.save(draftId, draft);
        } else {
          await repository.delete(draftId);
        }
        if (state.draft.updatedAt == draft.updatedAt) {
          state = state.copyWith(status: MemoryComposerStatus.draftSaved);
        }
      } catch (error) {
        state = state.copyWith(
          status: MemoryComposerStatus.failed,
          errorMessage: error.toString(),
        );
      }
    });
  }
}

List<MemoryMedia> limitMemoryMediaVideos({
  required List<MemoryMedia> incoming,
  required int existingVideoCount,
  required int maxVideos,
}) {
  var remainingVideos = (maxVideos - existingVideoCount).clamp(0, maxVideos);
  final accepted = <MemoryMedia>[];
  for (final item in incoming) {
    if (item.type == MemoryMediaType.video) {
      if (remainingVideos == 0) {
        continue;
      }
      remainingVideos -= 1;
    }
    accepted.add(item);
  }
  return List.unmodifiable(accepted);
}
