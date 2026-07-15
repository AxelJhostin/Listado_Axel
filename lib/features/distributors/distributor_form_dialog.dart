import 'package:flutter/material.dart';

import '../../models/distributor.dart';
import '../../theme/app_theme.dart';

class DistributorFormDialog extends StatefulWidget {
  const DistributorFormDialog({super.key, this.distributor});

  final Distributor? distributor;

  @override
  State<DistributorFormDialog> createState() => _DistributorFormDialogState();
}

class _DistributorFormDialogState extends State<DistributorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.distributor?.name ?? '',
    );
    _locationController = TextEditingController(
      text: widget.distributor?.locationNotes ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.distributor?.phoneNumber ?? '',
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final distributor = widget.distributor ?? Distributor();
    distributor.name = _nameController.text.trim();
    distributor.locationNotes = _locationController.text.trim().isEmpty
        ? null
        : _locationController.text.trim();
    distributor.phoneNumber = _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim();

    Navigator.pop(context, distributor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.distributor == null
            ? 'Nuevo distribuidor'
            : 'Editar distribuidor',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del distribuidor',
                  hintText: 'Ej: Distribuidora El Centro',
                  helperText: 'Campo obligatorio',
                ),
                style: const TextStyle(fontSize: AppTheme.fontBody),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nombre obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación en el mercado',
                  hintText: 'Pasillo 4, local 12, o dirección',
                  helperText: 'Opcional — para encontrarlo rápido',
                ),
                style: const TextStyle(fontSize: AppTheme.fontBody),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono de contacto',
                  hintText: 'Número para llamar al proveedor',
                  helperText: 'Opcional',
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
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
