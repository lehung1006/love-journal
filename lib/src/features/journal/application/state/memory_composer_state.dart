import '../../domain/entities/journal_entities.dart';

enum MemoryComposerStatus { idle, savingDraft, draftSaved, submitting, failed }

class MemoryComposerState {
  const MemoryComposerState({
    required this.draft,
    this.isInitialized = false,
    this.restorableDraft,
    this.status = MemoryComposerStatus.idle,
    this.errorMessage,
  });

  factory MemoryComposerState.initial() {
    final now = DateTime.now();
    return MemoryComposerState(
      draft: MemoryComposerDraft.empty(
        now: now,
        primaryTagId: MemoryTag.systemIdForCategory(MemoryCategory.daily),
      ),
    );
  }

  final MemoryComposerDraft draft;
  final bool isInitialized;
  final MemoryComposerDraft? restorableDraft;
  final MemoryComposerStatus status;
  final String? errorMessage;

  bool get canSubmit {
    return draft.hasMeaningfulContent &&
        status != MemoryComposerStatus.submitting;
  }

  MemoryComposerState copyWith({
    MemoryComposerDraft? draft,
    bool? isInitialized,
    MemoryComposerDraft? restorableDraft,
    bool clearRestorableDraft = false,
    MemoryComposerStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MemoryComposerState(
      draft: draft ?? this.draft,
      isInitialized: isInitialized ?? this.isInitialized,
      restorableDraft: clearRestorableDraft
          ? null
          : restorableDraft ?? this.restorableDraft,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

String resolveMemoryTitle({
  required MemoryComposerDraft draft,
  required String tagName,
  String? locationName,
}) {
  final override = draft.titleOverride?.trim();
  if (override != null && override.isNotEmpty) {
    return override;
  }

  final firstLine = draft.story
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  if (firstLine.isNotEmpty) {
    return firstLine.length <= 56
        ? firstLine
        : '${firstLine.substring(0, 53).trimRight()}...';
  }

  final place = locationName?.trim();
  if (place != null && place.isNotEmpty) {
    return place;
  }

  final day = draft.date.day.toString().padLeft(2, '0');
  final month = draft.date.month.toString().padLeft(2, '0');
  return '$tagName · $day.$month.${draft.date.year}';
}
