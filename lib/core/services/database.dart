import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
}

class Drinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Activities, Drinks, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(settings);
      }
    },
  );

  // Activities CRUD
  Future<List<Activity>> getAllActivities() => select(activities).get();
  Stream<List<Activity>> watchActivities() => select(activities).watch();

  Future<int> saveActivity(Insertable<Activity> activity) {
    return into(activities).insert(activity, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteActivity(int id) {
    return (delete(activities)..where((t) => t.id.equals(id))).go();
  }

  // Drinks CRUD
  Future<List<Drink>> getAllDrinks() => select(drinks).get();
  Stream<List<Drink>> watchDrinks() => select(drinks).watch();

  Future<int> saveDrink(Insertable<Drink> drink) {
    return into(drinks).insert(drink, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteDrink(int id) {
    return (delete(drinks)..where((t) => t.id.equals(id))).go();
  }

  // Settings CRUD
  Future<String?> getSetting(String key) async {
    final query = select(settings)..where((s) => s.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future<void> saveSetting(String key, String value) {
    return into(settings).insert(
      SettingsCompanion(key: Value(key), value: Value(value)),
      mode: InsertMode.insertOrReplace,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
