import 'package:isar/isar.dart';

import 'distributor.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  int? currentStock;
  String? description;
  String? localImagePath;

  @Index()
  bool isChecked = false;

  int? purchasedQuantity;
  double? purchasePrice;

  final distributors = IsarLinks<Distributor>();
  final finalDistributor = IsarLink<Distributor>();
}
