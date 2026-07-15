import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:listado_axel/features/shopping_list/utils/purchase_report_builder.dart';
import 'package:listado_axel/models/distributor.dart';
import 'package:listado_axel/models/product.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  test('PurchaseReportBuilder genera reporte con totales y detalle', () {
    final distributor = Distributor()..name = 'Proveedor Test';

    final product = Product()
      ..name = 'Arroz 1kg'
      ..isChecked = true
      ..purchasedQuantity = 10
      ..purchasePrice = 8.5;
    product.finalDistributor.value = distributor;

    final report = PurchaseReportBuilder.build([product]);

    expect(report, contains('🛒 *Resumen de Compra'));
    expect(report, contains('💰 *Total Invertido:*'));
    expect(report, contains('(10 unidades)'));
    expect(report, contains('* Arroz 1kg'));
    expect(report, contains('- Cantidad: 10 unidades'));
    expect(report, contains('- Proveedor: Proveedor Test'));
    expect(report, contains(r'$85.00'));
  });
}
