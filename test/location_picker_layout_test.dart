import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_love_journal/l10n/app_localizations.dart';
import 'package:flutter_love_journal/src/core/theme/app_theme.dart';
import 'package:flutter_love_journal/src/features/journal/application/state/map_search_controller.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/journal_entities.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/components/location_picker_map_components.dart';
import 'package:flutter_love_journal/src/features/journal/presentation/screens/location_picker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationMapToolbar', () {
    for (final width in [320.0, 360.0, 430.0]) {
      testWidgets('fits a $width logical pixel viewport', (tester) async {
        await _setViewport(tester, width: width);

        await tester.pumpWidget(
          _localizedApp(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LocationMapToolbar(
                selectionMode: false,
                hasSelection: true,
                onSelectionModeChanged: _noopModeChange,
                onReset: _noop,
              ),
            ),
          ),
        );

        expect(find.text('Xem'), findsOneWidget);
        expect(find.text('Chọn vị trí'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('location-picker-map-reset')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('fits large text and keeps reset available', (tester) async {
      await _setViewport(tester, width: 320);

      await tester.pumpWidget(
        _localizedApp(
          textScaler: const TextScaler.linear(2),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LocationMapToolbar(
              selectionMode: true,
              hasSelection: true,
              onSelectionModeChanged: _noopModeChange,
              onReset: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Xem'), findsOneWidget);
      expect(find.text('Chọn vị trí'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('location-picker-map-reset')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('search focus hides and restores the selected-place panel', (
    tester,
  ) async {
    await _setViewport(tester, width: 360);
    await tester.pumpWidget(_localizedApp(child: const _SearchFocusHarness()));

    expect(find.byKey(const ValueKey('selected-place-panel')), findsOneWidget);
    expect(find.text('Hồ Hoàn Kiếm'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('location-picker-search-field')),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('selected-place-panel')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('location-picker-search-field')),
      'Hồ Gươm',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.byKey(const ValueKey('selected-place-panel')), findsOneWidget);
    expect(find.text('Hồ Hoàn Kiếm'), findsOneWidget);
  });

  testWidgets('only the search-map step disables scaffold resize', (
    tester,
  ) async {
    await _setViewport(tester, width: 360);

    await tester.pumpWidget(
      ProviderScope(
        child: _localizedApp(
          child: LocationPickerScreen(
            data: const JournalData(memories: [], letters: [], places: []),
            onSelected: _noopSelection,
            onCancel: _noop,
          ),
        ),
      ),
    );

    final chooseScaffold = tester.widget<Scaffold>(
      find.byKey(const ValueKey('location-picker-choose')),
    );
    expect(chooseScaffold.resizeToAvoidBottomInset, isTrue);

    await tester.tap(find.text('Tìm hoặc ghim một nơi mới').last);
    await tester.pump();

    final searchScaffold = tester.widget<Scaffold>(
      find.byKey(const ValueKey('location-picker-search')),
    );
    expect(searchScaffold.resizeToAvoidBottomInset, isFalse);
  });
}

class _SearchFocusHarness extends StatefulWidget {
  const _SearchFocusHarness();

  @override
  State<_SearchFocusHarness> createState() => _SearchFocusHarnessState();
}

class _SearchFocusHarnessState extends State<_SearchFocusHarness> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          LocationSearchPanel(
            controller: _controller,
            focusNode: _focusNode,
            state: const LocationSearchState(),
            onClear: _controller.clear,
            onSuggestionTap: (_) {},
          ),
          if (!_focusNode.hasFocus && !keyboardVisible)
            const Text('Hồ Hoàn Kiếm', key: ValueKey('selected-place-panel')),
        ],
      ),
    );
  }
}

Future<void> _setViewport(WidgetTester tester, {required double width}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);
}

Widget _localizedApp({
  required Widget child,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, appChild) {
      final mediaQuery = MediaQuery.of(context);
      return MediaQuery(
        data: mediaQuery.copyWith(textScaler: textScaler),
        child: appChild!,
      );
    },
    home: Scaffold(body: SafeArea(child: child)),
  );
}

void _noop() {}

void _noopModeChange(bool value) {}

void _noopSelection(MemoryLocationSelection selection) {}
