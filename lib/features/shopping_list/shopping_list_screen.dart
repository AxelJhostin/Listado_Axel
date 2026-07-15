import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/isar_service.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import 'utils/purchase_report_builder.dart';
import 'widgets/daily_summary_banner.dart';
import 'widgets/product_card.dart';
import 'widgets/purchase_check_dialog.dart';
import '../../widgets/product_search_bar.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<Product> _toBuy = [];
  List<Product> _purchased = [];
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  void _onTabChanged() => setState(() {});

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<Product> _filter(List<Product> products) {
    return filterProductsByName(products, _searchQuery);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final toBuy = await IsarService.instance.getProducts(checked: false);
    final purchased = await IsarService.instance.getProducts(checked: true);
    if (mounted) {
      setState(() {
        _toBuy = toBuy;
        _purchased = purchased;
        _loading = false;
      });
    }
  }

  Future<void> _onCheck(Product product) async {
    final result = await showDialog<PurchaseResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PurchaseCheckDialog(productName: product.name),
    );

    if (result != null) {
      await IsarService.instance.markAsPurchased(
        product: product,
        quantity: result.quantity,
        price: result.price,
        distributorId: result.distributorId,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} marcado como comprado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onUndo(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deshacer compra?'),
        content: Text(
          '${product.name} volverá a la lista "Por Comprar" '
          'y se borrarán los datos de la compra.',
          style: const TextStyle(fontSize: AppTheme.fontBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deshacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await IsarService.instance.resetPurchase(product);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} devuelto a Por Comprar'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    if (_purchased.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay compras para compartir'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final report = PurchaseReportBuilder.build(_purchased);
    await Share.share(report, subject: 'Resumen de Compra - Listado Axel');
  }

  bool get _isPurchasedTab => _tabController.index == 1;

  @override
  Widget build(BuildContext context) {
    final filteredToBuy = _filter(_toBuy);
    final filteredPurchased = _filter(_purchased);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          if (_isPurchasedTab)
            Semantics(
              button: true,
              label: 'Compartir resumen del día',
              child: IconButton(
                onPressed: _purchased.isEmpty ? null : _shareReport,
                icon: const Icon(Icons.share, size: 28),
                tooltip: 'Compartir resumen',
                constraints: const BoxConstraints(
                  minWidth: AppTheme.minAccessibleTouch,
                  minHeight: AppTheme.minAccessibleTouch,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 4,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(text: 'Por Comprar (${filteredToBuy.length})'),
            Tab(text: 'Ya Comprados (${filteredPurchased.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ProductSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: _clearSearch,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(
                        filteredToBuy,
                        allProducts: _toBuy,
                        showCheck: true,
                      ),
                      _buildPurchasedList(
                        filteredPurchased,
                        allPurchased: _purchased,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    List<Product> products, {
    required List<Product> allProducts,
    required bool showCheck,
  }) {
    if (allProducts.isEmpty) {
      return _emptyState(
        'No hay productos pendientes.\nAgrega productos en el Catálogo.',
      );
    }

    if (products.isEmpty) {
      return _emptyState('No se encontraron productos con esa búsqueda.');
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          showCheckButton: showCheck,
          onCheck: () => _onCheck(products[i]),
        ),
      ),
    );
  }

  Widget _buildPurchasedList(
    List<Product> products, {
    required List<Product> allPurchased,
  }) {
    if (allPurchased.isEmpty) {
      return _emptyState('Aún no has comprado nada hoy.');
    }

    if (products.isEmpty) {
      return Column(
        children: [
          DailySummaryBanner(purchasedProducts: allPurchased),
          Expanded(
            child: _emptyState('No se encontraron productos con esa búsqueda.'),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: products.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return DailySummaryBanner(purchasedProducts: allPurchased);
          }
          final product = products[i - 1];
          return ProductCard(
            product: product,
            showCheckButton: false,
            showUndoButton: true,
            onUndo: () => _onUndo(product),
          );
        },
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
