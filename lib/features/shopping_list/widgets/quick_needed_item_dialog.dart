import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/needed_item.dart';
import '../../../theme/app_theme.dart';

class QuickNeededItemDialog extends StatefulWidget {
  const QuickNeededItemDialog({super.key});

  @override
  State<QuickNeededItemDialog> createState() => _QuickNeededItemDialogState();
}

class _QuickNeededItemDialogState extends State<QuickNeededItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Faltante rápido'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '¿Qué falta?',
                  hintText: 'Ej: Servilletas, bolsas, etc.',
                ),
                style: const TextStyle(fontSize: AppTheme.fontBody),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Escribe qué necesitas'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Opcional',
                ),
                style: const TextStyle(fontSize: AppTheme.fontBody),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Marca, presentación, etc.',
                ),
                style: const TextStyle(fontSize: AppTheme.fontBody),
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
          onPressed: _save,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final item = NeededItem()
      ..name = _nameController.text.trim()
      ..quantity = int.tryParse(_quantityController.text.trim())
      ..notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

    Navigator.pop(context, item);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
