import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../models/drink.dart';
import '../services/isar_service.dart';
import 'pint_calculator.dart';

class AppState extends ChangeNotifier {
  final IsarService _isarService;

  double _balance = 0.0;
  double get balance => _balance;

  List<Activity> _activities = [];
  List<Drink> _drinks = [];

  List<dynamic> get logs {
    final combined = [..._activities, ..._drinks];
    combined.sort(
      (a, b) => (b as dynamic).timestamp.compareTo((a as dynamic).timestamp),
    );
    return combined;
  }

  AppState(this._isarService) {
    _init();
  }

  void _init() {
    _isarService.watchActivities().listen((activities) {
      _activities = activities;
      _calculateBalance();
    });

    _isarService.watchDrinks().listen((drinks) {
      _drinks = drinks;
      _calculateBalance();
    });
  }

  Future<void> addActivity(double km) async {
    final activity = Activity.run(km);
    await _isarService.saveActivity(activity);
    // UI will update via the stream listener
  }

  Future<void> addDrink(double pints) async {
    final drink = Drink.pint(pints);
    await _isarService.saveDrink(drink);
    // UI will update via the stream listener
  }

  void _calculateBalance() {
    _balance = PintCalculator.calculateBalance(_activities, _drinks);
    notifyListeners();
  }
}
