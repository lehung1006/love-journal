import 'package:flutter_love_journal/src/core/storage/key_value_store.dart';
import 'package:flutter_love_journal/src/features/journal/application/state/memory_composer_controller.dart';
import 'package:flutter_love_journal/src/features/journal/application/state/memory_composer_state.dart';
import 'package:flutter_love_journal/src/features/journal/data/dtos/journal_data_codec.dart';
import 'package:flutter_love_journal/src/features/journal/data/dtos/memory_composer_draft_codec.dart';
import 'package:flutter_love_journal/src/features/journal/data/repositories/memory_composer_draft_repository_impl.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/journal_entities.dart';
import 'package:flutter_love_journal/src/features/journal/domain/services/memory_attachment_service.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/memory_composer_components.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/memory_composer_date_picker.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/memory_media_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryComposerDraftCodec', () {
    test('round-trips all composer-owned fields', () {
      final updatedAt = DateTime(2026, 7, 21, 19, 30);
      final draft = MemoryComposerDraft(
        titleOverride: 'Một tối thật dịu dàng',
        story: 'Mình đã đi bộ rất lâu bên nhau.',
        date: DateTime(2026, 7, 20),
        primaryTagId: 'custom-date',
        locationSelection: const MemoryLocationSelection.draft(
          MemoryLocationDraft(
            displayName: 'Góc quen của hai đứa',
            formattedAddress: 'Quận 1, TP. Hồ Chí Minh',
            latitude: 10.7769,
            longitude: 106.7009,
            googlePlaceId: 'place-123',
            source: MemoryLocationSource.googlePlaces,
          ),
        ),
        voiceMessages: [
          MemoryVoiceMessage(
            id: 'voice-1',
            uri: 'file:///voice.m4a',
            source: MemoryVoiceMessageSource.recorded,
            durationSeconds: 18,
            waveform: const [.2, .7, .4],
            createdAt: updatedAt,
          ),
        ],
        mediaGroups: const [
          MemoryMediaGroup(
            id: 'group-1',
            title: 'Buổi tối bên hồ',
            note: 'Ánh đèn hôm đó rất đẹp.',
            sortOrder: 0,
            items: [
              MemoryMedia(
                id: 'media-1',
                type: MemoryMediaType.video,
                uri: 'file:///video.mp4',
                thumbnailUri: 'file:///video-thumbnail.jpg',
              ),
            ],
          ),
        ],
        category: MemoryCategory.anniversary,
        phase: RelationshipPhase.year3,
        updatedAt: updatedAt,
      );

      final decoded = MemoryComposerDraftCodec.decode(
        MemoryComposerDraftCodec.encode(draft),
      );

      expect(decoded.titleOverride, draft.titleOverride);
      expect(decoded.story, draft.story);
      expect(decoded.date, draft.date);
      expect(decoded.primaryTagId, draft.primaryTagId);
      expect(
        decoded.mediaGroups.single.items.single.thumbnailUri,
        'file:///video-thumbnail.jpg',
      );
      expect(
        decoded.locationSelection?.draftLocation?.googlePlaceId,
        'place-123',
      );
      expect(decoded.voiceMessages.single.durationSeconds, 18);
      expect(decoded.mediaGroups.single.items.single.uri, 'file:///video.mp4');
      expect(decoded.mediaGroups.single.title, 'Buổi tối bên hồ');
      expect(decoded.category, MemoryCategory.anniversary);
      expect(decoded.phase, RelationshipPhase.year3);
      expect(decoded.updatedAt, updatedAt);
    });
  });

  group('MemoryComposerDraftRepositoryImpl', () {
    test('removes an unreadable persisted draft', () async {
      final store = _MemoryStore()
        ..strings['memoryComposerDraft.v1.new-memory'] = '{not-json';
      final repository = MemoryComposerDraftRepositoryImpl(store);

      final result = await repository.load('new-memory');

      expect(result, isNull);
      expect(store.strings, isEmpty);
    });
  });

  test('journal draft keeps the edited media-group title', () {
    final now = DateTime(2026, 7, 21);
    final memory = Memory(
      id: 'memory-1',
      title: 'Một ngày đẹp',
      date: now,
      category: MemoryCategory.daily,
      phase: RelationshipPhase.year3,
      media: const [],
      story: 'Mình đã ở cạnh nhau.',
      mediaGroups: const [
        MemoryMediaGroup(
          id: 'group-1',
          title: 'Bên hồ lúc hoàng hôn',
          items: [],
          sortOrder: 0,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    final data = JournalData(
      memories: [memory],
      letters: const [],
      places: const [],
    );
    const seed = JournalData(memories: [], letters: [], places: []);

    final restored = JournalDataDraftCodec.applyDraft(
      seed,
      JournalDataDraftCodec.encode(data),
    );

    expect(
      restored.memories.single.mediaGroups.single.title,
      'Bên hồ lúc hoàng hôn',
    );
  });

  group('resolveMemoryTitle', () {
    test('prefers override, then story, location, and tag/date fallback', () {
      final base = MemoryComposerDraft.empty(
        now: DateTime(2026, 7, 21),
        primaryTagId: 'daily',
      );

      expect(
        resolveMemoryTitle(
          draft: base.copyWith(titleOverride: 'Tên riêng'),
          tagName: 'Đời thường',
          locationName: 'Hồ Gươm',
        ),
        'Tên riêng',
      );
      expect(
        resolveMemoryTitle(
          draft: base.copyWith(story: '\nDòng đầu tiên\nDòng sau'),
          tagName: 'Đời thường',
          locationName: 'Hồ Gươm',
        ),
        'Dòng đầu tiên',
      );
      expect(
        resolveMemoryTitle(
          draft: base,
          tagName: 'Đời thường',
          locationName: 'Hồ Gươm',
        ),
        'Hồ Gươm',
      );
      expect(
        resolveMemoryTitle(draft: base, tagName: 'Đời thường'),
        'Đời thường · 21.07.2026',
      );
    });
  });

  testWidgets('date picker changes month without a transition delay', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoryComposerDatePicker(
            initialDate: DateTime(2026, 7, 21),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onSelected: (date) => selected = date,
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tháng 7 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Tháng sau'));
    await tester.pump();

    expect(find.text('Tháng 8 2026'), findsOneWidget);
    await tester.tap(find.text('15'));
    expect(selected, DateTime(2026, 8, 15));
  });

  test('cover video replays twice and stops after the third play', () {
    final policy = MemoryVideoReplayPolicy(automaticPlayCount: 3);

    expect(policy.registerCompletion(), MemoryVideoCompletionAction.replay);
    expect(policy.registerCompletion(), MemoryVideoCompletionAction.replay);
    expect(policy.registerCompletion(), MemoryVideoCompletionAction.stop);
    expect(policy.completedPlays, 3);
    expect(policy.hasAutomaticReplay, isFalse);

    expect(policy.registerCompletion(), MemoryVideoCompletionAction.stop);
  });

  test('media limiter keeps images but enforces three videos per memory', () {
    const incoming = [
      MemoryMedia(
        id: 'video-1',
        type: MemoryMediaType.video,
        uri: 'video-1.mp4',
      ),
      MemoryMedia(
        id: 'image-1',
        type: MemoryMediaType.image,
        uri: 'image-1.jpg',
      ),
      MemoryMedia(
        id: 'video-2',
        type: MemoryMediaType.video,
        uri: 'video-2.mp4',
      ),
    ];

    final accepted = limitMemoryMediaVideos(
      incoming: incoming,
      existingVideoCount: 2,
      maxVideos: MemoryComposerController.maxVideos,
    );

    expect(accepted.map((item) => item.id), ['video-1', 'image-1']);
  });

  test('video import result reports files skipped by the limit', () {
    final result = MemoryMediaImportResult(
      media: const [
        MemoryMedia(
          id: 'video-1',
          type: MemoryMediaType.video,
          uri: 'video-1.mp4',
        ),
      ],
      selectedCount: 3,
    );

    expect(result.wasLimited, isTrue);
    expect(result.skippedByLimit, 2);
  });

  testWidgets('video import overlay shows progress for multiple files', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MemoryComposerMediaImportOverlay(
            completedFiles: 0,
            totalFiles: 3,
          ),
        ),
      ),
    );

    expect(find.text('Đang thêm video 1/3'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _MemoryStore implements KeyValueStore {
  final Map<String, String> strings = {};
  final Map<String, bool> bools = {};
  final Map<String, List<String>> lists = {};

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return bools[key] ?? defaultValue;
  }

  @override
  String? getString(String key) => strings[key];

  @override
  List<String> getStringList(String key) => lists[key] ?? const [];

  @override
  Future<void> remove(String key) async {
    strings.remove(key);
    bools.remove(key);
    lists.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    bools[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    strings[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    lists[key] = [...value];
  }
}
