import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../models/drink.dart';

class AppState extends ChangeNotifier {
  double _balance = 0.0;
  double get balance => _balance;

  final List<Activity> _activities = [];
  final List<Drink> _drinks = [];

  void addActivity(Activity activity) {
    _activities.add(activity);
    _calculateBalance();
    notifyListeners();
  }

  void addDrink(Drink drink) {
    _drinks.add(drink);
    _calculateBalance();
    notifyListeners();
  }

  void _calculateBalance() {
    double totalEarned = 0;
    for (var a in _activities) {
      if (a.type == 'Run') {
        totalEarned += (a.amount / 3.0); // MVP Rate: 3km = 1 Pint
      }
    }

    double totalConsumed = 0;
    for (var d in _drinks) {
      totalConsumed += d.amount;
    }

    _balance = totalEarned - totalConsumed;
  }
}
