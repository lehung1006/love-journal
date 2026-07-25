import '../entities/memory_composer_draft.dart';

abstract interface class MemoryComposerDraftRepository {
  Future<MemoryComposerDraft?> load(String draftId);
  Future<void> save(String draftId, MemoryComposerDraft draft);
  Future<void> delete(String draftId);
}
