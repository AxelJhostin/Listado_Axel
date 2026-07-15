import 'package:flutter/material.dart';

import '../../database/isar_service.dart';
import '../../models/product.dart';
import 'widgets/product_card.dart';
import 'widgets/purchase_check_dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _toBuy = [];
  List<Product> _purchased = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 4,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(text: 'Por Comprar (${_toBuy.length})'),
            Tab(text: 'Ya Comprados (${_purchased.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_toBuy, showCheck: true),
                _buildList(_purchased, showCheck: false),
              ],
            ),
    );
  }

  Widget _buildList(List<Product> products, {required bool showCheck}) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            showCheck
                ? 'No hay productos pendientes.\nAgrega productos en el Catálogo.'
                : 'Aún no has comprado nada hoy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          showCheckButton: showCheck,
          onCheck: () => _onCheck(products[i]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
