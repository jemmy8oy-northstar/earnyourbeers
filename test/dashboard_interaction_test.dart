import 'package:drift/native.dart';
import 'package:earn_your_beers/core/logic/app_state.dart';
import 'package:earn_your_beers/core/services/database.dart';
import 'package:earn_your_beers/ui/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late AppDatabase database;
  late AppState appState;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    appState = AppState(database);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Weekly History Swipe Navigation', (WidgetTester tester) async {
    // 1. Setup Data
    // Current Week Activity
    await appState.addActivity('Run', 5.0); // Timestamp: Now

    // Last Week Activity (Manual Insert to control timestamp)
    final lastWeek = DateTime.now().subtract(const Duration(days: 7, hours: 1));
    await database.saveActivity(
      ActivitiesCompanion.insert(
        type: 'Cycle',
        amount: 20.0,
        timestamp: lastWeek,
      ),
    );

    // 2. Pump Widget (Wait for Database async stream to update state)
    // We need to wait for AppState to get data.
    // Since AppState uses listen(), it's async.
    // We can just verify initial state, pump loop until data appears?

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: appState)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Wait for the stream listener in AppState to fire and update UI
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 3. Verify Current Week
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Cycle'), findsNothing); // Should be on next page

    // 4. Swipe to Previous Week
    // PageView(reverse: true) means Index 0 is right-most. Index 1 is to the left.
    // To see Index 1, we pull from Left to Right.
    await tester.drag(find.byType(PageView), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // 5. Verify Last Week
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('Run'), findsNothing); // 5km Run is on page 0
  });
}
