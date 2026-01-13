import 'package:isar/isar.dart';

part 'drink.g.dart';

@collection
class Drink {
  Id id = Isar.autoIncrement;

  late double amount; // e.g., 1.0 for a Pint

  late DateTime timestamp;

  Drink();

  Drink.pint(this.amount) {
    timestamp = DateTime.now();
  }
}
