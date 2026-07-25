import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_love_journal/l10n/app_localizations.dart';
import 'package:flutter_love_journal/src/core/theme/app_theme.dart';
import 'package:flutter_love_journal/src/core/theme/app_tokens.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/journal_entities.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/journal_components.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home responsive states', () {
    for (final width in [320.0, 393.0, 430.0]) {
      testWidgets('renders empty state without overflow at width $width', (
        tester,
      ) async {
        await _setViewport(tester, Size(width, 820));
        await _pumpHome(
          tester,
          data: const JournalData(memories: [], letters: [], places: []),
        );

        expect(find.byType(HomeEmptyHero), findsOneWidget);
        expect(find.byType(HomeMemoryDiscoveryCarousel), findsNothing);
        expect(find.text('Tạo kỷ niệm đầu tiên'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('one memory is used by hero and leaves carousel hidden', (
      tester,
    ) async {
      await _setViewport(tester, const Size(393, 820));
      await _pumpHome(tester, data: _dataWithMemories(1));

      expect(find.byType(HomeLivingHero), findsOneWidget);
      expect(find.byType(HomeMemoryDiscoveryCarousel), findsNothing);
      expect(find.text('Kỷ niệm 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('many memories show recent discovery with next-card peek', (
      tester,
    ) async {
      await _setViewport(tester, const Size(393, 820));
      await _pumpHome(tester, data: _dataWithMemories(7));

      expect(find.byType(HomeMemoryDiscoveryCarousel), findsOneWidget);
      final pageView = tester.widget<PageView>(
        find.byKey(const ValueKey('home-memory-page-view')),
      );
      final controller = pageView.controller!;
      expect(controller.viewportFraction, .86);
      expect(find.byType(PageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large text scale remains stable on a narrow viewport', (
      tester,
    ) async {
      await _setViewport(tester, const Size(320, 820));
      await _pumpHome(
        tester,
        data: _dataWithMemories(4),
        textScaler: const TextScaler.linear(1.45),
      );

      expect(find.byType(HomeLivingHero), findsOneWidget);
      expect(find.byType(HomeStatsRibbon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Home interactions', () {
    testWidgets('hero opens recap', (tester) async {
      await _setViewport(tester, const Size(393, 820));
      var recapTapCount = 0;
      await _pumpHome(
        tester,
        data: _dataWithMemories(2),
        onRecapTap: () => recapTapCount++,
      );

      await tester.tap(find.byKey(const ValueKey('home-living-hero')));
      await tester.pump();

      expect(recapTapCount, 1);
    });

    testWidgets('recent memory opens Memory Detail callback', (tester) async {
      await _setViewport(tester, const Size(393, 820));
      Memory? tappedMemory;
      final data = _dataWithMemories(4);
      await _pumpHome(
        tester,
        data: data,
        onMemoryTap: (memory) => tappedMemory = memory,
      );

      final cardFinder = find.byKey(
        const ValueKey('home-memory-card-memory-4'),
      );
      await tester.ensureVisible(cardFinder);
      await tester.tap(cardFinder);
      await tester.pump();

      expect(tappedMemory?.id, 'memory-4');
    });

    testWidgets('empty CTA opens Add Memory callback', (tester) async {
      await _setViewport(tester, const Size(393, 820));
      var addTapCount = 0;
      await _pumpHome(
        tester,
        data: const JournalData(memories: [], letters: [], places: []),
        onAddMemory: () => addTapCount++,
      );

      await tester.tap(find.text('Tạo kỷ niệm đầu tiên'));
      await tester.pump();

      expect(addTapCount, 1);
    });
  });

  group('Home media and motion', () {
    testWidgets('video cover uses a static thumbnail without a player', (
      tester,
    ) async {
      await _setViewport(tester, const Size(393, 820));
      await _pumpHome(tester, data: _dataWithVideoHero);

      expect(find.byType(MemoryVideoPreview), findsOneWidget);
      expect(find.byType(MemoryVideoPlayer), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reduce Motion reveals content immediately', (tester) async {
      await _setViewport(tester, const Size(393, 820));
      await _pumpHome(
        tester,
        data: _dataWithMemories(4),
        disableAnimations: true,
        settle: false,
      );

      final entranceOpacity = tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(HomeEntrance),
              matching: find.byType(Opacity),
            ),
          )
          .map((widget) => widget.opacity);
      expect(entranceOpacity, isNotEmpty);
      expect(entranceOpacity, everyElement(1));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required JournalData data,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  bool settle = true,
  ValueChanged<Memory>? onMemoryTap,
  ValueChanged<Letter>? onLetterTap,
  VoidCallback? onRecapTap,
  VoidCallback? onAddMemory,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize,
          textScaler: textScaler,
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(
          body: HomeScreen(
            data: data,
            now: _now,
            openedLetterIds: const {},
            onMemoryTap: onMemoryTap ?? (_) {},
            onLetterTap: onLetterTap ?? (_) {},
            onRecapTap: onRecapTap ?? () {},
            onAddMemory: onAddMemory ?? () {},
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

JournalData _dataWithMemories(int count) {
  final memories = [
    for (var index = 1; index <= count; index++)
      Memory(
        id: 'memory-$index',
        title: 'Kỷ niệm $index',
        date: DateTime(2026, index.clamp(1, 12), index),
        category: MemoryCategory.daily,
        phase: RelationshipPhase.year3,
        media: [
          MemoryMedia(
            id: 'media-$index',
            type: MemoryMediaType.image,
            uri: AppAssets.heroImage,
          ),
        ],
        story: 'Một ngày đáng nhớ.',
        locationId: index <= 2 ? 'location-1' : null,
        isFeatured: index == 1,
        createdAt: _now,
        updatedAt: DateTime(2026, 6, index),
      ),
  ];
  return JournalData(
    memories: memories,
    letters: [_letter],
    places: const [],
    locations: count == 0
        ? const []
        : [
            MemoryLocation(
              id: 'location-1',
              displayName: 'Hồ Gươm',
              latitude: 21.0285,
              longitude: 105.8542,
              source: MemoryLocationSource.googlePlaces,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
  );
}

final _dataWithVideoHero = JournalData(
  memories: [
    Memory(
      id: 'video-memory',
      title: 'Một đoạn phim',
      date: _now,
      category: MemoryCategory.anniversary,
      phase: RelationshipPhase.year3,
      media: const [
        MemoryMedia(
          id: 'video-media',
          type: MemoryMediaType.video,
          uri: 'video.mp4',
          thumbnailUri: AppAssets.heroImage,
        ),
      ],
      story: 'Một ngày được giữ lại bằng video.',
      isFeatured: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  letters: const [],
  places: const [],
);

final _letter = Letter(
  id: 'letter-1',
  title: 'Mở khi em nhớ anh',
  occasion: 'Một ngày bình thường',
  preview: 'Có một điều anh muốn kể.',
  body: 'Nội dung lá thư.',
  status: LetterStatus.open,
  coverStyle: LetterCoverStyle.rose,
  pinToHome: true,
);

final _now = DateTime(2026, 6, 5);
