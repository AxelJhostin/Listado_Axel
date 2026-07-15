import 'package:flutter_test/flutter_test.dart';
import 'package:listado_axel/models/product.dart';

void main() {
  group('Reglas de estado needsPurchase', () {
    bool isInToBuyList(Product product) =>
        product.needsPurchase && !product.isChecked;

    bool isCatalogOnly(Product product) =>
        !product.needsPurchase && !product.isChecked;

    bool isPurchased(Product product) =>
        product.isChecked && !product.needsPurchase;

    test('Por Comprar solo incluye needsPurchase=true e isChecked=false', () {
      final onList = Product()
        ..name = 'Arroz'
        ..needsPurchase = true
        ..isChecked = false;

      final catalogOnly = Product()
        ..name = 'Aceite'
        ..needsPurchase = false
        ..isChecked = false;

      expect(isInToBuyList(onList), isTrue);
      expect(isInToBuyList(catalogOnly), isFalse);
      expect(isCatalogOnly(catalogOnly), isTrue);
    });

    test('markAsPurchased limpia needsPurchase y marca isChecked', () {
      final product = Product()
        ..name = 'Arroz'
        ..needsPurchase = true
        ..isChecked = false;

      product.isChecked = true;
      product.needsPurchase = false;
      product.purchasedQuantity = 5;
      product.purchasePrice = 10;

      expect(isPurchased(product), isTrue);
      expect(isInToBuyList(product), isFalse);
    });

    test('resetPurchase restaura needsPurchase y limpia compra', () {
      final product = Product()
        ..name = 'Arroz'
        ..needsPurchase = false
        ..isChecked = true
        ..purchasedQuantity = 5
        ..purchasePrice = 10;

      product.isChecked = false;
      product.needsPurchase = true;
      product.purchasedQuantity = null;
      product.purchasePrice = null;

      expect(isInToBuyList(product), isTrue);
      expect(isPurchased(product), isFalse);
    });
  });
}
