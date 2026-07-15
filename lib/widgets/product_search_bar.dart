import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Buscar producto por nombre…',
    this.semanticsLabel = 'Buscar productos por nombre',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Semantics(
        label: semanticsLabel,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: AppTheme.fontBody,
            color: AppTheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppTheme.surfaceCard,
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 22,
              color: AppTheme.onSurfaceMuted,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Limpiar búsqueda',
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

List<Product> filterProductsByName(List<Product> products, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return products;
  return products
      .where((p) => p.name.toLowerCase().contains(normalized))
      .toList();
}
