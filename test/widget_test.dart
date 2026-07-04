import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_love_journal/src/app/love_journal_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows opening gift before entering home', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: LoveJournalApp()));
    await tester.pumpAndSettle();

    expect(find.text('Mở món quà'), findsOneWidget);

    await tester.tap(find.text('Mở món quà'));
    await tester.pumpAndSettle();

    expect(find.text('Mình & Em'), findsOneWidget);
    expect(find.text('Timeline'), findsNothing);
  });
}
