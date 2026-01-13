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

  Future<void> addActivity([double units = 5.0]) async {
    final activity = Activity.run(units);
    await _isarService.saveActivity(activity);
  }

  Future<void> addDrink([double units = 1.0]) async {
    final drink = Drink.pint(units);
    await _isarService.saveDrink(drink);
  }

  Future<void> updateActivity(Activity activity, double newAmount) async {
    activity.amount = newAmount;
    await _isarService.saveActivity(activity);
  }

  Future<void> updateDrink(Drink drink, double newAmount) async {
    drink.amount = newAmount;
    await _isarService.saveDrink(drink);
  }

  Future<void> deleteActivity(int id) async {
    await _isarService.deleteActivity(id);
  }

  Future<void> deleteDrink(int id) async {
    await _isarService.deleteDrink(id);
  }

  void _calculateBalance() {
    _balance = PintCalculator.calculateBalance(_activities, _drinks);
    notifyListeners();
  }
}
