import 'package:intl/intl.dart';

import '../../../models/product.dart';

class PurchaseSummary {
  PurchaseSummary._();

  static int totalUnits(List<Product> products) => products.fold<int>(
        0,
        (sum, p) => sum + (p.purchasedQuantity ?? 0),
      );

  static double totalSpent(List<Product> products) => products.fold<double>(
        0,
        (sum, p) {
          final qty = p.purchasedQuantity ?? 0;
          final price = p.purchasePrice ?? 0;
          return sum + (qty * price);
        },
      );

  static double subtotal(Product product) {
    final qty = product.purchasedQuantity ?? 0;
    final price = product.purchasePrice ?? 0;
    return qty * price;
  }
}

class PurchaseReportBuilder {
  PurchaseReportBuilder._();

  static String build(List<Product> purchasedProducts) {
    final date = DateFormat('d MMMM yyyy', 'es').format(DateTime.now());
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final totalUnits = PurchaseSummary.totalUnits(purchasedProducts);
    final totalSpent = PurchaseSummary.totalSpent(purchasedProducts);

    final buffer = StringBuffer()
      ..writeln('🛒 *Resumen de Compra - $date*')
      ..writeln(
        '💰 *Total Invertido:* ${currency.format(totalSpent)} '
        '($totalUnits unidades)',
      )
      ..writeln('----------------------------------');

    for (final product in purchasedProducts) {
      final qty = product.purchasedQuantity ?? 0;
      final price = product.purchasePrice ?? 0;
      final subtotal = PurchaseSummary.subtotal(product);
      final distributor = product.finalDistributor.value?.name ?? 'Sin registrar';

      buffer
        ..writeln('* ${product.name}')
        ..writeln('  - Cantidad: $qty unidades')
        ..writeln('  - Precio unitario: ${currency.format(price)}')
        ..writeln('  - Subtotal: ${currency.format(subtotal)}')
        ..writeln('  - Proveedor: $distributor')
        ..writeln();
    }

    return buffer.toString().trimRight();
  }
}
