import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/isar_service.dart';
import '../../models/needed_item.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import 'utils/purchase_report_builder.dart';
import 'widgets/add_product_picker_sheet.dart';
import 'widgets/daily_summary_banner.dart';
import 'widgets/needed_item_card.dart';
import 'widgets/product_card.dart';
import 'widgets/purchase_check_dialog.dart';
import 'widgets/quick_needed_item_dialog.dart';
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
  List<NeededItem> _neededItems = [];
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

  List<NeededItem> _filterNeededItems(List<NeededItem> items) {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items
        .where((item) => item.name.toLowerCase().contains(normalized))
        .toList();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final toBuy = await IsarService.instance.getProducts(checked: false);
    final neededItems = await IsarService.instance.getActiveNeededItems();
    final purchased = await IsarService.instance.getProducts(checked: true);
    if (mounted) {
      setState(() {
        _toBuy = toBuy;
        _neededItems = neededItems;
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

  Future<void> _onRemoveFromList(Product product) async {
    await IsarService.instance.setNeedsPurchase(product, false);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} quitado de la lista'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openQuickNeededItemDialog() async {
    final item = await showDialog<NeededItem>(
      context: context,
      builder: (_) => const QuickNeededItemDialog(),
    );

    if (item != null) {
      await IsarService.instance.saveNeededItem(item);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} agregado a la lista'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openAddOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Del catálogo'),
              subtitle: const Text('Producto que ya tienes registrado'),
              onTap: () => Navigator.pop(ctx, 'catalog'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Faltante rápido'),
              subtitle: const Text('Anotar algo que falta sin registrarlo'),
              onTap: () => Navigator.pop(ctx, 'quick'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || choice == null) return;
    if (choice == 'catalog') {
      await _openAddProductPicker();
    } else {
      await _openQuickNeededItemDialog();
    }
  }

  Future<void> _onNeededItemCheck(NeededItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Marcar como conseguido?'),
        content: Text(
          '${item.name} se quitará de la lista de faltantes.',
          style: const TextStyle(fontSize: AppTheme.fontBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Conseguido'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await IsarService.instance.markNeededItemDone(item);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} marcado como conseguido'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onDeleteNeededItem(NeededItem item) async {
    await IsarService.instance.deleteNeededItem(item.id);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} eliminado de la lista'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openAddProductPicker() async {
    final added = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddProductPickerSheet(),
    );

    if (added != null) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${added.name} agregado a la lista'),
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
  bool get _isToBuyTab => _tabController.index == 0;

  @override
  Widget build(BuildContext context) {
    final filteredToBuy = _filter(_toBuy);
    final filteredNeeded = _filterNeededItems(_neededItems);
    final filteredPurchased = _filter(_purchased);
    final toBuyCount = filteredToBuy.length + filteredNeeded.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          if (_isToBuyTab) ...[
            IconButton(
              onPressed: _openQuickNeededItemDialog,
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'Faltante rápido',
            ),
            IconButton(
              onPressed: _openAddProductPicker,
              icon: const Icon(Icons.playlist_add_rounded),
              tooltip: 'Agregar producto',
            ),
          ],
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
          tabs: [
            Tab(text: 'Por Comprar ($toBuyCount)'),
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
                        filteredNeeded,
                        allProducts: _toBuy,
                        allNeededItems: _neededItems,
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
      floatingActionButton: _isToBuyTab
          ? FloatingActionButton.extended(
              onPressed: _openAddOptions,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar'),
            )
          : null,
    );
  }

  Widget _buildList(
    List<Product> products,
    List<NeededItem> neededItems, {
    required List<Product> allProducts,
    required List<NeededItem> allNeededItems,
  }) {
    final isEmpty = allProducts.isEmpty && allNeededItems.isEmpty;
    final hasFilteredResults = products.isNotEmpty || neededItems.isNotEmpty;

    if (isEmpty) {
      return _emptyState(
        'No hay nada en la lista.\n'
        'Marca productos desde el Catálogo, agrega del catálogo '
        'o anota un faltante rápido.',
        icon: Icons.shopping_bag_outlined,
      );
    }

    if (!hasFilteredResults) {
      return _emptyState('No se encontraron ítems con esa búsqueda.');
    }

    final entries = <_ToBuyEntry>[
      ...products.map(_ToBuyEntry.product),
      ...neededItems.map(_ToBuyEntry.needed),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final entry = entries[i];
          if (entry.product != null) {
            final product = entry.product!;
            return ProductCard(
              product: product,
              showCheckButton: true,
              showRemoveFromListButton: true,
              onCheck: () => _onCheck(product),
              onRemoveFromList: () => _onRemoveFromList(product),
            );
          }

          final item = entry.neededItem!;
          return NeededItemCard(
            item: item,
            onCheck: () => _onNeededItemCheck(item),
            onDelete: () => _onDeleteNeededItem(item),
          );
        },
      ),
    );
  }

  Widget _buildPurchasedList(
    List<Product> products, {
    required List<Product> allPurchased,
  }) {
    if (allPurchased.isEmpty) {
      return _emptyState(
        'Aún no has comprado nada hoy.',
        icon: Icons.check_circle_outline_rounded,
      );
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

  Widget _emptyState(String message, {IconData icon = Icons.inbox_rounded}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.onSurfaceMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurfaceMuted,
                  ),
            ),
          ],
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

class _ToBuyEntry {
  const _ToBuyEntry._({this.product, this.neededItem});

  factory _ToBuyEntry.product(Product product) =>
      _ToBuyEntry._(product: product);

  factory _ToBuyEntry.needed(NeededItem item) =>
      _ToBuyEntry._(neededItem: item);

  final Product? product;
  final NeededItem? neededItem;

  String get name => product?.name ?? neededItem!.name;
}
