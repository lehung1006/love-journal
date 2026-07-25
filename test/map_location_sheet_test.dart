import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_love_journal/l10n/app_localizations.dart';
import 'package:flutter_love_journal/src/core/config/map_service_config.dart';
import 'package:flutter_love_journal/src/core/theme/app_theme.dart';
import 'package:flutter_love_journal/src/features/journal/application/providers/map_providers.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/journal_entities.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/location_memory_list_sheet.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/screens/map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('location sheet is presented above the shell tab bar', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);

    var tabTapCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapServiceConfigProvider.overrideWith(
            (ref) async => const MapServiceConfig(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => MapScreen(
                        data: _journalData,
                        onMemoryTap: (_) {},
                        onAddMemory: () {},
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: GestureDetector(
                    key: const ValueKey('shell-tab-bar'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => tabTapCount++,
                    child: const SizedBox(height: 64),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('VNPT'));
    await tester.pumpAndSettle();

    expect(find.byType(LocationMemoryListSheet), findsOneWidget);

    final tabBarCenter = tester.getCenter(
      find.byKey(const ValueKey('shell-tab-bar')),
    );
    await tester.tapAt(tabBarCenter);
    await tester.pump();

    expect(tabTapCount, 0);
    expect(find.byType(LocationMemoryListSheet), findsOneWidget);
  });
}

final _now = DateTime(2026, 6, 5);

final _journalData = JournalData(
  memories: [
    Memory(
      id: 'memory-1',
      title: 'Sinh nhật',
      date: _now,
      category: MemoryCategory.birthday,
      phase: RelationshipPhase.year1,
      media: const [],
      story: 'Một ngày đáng nhớ.',
      locationId: 'location-1',
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  letters: const [],
  places: const [],
  locations: [
    MemoryLocation(
      id: 'location-1',
      displayName: 'VNPT',
      formattedAddress: '270b Đ. Lý Thường Kiệt, Hồ Chí Minh',
      latitude: 10.7769,
      longitude: 106.7009,
      source: MemoryLocationSource.googlePlaces,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
);
