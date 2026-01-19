import 'package:earn_your_beers/core/logic/app_state.dart';
import 'package:earn_your_beers/core/services/database.dart';
import 'package:earn_your_beers/ui/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late AppState appState;

  setUp(() async {
    // Use an in-memory database for testing
    database = AppDatabase(NativeDatabase.memory());
    appState = AppState(database);
    await appState.initializationDone;
  });

  tearDown(() async {
    await database.close();
  });

  group('AppState Vice Settings', () {
    test('defaults to Pizza emoji', () {
      expect(appState.viceEmoji, '🍕');
      expect(appState.viceName, 'Pizza');
    });

    test('updates vice and persists to database', () async {
      await appState.updateVice('🎮');

      expect(appState.viceEmoji, '🎮');

      // Verify persistence
      final savedEmoji = await database.getSetting('vice_emoji');
      expect(savedEmoji, '🎮');
    });

    test('updates theme mode', () async {
      expect(appState.themeMode, ThemeMode.system);

      await appState.updateTheme(ThemeMode.dark);

      expect(appState.themeMode, ThemeMode.dark);

      // Verify persistence
      final savedTheme = await database.getSetting('theme_mode');
      expect(savedTheme, 'ThemeMode.dark');
    });
  });

  group('Dashboard UI Rebrand', () {
    testWidgets('shows new title and vice emoji', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const DashboardScreen(),
          ),
        ),
      );
      // Use pump with duration to let initial build complete
      await tester.pump(const Duration(milliseconds: 500));

      // Verify rebranded title
      expect(find.text('Earn Your Vices'), findsOneWidget);

      // Verify settings icon exists
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Verify the FAB shows the vice emoji (Pizza by default)
      expect(find.textContaining('Log 🍕'), findsOneWidget);
    });

    testWidgets('settings dialog opens and shows vice options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const DashboardScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Tap settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify dialog opened
      expect(find.text('Edit Your Vice 😈'), findsOneWidget);
      expect(find.text('Pick an Emoji'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      // Verify quick picks exist by finding ActionChips with those labels
      expect(find.widgetWithText(ActionChip, 'Pizza'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Gaming'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Treat'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Soda'), findsOneWidget);
    });

    testWidgets('tapping quick pick updates appState', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const DashboardScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial state
      expect(appState.viceEmoji, '🍕');
      expect(appState.viceName, 'Pizza');

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Gaming quick pick (updates the text controllers)
      await tester.tap(find.widgetWithText(ActionChip, 'Gaming'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Save button - this should call updateVice on AppState
      await tester.tap(find.text('Save'));
      // Process the dialog close and async updateVice call
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify AppState was updated
      expect(appState.viceEmoji, '🎮');
      expect(appState.viceName, 'Gaming');
    });
  });
}
