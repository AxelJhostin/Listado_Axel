import 'package:isar/isar.dart';

part 'distributor.g.dart';

@collection
class Distributor {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  String? locationNotes;
  String? phoneNumber;
}
