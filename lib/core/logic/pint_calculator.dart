import '../services/database.dart';

class PintCalculator {
  // Standardized Activity Types
  static const String typeRun = 'Run';
  static const String typeCycle = 'Cycle';
  static const String typeSwim = 'Swim';

  // Points Multipliers (per unit)
  // Run: 1 km = 3 Points
  // Bike: 1 km = 1 Point
  // Swim: 10 lengths = 1 Point (so 1 length = 0.1 Point)
  static const double pointsPerKmRun = 0.5;
  static const double pointsPerKmCycle = 1.0 / 15.0;
  static const double pointsPerLengthSwim = 1.0 / 30.0;

  static double calculateBalance(
    List<Activity> activities,
    List<Drink> drinks,
  ) {
    double totalEarned = 0;
    for (var activity in activities) {
      switch (activity.type) {
        case typeRun:
          totalEarned += (activity.amount * pointsPerKmRun);
          break;
        case typeCycle:
          totalEarned += (activity.amount * pointsPerKmCycle);
          break;
        case typeSwim:
          totalEarned += (activity.amount * pointsPerLengthSwim);
          break;
        default:
          // Fallback for legacy or unknown types (assume Run / 5 logic if needed, or 0)
          // For now, let's treat unknown as 0 to be safe, or map legacy 'Run' if strictly 'Run' string wasn't used previously.
          if (activity.type == 'Run') {
            totalEarned += (activity.amount * pointsPerKmRun);
          }
      }
    }

    double totalConsumed = 0;
    for (var drink in drinks) {
      totalConsumed += drink.amount;
    }

    return totalEarned - totalConsumed;
  }

  /// Returns the balance for the current week (starting Monday).
  static double getWeeklyBalance(
    List<Activity> activities,
    List<Drink> drinks, {
    DateTime? now, // Dependency Injection for Time Travel
  }) {
    final effectiveNow = now ?? DateTime.now();
    // Monday = 1. Subtract (weekday - 1) days to get to Monday.
    final monday = effectiveNow.subtract(
      Duration(days: effectiveNow.weekday - 1),
    );
    final startOfWeek = DateTime(
      monday.year,
      monday.month,
      monday.day,
    ); // 00:00:00

    final weeklyActivities = activities
        .where(
          (a) =>
              a.timestamp.isAfter(startOfWeek) ||
              a.timestamp.isAtSameMomentAs(startOfWeek),
        )
        .toList();
    final weeklyDrinks = drinks
        .where(
          (Drink d) =>
              d.timestamp.isAfter(startOfWeek) ||
              d.timestamp.isAtSameMomentAs(startOfWeek),
        )
        .toList();

    return calculateBalance(weeklyActivities, weeklyDrinks);
  }
}
