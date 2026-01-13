import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/activity.dart';
import '../models/drink.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ActivitySchema, DrinkSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveActivity(Activity activity) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.activities.putSync(activity));
  }

  Future<void> saveDrink(Drink drink) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.drinks.putSync(drink));
  }

  Future<List<Activity>> getAllActivities() async {
    final isar = await db;
    return await isar.activities.where().findAll();
  }

  Future<List<Drink>> getAllDrinks() async {
    final isar = await db;
    return await isar.drinks.where().findAll();
  }

  Stream<List<Activity>> watchActivities() async* {
    final isar = await db;
    yield* isar.activities.where().watch(fireImmediately: true);
  }

  Stream<List<Drink>> watchDrinks() async* {
    final isar = await db;
    yield* isar.drinks.where().watch(fireImmediately: true);
  }
}
