import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:drift/drift.dart' show Value;
import '../services/database.dart';
import 'pint_calculator.dart';

class LeagueTier {
  final String name;
  final String division;
  final String vibe;
  final Color color;

  const LeagueTier({
    required this.name,
    required this.division,
    required this.vibe,
    required this.color,
  });
}

const List<LeagueTier> leagueTiers = [
  // Division I: The Apprenticeship (Quartz)
  LeagueTier(
    name: 'Noob',
    division: 'Apprenticeship',
    vibe: 'Entry level.',
    color: Color(0xFF9E9E9E),
  ),
  LeagueTier(
    name: 'Novice',
    division: 'Apprenticeship',
    vibe: 'Breaking the seal.',
    color: Color(0xFF9E9E9E),
  ),
  LeagueTier(
    name: 'Weekender',
    division: 'Apprenticeship',
    vibe: 'Finding rhythm.',
    color: Color(0xFF9E9E9E),
  ),
  LeagueTier(
    name: 'Rookie',
    division: 'Apprenticeship',
    vibe: 'Early consistency.',
    color: Color(0xFF9E9E9E),
  ),
  LeagueTier(
    name: 'Apprentice',
    division: 'Apprenticeship',
    vibe: 'Learning the architecture.',
    color: Color(0xFF9E9E9E),
  ),
  // Division II: The Practice (Emerald)
  LeagueTier(
    name: 'Regular',
    division: 'Practice',
    vibe: 'Familiar face.',
    color: Color(0xFF2ECC71),
  ),
  LeagueTier(
    name: 'Grinder',
    division: 'Practice',
    vibe: 'Pure volume.',
    color: Color(0xFF2ECC71),
  ),
  LeagueTier(
    name: 'Athlete',
    division: 'Practice',
    vibe: 'Performance focus.',
    color: Color(0xFF2ECC71),
  ),
  LeagueTier(
    name: 'Competitor',
    division: 'Practice',
    vibe: 'Pushing limits.',
    color: Color(0xFF2ECC71),
  ),
  LeagueTier(
    name: 'Professional',
    division: 'Practice',
    vibe: 'Mastery of foundational cycle.',
    color: Color(0xFF2ECC71),
  ),
  // Division III: The Mastery (Sapphire)
  LeagueTier(
    name: 'Specialist',
    division: 'Mastery',
    vibe: 'Refined focus.',
    color: Color(0xFF3498DB),
  ),
  LeagueTier(
    name: 'Relentless',
    division: 'Mastery',
    vibe: 'Unstoppable consistency.',
    color: Color(0xFF3498DB),
  ),
  LeagueTier(
    name: 'Veteran',
    division: 'Mastery',
    vibe: 'Proven performance.',
    color: Color(0xFF3498DB),
  ),
  LeagueTier(
    name: 'Expert',
    division: 'Mastery',
    vibe: 'Deep intuition.',
    color: Color(0xFF3498DB),
  ),
  LeagueTier(
    name: 'Champion',
    division: 'Mastery',
    vibe: 'Sustained peak.',
    color: Color(0xFF3498DB),
  ),
  // Division IV: The Legacy (Amethyst -> Obsidian)
  LeagueTier(
    name: 'Master',
    division: 'Legacy',
    vibe: 'Total command.',
    color: Color(0xFF9B59B6),
  ),
  LeagueTier(
    name: 'Grandmaster',
    division: 'Legacy',
    vibe: 'Technical insight.',
    color: Color(0xFF9B59B6),
  ),
  LeagueTier(
    name: 'Elite',
    division: 'Legacy',
    vibe: 'Top 1%.',
    color: Color(0xFF9B59B6),
  ),
  LeagueTier(
    name: 'Titan',
    division: 'Legacy',
    vibe: 'Monumental presence.',
    color: Color(0xFF8E44AD),
  ),
  LeagueTier(
    name: 'Legend',
    division: 'Legacy',
    vibe: 'Eternal residency.',
    color: Color(0xFF2C3E50),
  ),
];

class SettlementReport {
  final double weeklyNet;
  final int levelChange;
  final double previousTally;
  final double newTally;
  final LeagueTier oldTier;
  final LeagueTier newTier;

  SettlementReport({
    required this.weeklyNet,
    required this.levelChange,
    required this.previousTally,
    required this.newTally,
    required this.oldTier,
    required this.newTier,
  });
}

class AppState extends ChangeNotifier {
  final AppDatabase _database;

  double _balance = 0.0;
  double get balance => _balance;

  // Debug: Time Travel
  Duration _debugTimeOffset = Duration.zero;
  DateTime get simulatedNow =>
      kDebugMode ? DateTime.now().add(_debugTimeOffset) : DateTime.now();

  void simulateAdvanceWeek() {
    if (!kDebugMode) return;
    _debugTimeOffset += const Duration(days: 7);
    _checkSettlement(); // Trigger settlement with new date
    _calculateBalance();
    notifyListeners();
  }

  Future<void> resetTimeTravel() async {
    if (!kDebugMode) return;
    _debugTimeOffset = Duration.zero;

    // Clear future logs from DB
    final threshold = DateTime.now();
    await _database.clearFutureActivities(threshold);
    await _database.clearFutureDrinks(threshold);

    // Reset League Status to force re-evaluation from current date
    _currentLevel = 0;
    _leagueTally = 0.0;
    _lastSettledDate = null;

    await _database.saveSetting('current_level', '0');
    await _database.saveSetting('league_tally', '0.0');
    await _database.saveSetting('last_settled_date', '');

    _checkSettlement();
    _calculateBalance();
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

  bool _isOnboarded = false;
  bool get isOnboarded => _isOnboarded;

  // Rebrand State
  String _viceEmoji = '🍕';
  ThemeMode _themeMode = ThemeMode.system;

  String get viceEmoji => _viceEmoji;
  ThemeMode get themeMode => _themeMode;

  // League State
  int _currentLevel = 0;
  double _leagueTally = 0.0;
  DateTime? _lastSettledDate;

  int get currentLevel => _currentLevel;
  double get leagueTally => _leagueTally;

  // Exponential Difficulty Formula: 10.0 * (0.7943 ^ Level)
  // This ensures Tier 0: 5km = 25pts (1km = 5.0)
  // This ensures Tier 20: 500km = 25pts (1km = 0.05)
  double get currentDifficulty => 10.0 * (math.pow(0.794328, _currentLevel));
  // Progress from -25 to +25 mapped to 0 to 1
  double get tallyProgress => ((_leagueTally + 25) / 50).clamp(0.0, 1.0);
  LeagueTier get currentTier =>
      leagueTiers[_currentLevel.clamp(0, leagueTiers.length - 1)];

  late Future<void> initializationDone;

  final _settlementController = StreamController<SettlementReport>.broadcast();
  Stream<SettlementReport> get settlementStream => _settlementController.stream;

  AppState(this._database) {
    initializationDone = _init();
  }

  Future<void> _init() async {
    // Load Activities
    _database.watchActivities().listen((activities) {
      _activities = activities;
      _calculateBalance();
    });

    // Load Drinks
    _database.watchDrinks().listen((drinks) {
      _drinks = drinks;
      _calculateBalance();
    });

    // Load Settings
    final savedEmoji = await _database.getSetting('vice_emoji');
    if (savedEmoji != null) _viceEmoji = savedEmoji;

    final savedTheme = await _database.getSetting('theme_mode');
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    final savedLevel = await _database.getSetting('current_level');
    if (savedLevel != null) _currentLevel = int.parse(savedLevel);

    final savedTally = await _database.getSetting('league_tally');
    if (savedTally != null) _leagueTally = double.parse(savedTally);

    final savedSettled = await _database.getSetting('last_settled_date');
    if (savedSettled != null && savedSettled.isNotEmpty) {
      _lastSettledDate = DateTime.parse(savedSettled);
    }

    final savedOnboarded = await _database.getSetting('onboarding_completed');
    _isOnboarded = savedOnboarded == 'true';

    // Initial settlement check
    _checkSettlement();

    notifyListeners();
  }

  void _checkSettlement() {
    final now = simulatedNow;
    if (_lastSettledDate == null) {
      _lastSettledDate = now;
      _database.saveSetting('last_settled_date', now.toIso8601String());
      return;
    }

    // Start of this week
    final currentMon = now.subtract(Duration(days: now.weekday - 1));
    final startOfThisWeek = DateTime(
      currentMon.year,
      currentMon.month,
      currentMon.day,
    );

    // Start of last settled week
    final settledMon = _lastSettledDate!.subtract(
      Duration(days: _lastSettledDate!.weekday - 1),
    );
    final startOfSettledWeek = DateTime(
      settledMon.year,
      settledMon.month,
      settledMon.day,
    );

    if (startOfThisWeek.isAfter(startOfSettledWeek)) {
      _processWeeklySettlement(startOfSettledWeek, startOfThisWeek);
    }
  }

  @override
  void dispose() {
    _settlementController.close();
    super.dispose();
  }

  Future<void> _processWeeklySettlement(DateTime from, DateTime to) async {
    // 1. Calculate balance for the interval (usually just the previous week)
    // For simplicity, we calculate the balance of ALL items between from and to
    final intervalLogs = logs.where((log) {
      final ts = (log as dynamic).timestamp as DateTime;
      return ts.isAtSameMomentAs(from) || (ts.isAfter(from) && ts.isBefore(to));
    }).toList();

    final activities = intervalLogs.whereType<Activity>().toList();
    final drinks = intervalLogs.whereType<Drink>().toList();
    final weeklyNet = PintCalculator.calculateBalance(
      activities,
      drinks,
      difficultyMultiplier: currentDifficulty,
    );

    final double previousTally = _leagueTally;
    final int previousLevel = _currentLevel;

    // 2. Update Tally
    _leagueTally += weeklyNet;

    // 3. Process Promotions/Demotions
    int levelChange = 0;
    if (_leagueTally >= 50) {
      levelChange = 2;
      _leagueTally -= 50;
    } else if (_leagueTally >= 25) {
      levelChange = 1;
      _leagueTally -= 25;
    } else if (_leagueTally <= -25) {
      levelChange = -1;
      _leagueTally += 25;
    }

    if (levelChange != 0) {
      _currentLevel = (_currentLevel + levelChange).clamp(
        0,
        leagueTiers.length - 1,
      );
      await _database.saveSetting('current_level', _currentLevel.toString());
    }

    _lastSettledDate = to;
    await _database.saveSetting('league_tally', _leagueTally.toString());
    await _database.saveSetting('last_settled_date', to.toIso8601String());

    // Emit Report
    _settlementController.add(
      SettlementReport(
        weeklyNet: weeklyNet,
        levelChange: levelChange,
        previousTally: previousTally,
        newTally: _leagueTally,
        oldTier: leagueTiers[previousLevel],
        newTier: leagueTiers[_currentLevel],
      ),
    );

    notifyListeners();
  }

  Future<void> updateVice(String emoji) async {
    _viceEmoji = emoji;
    notifyListeners();
    await _database.saveSetting('vice_emoji', emoji);
  }

  Future<void> completeOnboarding({
    required double runVolume,
    required String viceEmoji,
  }) async {
    // Seeding logic based on onboarding_brainstorm.md
    int seededLevel = 0;
    if (runVolume >= 100) {
      seededLevel = 20;
    } else if (runVolume >= 60) {
      seededLevel = 15;
    } else if (runVolume >= 40) {
      seededLevel = 10;
    } else if (runVolume >= 20) {
      seededLevel = 5;
    } else {
      seededLevel = 0;
    }

    _currentLevel = seededLevel;
    _viceEmoji = viceEmoji;
    _isOnboarded = true;
    _lastSettledDate = simulatedNow;

    await _database.saveSetting('current_level', _currentLevel.toString());
    await _database.saveSetting('vice_emoji', _viceEmoji);
    await _database.saveSetting('onboarding_completed', 'true');
    await _database.saveSetting(
      'last_settled_date',
      _lastSettledDate!.toIso8601String(),
    );

    _calculateBalance();
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _database.clearAllData();
    _isOnboarded = false;
    _currentLevel = 0;
    _activities = [];
    _drinks = [];
    _leagueTally = 0;
    _viceEmoji = '🍕';
    _calculateBalance();
    notifyListeners();
  }

  Future<void> updateTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _database.saveSetting('theme_mode', mode.toString());
  }

  Future<void> addActivity(String type, double amount) async {
    final now = simulatedNow;
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Check if the ABSOLUTE most recent entry is the same activity type
    final lastEntry = logs.isEmpty ? null : logs.first;

    if (lastEntry is Activity &&
        lastEntry.type == type &&
        lastEntry.timestamp.isAfter(oneHourAgo)) {
      await updateActivity(lastEntry, lastEntry.amount + amount);
    } else {
      await _database.saveActivity(
        ActivitiesCompanion.insert(type: type, amount: amount, timestamp: now),
      );
    }
  }

  Future<void> addDrink([double units = 1.0]) async {
    final now = simulatedNow;
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Check if the ABSOLUTE most recent entry is a drink
    final lastEntry = logs.isEmpty ? null : logs.first;

    if (lastEntry is Drink && lastEntry.timestamp.isAfter(oneHourAgo)) {
      await updateDrink(lastEntry, lastEntry.amount + units);
    } else {
      await _database.saveDrink(
        DrinksCompanion.insert(amount: units, timestamp: now),
      );
    }
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

  Future<void> debugSetLevel(int level) async {
    _currentLevel = level.clamp(0, 20);
    await _database.saveSetting('current_level', _currentLevel.toString());
    _calculateBalance();
    notifyListeners();
  }

  void _calculateBalance() {
    _balance = PintCalculator.calculateBalance(
      _activities,
      _drinks,
      difficultyMultiplier: currentDifficulty,
    );
    notifyListeners();
  }
}
