import 'package:earn_your_beers/core/logic/app_state.dart';
import 'package:earn_your_beers/core/services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late AppState appState;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    appState = AppState(database);
    await appState.initializationDone;
  });

  tearDown(() async {
    await database.close();
  });

  group('League Settlement Logic', () {
    test('single promotion at +25 points', () async {
      await appState.addActivity('Run', 50.0); // 50km = 25 points
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.balance, 25.0);
      expect(appState.currentLevel, 0);
      expect(appState.leagueTally, 0.0);

      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLevel, 1); // Noob -> Novice
      expect(appState.leagueTally, 0.0); // 25 spent
    });

    test('double promotion at +50 points', () async {
      await appState.addActivity('Run', 100.0); // 100km = 50 points
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.balance, 50.0);

      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLevel, 2); // Noob -> Weekender (skip Novice)
      expect(appState.leagueTally, 0.0);
    });

    test('remains stable and carries over tally', () async {
      await appState.addActivity('Run', 20.0); // 20km = 10 points
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.balance, 10.0);

      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLevel, 0);
      expect(appState.leagueTally, 10.0);

      // Next week adds another 15
      await appState.addActivity('Run', 30.0); // 30km = 15 points
      await Future.delayed(const Duration(milliseconds: 100));

      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLevel, 1);
      expect(appState.leagueTally, 0.0); // 10 + 15 = 25
    });

    test('demotion at -25 points', () async {
      // First get to level 1
      await appState.addActivity('Run', 50.0);
      await Future.delayed(const Duration(milliseconds: 100));
      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appState.currentLevel, 1);

      // Now drink 25 units (1 unit = -1 point)
      await appState.addDrink(25.0);
      await Future.delayed(const Duration(milliseconds: 100));

      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLevel, 0); // Demoted
      expect(appState.leagueTally, 0.0);
    });

    test('resetTimeTravel clears future logs and league status', () async {
      // 1. Advance to future and get promoted
      await appState.addActivity('Run', 50.0); // 50km = 25 points
      await Future.delayed(const Duration(milliseconds: 100));
      appState.simulateAdvanceWeek();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appState.currentLevel, 1);

      // 2. Log something in the future
      await appState.addActivity('Run', 20.0); // 20km * 0.5 = 10.0 points
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appState.balance, 35.0); // 25.0 (past) + 10.0 (future)

      // 3. Reset Time Travel
      await appState.resetTimeTravel();
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Verify everything is reset
      expect(appState.currentLevel, 0);
      expect(appState.leagueTally, 0.0);
      expect(appState.balance, 25.0); // Only the future 10.0 should be gone
      expect(appState.activities.length, 1); // Only the first run remains
    });
  });
}
