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
    expect(find.text('Cycle'), findsNothing);
    expect(find.text('CURRENT WEEK'), findsOneWidget);

    // 4. Navigate to Previous Week via Header Arrow
    await tester.tap(find.byTooltip('Previous Week'));
    await tester.pumpAndSettle();

    // 5. Verify Last Week
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('Run'), findsNothing);

    // 6. Verify Header Date (Last Week)
    expect(find.text('CURRENT WEEK'), findsNothing);
    expect(find.textContaining('WEEK OF'), findsOneWidget);

    // 7. Verify Cannot Go Back Further (Constraint Logic)
    // We added data 1 week ago. Page count should be 2.
    // We are at Index 1 (Last Week). Next arrow (Previous Week) should be disabled/gone.
    // "Previous Week" arrow is the LEFT arrow.
    // In our UI code: onPressed: canGoBack ? ... : null

    // Attempt to tap Previous Week again
    await tester.tap(find.byTooltip('Previous Week'));
    await tester.pumpAndSettle();

    // Should still be on Last Week (Cycle visible)
    expect(find.text('Cycle'), findsOneWidget);
    // Should NOT have moved to a 3rd page (empty)
  });
}
