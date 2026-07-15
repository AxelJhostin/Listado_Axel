import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.showCheckButton,
    this.onCheck,
  });

  final Product product;
  final bool showCheckButton;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final distributors = product.distributors
        .map((d) => d.name)
        .where((n) => n.isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumbnail(path: product.localImagePath),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (product.currentStock != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: product.currentStock! <= 2
                            ? AppTheme.warning.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stock en tienda: ${product.currentStock}',
                        style: TextStyle(
                          fontSize: AppTheme.fontBody,
                          fontWeight: FontWeight.bold,
                          color: product.currentStock! <= 2
                              ? AppTheme.warning
                              : AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                  if (distributors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Sugerido en: ${distributors.join(', ')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (!showCheckButton && product.purchasedQuantity != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Comprado: ${product.purchasedQuantity} u. · '
                      '\$${product.purchasePrice?.toStringAsFixed(2) ?? '—'}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontBody,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                    if (product.finalDistributor.value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'En: ${product.finalDistributor.value!.name}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (showCheckButton) ...[
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Marcar ${product.name} como comprado',
                child: SizedBox(
                  width: 80,
                  child: FilledButton(
                    onPressed: onCheck,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      minimumSize: const Size(
                        AppTheme.minAccessibleTouch,
                        AppTheme.minTouchTarget,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 32),
                        SizedBox(height: 4),
                        Text('Check', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    const size = 80.0;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: path != null && File(path!).existsSync()
            ? Image.file(
                File(path!),
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }
}
