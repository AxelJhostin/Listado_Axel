import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'database/isar_service.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/distributors/distributors_screen.dart';
import 'features/shopping_list/shopping_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await IsarService.instance.db;
  runApp(const ListadoAxelApp());
}

class ListadoAxelApp extends StatelessWidget {
  const ListadoAxelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listado de Compras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    ShoppingListScreen(),
    CatalogScreen(),
    DistributorsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.cardBorder)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Compras',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Catálogo',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Distribuidores',
            ),
          ],
        ),
      ),
    );
  }
}
