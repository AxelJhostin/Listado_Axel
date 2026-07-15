import 'package:flutter/material.dart';

import '../../database/isar_service.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_search_bar.dart';
import 'product_form_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<Product> get _filteredProducts =>
      filterProductsByName(_products, _searchQuery);

  Future<void> _load() async {
    setState(() => _loading = true);
    final products = await IsarService.instance.getAllProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _openForm([Product? product]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Nuevo producto', style: TextStyle(fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ProductSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onClear: _clearSearch,
                  hintText: 'Buscar en el catálogo por nombre…',
                  semanticsLabel: 'Buscar productos en el catálogo',
                ),
                Expanded(child: _buildBody(filtered)),
              ],
            ),
    );
  }

  Widget _buildBody(List<Product> filtered) {
    if (_products.isEmpty) {
      return _emptyState(
        'No hay productos.\nToca "Nuevo producto" para empezar.',
      );
    }

    if (filtered.isEmpty) {
      return _emptyState('No se encontraron productos en el catálogo.');
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _CatalogProductCard(
          product: filtered[i],
          onTap: () => _openForm(filtered[i]),
        ),
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Semantics(
        button: true,
        label: 'Editar producto ${product.name}',
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          minVerticalPadding: AppTheme.minAccessibleTouch / 2,
          title: Text(
            product.name,
            style: const TextStyle(
              fontSize: AppTheme.fontLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: product.description != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    product.description!,
                    style: TextStyle(
                      fontSize: AppTheme.fontBody,
                      color: AppTheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : null,
          trailing: const Icon(Icons.chevron_right, size: 32),
          onTap: onTap,
        ),
      ),
    );
  }
}
