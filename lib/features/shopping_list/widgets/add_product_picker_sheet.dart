import 'package:flutter/material.dart';

import '../../../database/isar_service.dart';
import '../../../models/product.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/product_search_bar.dart';

class AddProductPickerSheet extends StatefulWidget {
  const AddProductPickerSheet({super.key});

  @override
  State<AddProductPickerSheet> createState() => _AddProductPickerSheetState();
}

class _AddProductPickerSheetState extends State<AddProductPickerSheet> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    final products = await IsarService.instance.getCatalogProductsNotOnList();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _addProduct(Product product) async {
    await IsarService.instance.setNeedsPurchase(product, true);
    if (mounted) Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterProductsByName(_products, _searchController.text);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Agregar producto a la lista',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ProductSearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onClear: () => _searchController.clear(),
              hintText: 'Buscar en el catálogo…',
              semanticsLabel: 'Buscar producto para agregar',
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Todos los productos del catálogo ya están en la lista.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppTheme.onSurfaceMuted),
                            ),
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron productos.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppTheme.onSurfaceMuted),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final product = filtered[i];
                                return ListTile(
                                  title: Text(product.name),
                                  trailing: IconButton(
                                    onPressed: () => _addProduct(product),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppTheme.primary,
                                    ),
                                    tooltip: 'Agregar a lista',
                                  ),
                                  onTap: () => _addProduct(product),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
