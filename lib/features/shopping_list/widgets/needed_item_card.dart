import 'package:flutter/material.dart';

import '../../../models/needed_item.dart';
import '../../../theme/app_theme.dart';

class NeededItemCard extends StatelessWidget {
  const NeededItemCard({
    super.key,
    required this.item,
    this.onCheck,
    this.onDelete,
  });

  final NeededItem item;
  final VoidCallback? onCheck;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppTheme.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Faltante',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.quantity != null || item.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (item.quantity != null) '${item.quantity} u.',
                        if (item.notes != null) item.notes!,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton.outlined(
                onPressed: onDelete,
                tooltip: 'Eliminar',
                style: IconButton.styleFrom(
                  foregroundColor: AppTheme.onSurfaceMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  minimumSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            if (onCheck != null)
              IconButton.filled(
                onPressed: onCheck,
                tooltip: 'Marcar conseguido',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.check_rounded, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
