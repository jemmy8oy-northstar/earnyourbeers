import 'package:flutter_test/flutter_test.dart';
import 'package:earn_your_beers/core/logic/pint_calculator.dart';
import 'package:earn_your_beers/core/services/database.dart';

// Mock classes if needed, but Calculator is pure logic so we can just use simple instances if we can instantiate them.
// Activity and Drink are Drift classes. We can instantiate them directly usually.
// If Drift classes are hard to instantiate without a DB, we might need a workaround,
// but usually generated data classes have constructors.

void main() {
  group('PintCalculator Tests', () {
    test('Run calculates 3 points per km', () {
      final activities = [
        Activity(id: 1, type: 'Run', amount: 1.0, timestamp: DateTime.now()),
      ];
      final balance = PintCalculator.calculateBalance(activities, []);
      expect(balance, 3.0);
    });

    test('Cycle calculates 1 point per km', () {
      final activities = [
        Activity(id: 1, type: 'Cycle', amount: 10.0, timestamp: DateTime.now()),
      ];
      final balance = PintCalculator.calculateBalance(activities, []);
      expect(balance, 10.0);
    });

    test('Swim calculates 0.1 point per length', () {
      final activities = [
        Activity(id: 1, type: 'Swim', amount: 30.0, timestamp: DateTime.now()),
      ];
      final balance = PintCalculator.calculateBalance(activities, []);
      expect(balance, 3.0);
    });

    test('Mixed activities sum correctly', () {
      final activities = [
        Activity(
          id: 1,
          type: 'Run',
          amount: 2.0,
          timestamp: DateTime.now(),
        ), // 6 pts
        Activity(
          id: 2,
          type: 'Cycle',
          amount: 5.0,
          timestamp: DateTime.now(),
        ), // 5 pts
      ];
      final balance = PintCalculator.calculateBalance(activities, []);
      expect(balance, 11.0);
    });

    test('Drinks subtract 1 point per unit', () {
      final drinks = [Drink(id: 1, amount: 2.0, timestamp: DateTime.now())];
      final balance = PintCalculator.calculateBalance([], drinks);
      expect(balance, -2.0);
    });

    test('Weekly balance filters out old activities', () {
      final now = DateTime.now();
      // Assume test runs on a non-Monday for safety, or we mock logic.
      // Actually getWeeklyBalance logic uses DateTime.now().
      // To reliably test this without mocking DateTime.now(), we need to inject the "now" or ensure we pick dates far apart.

      // Let's rely on the fact that "now" is the anchor.
      // Activity from 10 days ago should definitely be excluded.
      final oldDate = now.subtract(const Duration(days: 10));

      final activities = [
        Activity(
          id: 1,
          type: 'Run',
          amount: 1.0,
          timestamp: now,
        ), // Should count (3 pts)
        Activity(
          id: 2,
          type: 'Run',
          amount: 1.0,
          timestamp: oldDate,
        ), // Should NOT count
      ];

      // Note: If today is Monday, 10 days ago is last Friday.
      // If "Start of Week" is THIS Monday...
      // If today is Monday, start of week is today 00:00.
      // 10 days ago is definitely out.

      final balance = PintCalculator.getWeeklyBalance(activities, []);
      expect(balance, 3.0);
    });
  });
}
