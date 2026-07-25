import 'memory.dart';
import 'memory_location.dart';
import 'journal_enums.dart';

class MemoryComposerDraft {
  MemoryComposerDraft({
    required this.story,
    required this.date,
    required this.primaryTagId,
    required List<MemoryVoiceMessage> voiceMessages,
    required List<MemoryMediaGroup> mediaGroups,
    required this.category,
    required this.phase,
    required this.updatedAt,
    this.titleOverride,
    this.locationSelection,
  }) : voiceMessages = List.unmodifiable(voiceMessages),
       mediaGroups = List.unmodifiable(mediaGroups);

  factory MemoryComposerDraft.empty({
    required DateTime now,
    required String primaryTagId,
  }) {
    return MemoryComposerDraft(
      story: '',
      date: DateTime(now.year, now.month, now.day),
      primaryTagId: primaryTagId,
      voiceMessages: const [],
      mediaGroups: const [],
      category: MemoryCategory.daily,
      phase: RelationshipPhase.year3,
      updatedAt: now,
    );
  }

  factory MemoryComposerDraft.fromMemory(Memory memory) {
    final legacyNote = memory.note?.trim();
    final story = [
      memory.story.trim(),
      if (legacyNote != null && legacyNote.isNotEmpty) legacyNote,
    ].where((part) => part.isNotEmpty).join('\n\n');
    final groups = memory.mediaGroups.isNotEmpty
        ? memory.mediaGroups
        : memory.media.isEmpty
        ? const <MemoryMediaGroup>[]
        : [
            MemoryMediaGroup(
              id: '${memory.id}-media-group-1',
              items: memory.media,
              sortOrder: 0,
            ),
          ];
    final locationId = memory.locationId;

    return MemoryComposerDraft(
      titleOverride: memory.title,
      story: story,
      date: memory.date,
      primaryTagId: memory.effectiveTagId,
      locationSelection: locationId == null
          ? null
          : MemoryLocationSelection.existing(locationId),
      voiceMessages: memory.voiceMessages,
      mediaGroups: groups,
      category: memory.category,
      phase: memory.phase,
      updatedAt: memory.updatedAt,
    );
  }

  final String? titleOverride;
  final String story;
  final DateTime date;
  final String primaryTagId;
  final MemoryLocationSelection? locationSelection;
  final List<MemoryVoiceMessage> voiceMessages;
  final List<MemoryMediaGroup> mediaGroups;
  final MemoryCategory category;
  final RelationshipPhase phase;
  final DateTime updatedAt;

  bool get hasMeaningfulContent {
    return story.trim().isNotEmpty ||
        voiceMessages.isNotEmpty ||
        mediaGroups.any((group) => group.items.isNotEmpty);
  }

  List<MemoryMedia> get media {
    return mediaGroups.expand((group) => group.items).toList(growable: false);
  }

  int get videoCount {
    return media.where((item) => item.type == MemoryMediaType.video).length;
  }

  MemoryComposerDraft copyWith({
    String? titleOverride,
    bool clearTitleOverride = false,
    String? story,
    DateTime? date,
    String? primaryTagId,
    MemoryLocationSelection? locationSelection,
    bool clearLocationSelection = false,
    List<MemoryVoiceMessage>? voiceMessages,
    List<MemoryMediaGroup>? mediaGroups,
    MemoryCategory? category,
    RelationshipPhase? phase,
    DateTime? updatedAt,
  }) {
    return MemoryComposerDraft(
      titleOverride: clearTitleOverride
          ? null
          : titleOverride ?? this.titleOverride,
      story: story ?? this.story,
      date: date ?? this.date,
      primaryTagId: primaryTagId ?? this.primaryTagId,
      locationSelection: clearLocationSelection
          ? null
          : locationSelection ?? this.locationSelection,
      voiceMessages: voiceMessages ?? this.voiceMessages,
      mediaGroups: mediaGroups ?? this.mediaGroups,
      category: category ?? this.category,
      phase: phase ?? this.phase,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
