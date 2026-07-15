import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../../../database/isar_service.dart';
import '../../../models/distributor.dart';
import '../../../theme/app_theme.dart';

class PurchaseResult {
  PurchaseResult({
    required this.quantity,
    required this.price,
    required this.distributorId,
  });

  final int quantity;
  final double price;
  final Id distributorId;
}

class PurchaseCheckDialog extends StatefulWidget {
  const PurchaseCheckDialog({super.key, required this.productName});

  final String productName;

  @override
  State<PurchaseCheckDialog> createState() => _PurchaseCheckDialogState();
}

class _PurchaseCheckDialogState extends State<PurchaseCheckDialog> {
  int _quantity = 1;
  final _priceController = TextEditingController();
  List<Distributor> _distributors = [];
  Id? _selectedDistributorId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDistributors();
  }

  Future<void> _loadDistributors() async {
    final list = await IsarService.instance.getAllDistributors();
    setState(() {
      _distributors = list;
      _selectedDistributorId = list.isNotEmpty ? list.first.id : null;
      _loading = false;
    });
  }

  bool get _canSave =>
      _quantity > 0 &&
      _selectedDistributorId != null &&
      double.tryParse(_priceController.text.replaceAll(',', '.')) != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Compraste: ${widget.productName}'),
      content: _loading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionLabel('¿Cuántos compraste?'),
                  const SizedBox(height: 12),
                  _QuantityStepper(
                    value: _quantity,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: '¿A qué precio?',
                      prefixText: '\$ ',
                      hintText: '0.00',
                      helperText: 'Escribe el precio que pagaste',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  if (_distributors.isEmpty)
                    const Text(
                      'No hay distribuidores. Agrégalos en la pestaña Distribuidores.',
                      style: TextStyle(
                        fontSize: AppTheme.fontBody,
                        color: AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    DropdownButtonFormField<Id>(
                      initialValue: _selectedDistributorId,
                      items: _distributors
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(
                                d.name,
                                style: const TextStyle(fontSize: AppTheme.fontBody),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedDistributorId = v),
                      decoration: const InputDecoration(
                        labelText: '¿Dónde lo compraste?',
                        helperText: 'Selecciona el distribuidor',
                      ),
                    ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _canSave
              ? () {
                  Navigator.pop(
                    context,
                    PurchaseResult(
                      quantity: _quantity,
                      price: double.parse(
                        _priceController.text.replaceAll(',', '.'),
                      ),
                      distributorId: _selectedDistributorId!,
                    ),
                  );
                }
              : null,
          child: const Text('Guardar compra'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppTheme.fontTitle,
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurface,
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cantidad comprada',
      value: '$value unidades',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BigIconButton(
            icon: Icons.remove,
            semanticLabel: 'Reducir cantidad',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Container(
            width: 88,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          _BigIconButton(
            icon: Icons.add,
            semanticLabel: 'Aumentar cantidad',
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _BigIconButton extends StatelessWidget {
  const _BigIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      child: Material(
        color: onPressed != null ? AppTheme.primary : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: AppTheme.minAccessibleTouch,
            height: AppTheme.minAccessibleTouch,
            child: Center(
              child: Icon(icon, size: 32, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
