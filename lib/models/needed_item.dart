import 'package:isar/isar.dart';

part 'needed_item.g.dart';

@collection
class NeededItem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  int? quantity;
  String? notes;
  bool isDone = false;
  int? linkedProductId;
}
