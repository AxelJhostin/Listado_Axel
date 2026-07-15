import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/distributor.dart';
import '../models/needed_item.dart';
import '../models/product.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Future<Isar> get db async {
    if (_isar != null) return _isar!;
    _isar = await _open();
    return _isar!;
  }

  Future<Isar> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [DistributorSchema, ProductSchema, NeededItemSchema],
      directory: dir.path,
      inspector: true,
    );
  }

  Future<List<Distributor>> getAllDistributors() async {
    final isar = await db;
    return isar.distributors.where().sortByName().findAll();
  }

  Future<Id> saveDistributor(Distributor distributor) async {
    final isar = await db;
    return isar.writeTxn(() => isar.distributors.put(distributor));
  }

  Future<void> deleteDistributor(Id id) async {
    final isar = await db;
    await isar.writeTxn(() => isar.distributors.delete(id));
  }

  Future<List<Product>> getProducts({required bool checked}) async {
    final isar = await db;
    final query = isar.products.filter().isCheckedEqualTo(checked);
    final products = checked
        ? await query.sortByName().findAll()
        : await query
            .needsPurchaseEqualTo(true)
            .sortByName()
            .findAll();

    for (final product in products) {
      await product.distributors.load();
      await product.finalDistributor.load();
    }
    return products;
  }

  Future<List<Product>> getCatalogProductsNotOnList() async {
    final isar = await db;
    final products = await isar.products
        .filter()
        .isCheckedEqualTo(false)
        .needsPurchaseEqualTo(false)
        .sortByName()
        .findAll();

    for (final product in products) {
      await product.distributors.load();
    }
    return products;
  }

  Future<void> setNeedsPurchase(Product product, bool needsPurchase) async {
    final isar = await db;
    await isar.writeTxn(() async {
      product.needsPurchase = needsPurchase;
      await isar.products.put(product);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    final products = await isar.products.where().sortByName().findAll();

    for (final product in products) {
      await product.distributors.load();
      await product.finalDistributor.load();
    }
    return products;
  }

  Future<Id> saveProduct(Product product, {List<Id>? distributorIds}) async {
    final isar = await db;
    return isar.writeTxn(() async {
      final id = await isar.products.put(product);

      if (distributorIds != null) {
        product.distributors.clear();
        for (final distId in distributorIds) {
          final dist = await isar.distributors.get(distId);
          if (dist != null) product.distributors.add(dist);
        }
        await product.distributors.save();
      }

      return id;
    });
  }

  Future<void> markAsPurchased({
    required Product product,
    required int quantity,
    required double price,
    required Id distributorId,
  }) async {
    final isar = await db;
    await isar.writeTxn(() async {
      product.isChecked = true;
      product.needsPurchase = false;
      product.purchasedQuantity = quantity;
      product.purchasePrice = price;

      final distributor = await isar.distributors.get(distributorId);
      if (distributor != null) {
        product.finalDistributor.value = distributor;
        await product.finalDistributor.save();
      }

      await isar.products.put(product);
    });
  }

  Future<void> resetPurchase(Product product) async {
    final isar = await db;
    await isar.writeTxn(() async {
      product.isChecked = false;
      product.needsPurchase = true;
      product.purchasedQuantity = null;
      product.purchasePrice = null;
      product.finalDistributor.value = null;
      await product.finalDistributor.save();
      await isar.products.put(product);
    });
  }

  Future<void> deleteProduct(Id id) async {
    final isar = await db;
    await isar.writeTxn(() => isar.products.delete(id));
  }

  Future<List<NeededItem>> getActiveNeededItems() async {
    final isar = await db;
    return isar.neededItems
        .filter()
        .isDoneEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<Id> saveNeededItem(NeededItem item) async {
    final isar = await db;
    return isar.writeTxn(() => isar.neededItems.put(item));
  }

  Future<void> markNeededItemDone(NeededItem item) async {
    final isar = await db;
    await isar.writeTxn(() async {
      item.isDone = true;
      await isar.neededItems.put(item);
    });
  }

  Future<void> deleteNeededItem(Id id) async {
    final isar = await db;
    await isar.writeTxn(() => isar.neededItems.delete(id));
  }
}
