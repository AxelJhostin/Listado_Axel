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
  final _formKey = GlobalKey<FormState>();
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

  double? get _parsedPrice =>
      double.tryParse(_priceController.text.replaceAll(',', '.'));

  bool get _canSave =>
      _quantity > 0 &&
      _selectedDistributorId != null &&
      _parsedPrice != null &&
      _parsedPrice! > 0;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistributorId == null) return;

    Navigator.pop(
      context,
      PurchaseResult(
        quantity: _quantity,
        price: _parsedPrice!,
        distributorId: _selectedDistributorId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Compraste: ${widget.productName}'),
      content: _loading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                    TextFormField(
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
                        color: AppTheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        labelText: '¿A qué precio?',
                        prefixText: '\$ ',
                        hintText: '0.00',
                        helperText: 'Escribe el precio que pagaste',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el precio';
                        }
                        final price = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (price == null || price <= 0) {
                          return 'El precio debe ser mayor a 0';
                        }
                        return null;
                      },
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
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: AppTheme.fontBody,
                          color: AppTheme.onSurface,
                        ),
                        dropdownColor: AppTheme.surfaceCard,
                        iconEnabledColor: AppTheme.primary,
                        items: _distributors
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(
                                  d.name,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontBody,
                                    color: AppTheme.onSurface,
                                  ),
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
                        validator: (value) =>
                            value == null ? 'Selecciona un distribuidor' : null,
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _canSave ? _save : null,
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
            width: 72,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
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
            width: 40,
            height: 40,
            child: Center(
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
