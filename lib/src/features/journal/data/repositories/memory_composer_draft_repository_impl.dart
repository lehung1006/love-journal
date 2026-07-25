import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/memory_composer_draft.dart';
import '../../domain/repositories/memory_composer_draft_repository.dart';
import '../dtos/memory_composer_draft_codec.dart';

class MemoryComposerDraftRepositoryImpl
    implements MemoryComposerDraftRepository {
  const MemoryComposerDraftRepositoryImpl(this._store);

  static const _keyPrefix = 'memoryComposerDraft.v1.';

  final KeyValueStore _store;

  @override
  Future<MemoryComposerDraft?> load(String draftId) async {
    final key = _keyFor(draftId);
    final source = _store.getString(key);
    if (source == null || source.isEmpty) {
      return null;
    }
    try {
      return MemoryComposerDraftCodec.decode(source);
    } on FormatException {
      await _store.remove(key);
      return null;
    }
  }

  @override
  Future<void> save(String draftId, MemoryComposerDraft draft) {
    return _store.setString(
      _keyFor(draftId),
      MemoryComposerDraftCodec.encode(draft),
    );
  }

  @override
  Future<void> delete(String draftId) {
    return _store.remove(_keyFor(draftId));
  }

  String _keyFor(String draftId) => '$_keyPrefix$draftId';
}
