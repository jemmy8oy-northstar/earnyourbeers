import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import '../services/database.dart';
import 'pint_calculator.dart';

class AppState extends ChangeNotifier {
  final AppDatabase _database;

  double _balance = 0.0;
  double get balance => _balance;

  // Debug: Time Travel
  Duration _debugTimeOffset = Duration.zero;
  DateTime get simulatedNow => DateTime.now().add(_debugTimeOffset);

  void simulateAdvanceWeek() {
    _debugTimeOffset += const Duration(days: 7);
    _calculateBalance(); // Recalculate with new "now"
    notifyListeners();
  }

  List<Activity> _activities = [];
  List<Drink> _drinks = [];

  List<Activity> get activities => _activities;
  List<Drink> get drinks => _drinks;

  List<dynamic> get logs {
    final combined = [..._activities, ..._drinks];
    combined.sort(
      (a, b) => (b as dynamic).timestamp.compareTo((a as dynamic).timestamp),
    );
    return combined;
  }

  int get historyPageCount {
    if (_activities.isEmpty && _drinks.isEmpty) return 1;

    final oldestItem = logs.last;
    final DateTime oldestDate = (oldestItem as dynamic).timestamp;

    final currentMon = simulatedNow.subtract(
      Duration(days: simulatedNow.weekday - 1),
    );
    final startOfCurrentWeek = DateTime(
      currentMon.year,
      currentMon.month,
      currentMon.day,
    );

    final oldMon = oldestDate.subtract(Duration(days: oldestDate.weekday - 1));
    final startOfOldWeek = DateTime(oldMon.year, oldMon.month, oldMon.day);

    final weekDiff = startOfCurrentWeek.difference(startOfOldWeek).inDays ~/ 7;

    return weekDiff + 1; // +1 for the current week itself
  }

  AppState(this._database) {
    _init();
  }

  void _init() {
    _database.watchActivities().listen((activities) {
      _activities = activities;
      _calculateBalance();
    });

    _database.watchDrinks().listen((drinks) {
      _drinks = drinks;
      _calculateBalance();
    });
  }

  Future<void> addActivity(String type, double amount) async {
    await _database.saveActivity(
      ActivitiesCompanion.insert(
        type: type,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> addDrink([double units = 1.0]) async {
    await _database.saveDrink(
      DrinksCompanion.insert(amount: units, timestamp: DateTime.now()),
    );
  }

  Future<void> updateActivity(Activity activity, double newAmount) async {
    await _database.saveActivity(
      activity.toCompanion(false).copyWith(amount: Value(newAmount)),
    );
  }

  Future<void> updateDrink(Drink drink, double newAmount) async {
    await _database.saveDrink(
      drink.toCompanion(false).copyWith(amount: Value(newAmount)),
    );
  }

  Future<void> deleteActivity(int id) async {
    await _database.deleteActivity(id);
  }

  Future<void> deleteDrink(int id) async {
    await _database.deleteDrink(id);
  }

  void _calculateBalance() {
    _balance = PintCalculator.calculateBalance(_activities, _drinks);
    notifyListeners();
  }
}
