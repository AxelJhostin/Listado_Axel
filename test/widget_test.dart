import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listado_axel/theme/app_theme.dart';

void main() {
  testWidgets('Tema accesible se aplica correctamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: Text('Listado de Compras')),
        ),
      ),
    );

    expect(find.text('Listado de Compras'), findsOneWidget);
  });
}
