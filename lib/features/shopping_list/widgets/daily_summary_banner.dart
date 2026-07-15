import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/product.dart';
import '../utils/purchase_report_builder.dart';
import '../../../theme/app_theme.dart';

class DailySummaryBanner extends StatelessWidget {
  const DailySummaryBanner({super.key, required this.purchasedProducts});

  final List<Product> purchasedProducts;

  int get _totalUnits => PurchaseSummary.totalUnits(purchasedProducts);

  double get _totalSpent => PurchaseSummary.totalSpent(purchasedProducts);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: AppTheme.onPrimary, size: 28),
                SizedBox(width: 10),
                Text(
                  'Resumen del día',
                  style: TextStyle(
                    fontSize: AppTheme.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: 'Unidades compradas',
                    value: '$_totalUnits',
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppTheme.onPrimary.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: 'Total invertido',
                    value: currency.format(_totalSpent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontHeadline,
              fontWeight: FontWeight.bold,
              color: AppTheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
