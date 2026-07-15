import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.showCheckButton,
    this.showUndoButton = false,
    this.onCheck,
    this.onUndo,
  });

  final Product product;
  final bool showCheckButton;
  final bool showUndoButton;
  final VoidCallback? onCheck;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final distributors = product.distributors
        .map((d) => d.name)
        .where((n) => n.isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
            children: [
              _ProductThumbnail(path: product.localImagePath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (product.currentStock != null)
                          _InfoChip(
                            label: 'Stock: ${product.currentStock}',
                            color: product.currentStock! <= 2
                                ? AppTheme.warning
                                : AppTheme.onSurfaceMuted,
                            background: product.currentStock! <= 2
                                ? const Color(0xFFFFFBEB)
                                : AppTheme.surface,
                          ),
                        if (!showCheckButton &&
                            product.purchasedQuantity != null)
                          _InfoChip(
                            label:
                                '${product.purchasedQuantity} u. · \$${product.purchasePrice?.toStringAsFixed(2) ?? '—'}',
                            color: AppTheme.success,
                            background: AppTheme.primaryTint,
                          ),
                      ],
                    ),
                    if (distributors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        distributors.join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!showCheckButton &&
                        product.finalDistributor.value != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.finalDistributor.value!.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (showCheckButton)
                IconButton.filled(
                  onPressed: onCheck,
                  tooltip: 'Marcar comprado',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 22),
                ),
              if (showUndoButton)
                IconButton.outlined(
                  onPressed: onUndo,
                  tooltip: 'Deshacer compra',
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.warning,
                    side: const BorderSide(color: AppTheme.cardBorder),
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.undo_rounded, size: 20),
                ),
            ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
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
    const size = 56.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: SizedBox(
        width: size,
        height: size,
        child: path != null && File(path!).existsSync()
            ? Image.file(File(path!), fit: BoxFit.cover)
            : ColoredBox(
                color: AppTheme.surface,
                child: const Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
      ),
    );
  }
}
