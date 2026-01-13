import 'package:isar/isar.dart';

part 'activity.g.dart';

@collection
class Activity {
  Id id = Isar.autoIncrement;

  late String type; // e.g., 'Run'

  late double amount; // e.g., 5.0 for 5km

  late DateTime timestamp;

  Activity();

  Activity.run(this.amount) {
    type = 'Run';
    timestamp = DateTime.now();
  }
}
