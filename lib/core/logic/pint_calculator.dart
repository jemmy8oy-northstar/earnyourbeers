import '../services/database.dart';

class PintCalculator {
  static const double kmPerPint = 5.0; // 5km = 1 Pint

  static double calculateBalance(
    List<Activity> activities,
    List<Drink> drinks,
  ) {
    double totalEarned = 0;
    for (var activity in activities) {
      if (activity.type == 'Run') {
        totalEarned += (activity.amount / kmPerPint);
      }
    }

    double totalConsumed = 0;
    for (var drink in drinks) {
      totalConsumed += drink.amount;
    }

    return totalEarned - totalConsumed;
  }
}
