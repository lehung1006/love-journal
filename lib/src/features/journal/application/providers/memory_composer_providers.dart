import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/memory_composer_draft_repository_impl.dart';
import '../../domain/repositories/memory_composer_draft_repository.dart';

final memoryComposerDraftRepositoryProvider =
    FutureProvider<MemoryComposerDraftRepository>((ref) async {
      final store = await ref.watch(keyValueStoreProvider.future);
      return MemoryComposerDraftRepositoryImpl(store);
    });
