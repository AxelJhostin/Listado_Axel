import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/distributor.dart';
import '../../services/location_service.dart';
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

  double? _latitude;
  double? _longitude;
  bool _capturingGps = false;

  @override
  void initState() {
    super.initState();
    final distributor = widget.distributor;
    _nameController = TextEditingController(text: distributor?.name ?? '');
    _locationController = TextEditingController(
      text: distributor?.locationNotes ?? '',
    );
    _phoneController = TextEditingController(
      text: distributor?.phoneNumber ?? '',
    );
    _latitude = distributor?.latitude;
    _longitude = distributor?.longitude;
  }

  Future<void> _captureGps() async {
    setState(() => _capturingGps = true);
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación GPS guardada'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _capturingGps = false);
    }
  }

  void _clearGps() {
    setState(() {
      _latitude = null;
      _longitude = null;
    });
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
    distributor.latitude = _latitude;
    distributor.longitude = _longitude;

    Navigator.pop(context, distributor);
  }

  @override
  Widget build(BuildContext context) {
    final hasGps = _latitude != null && _longitude != null;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del distribuidor',
                  hintText: 'Ej: Distribuidora El Centro',
                  helperText: 'Campo obligatorio',
                ),
                style: const TextStyle(
                  fontSize: AppTheme.fontBody,
                  color: AppTheme.onSurface,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nombre obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Ubicación GPS',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _capturingGps ? null : _captureGps,
                icon: _capturingGps
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                label: Text(
                  _capturingGps
                      ? 'Obteniendo ubicación…'
                      : 'Usar mi ubicación actual',
                ),
              ),
              if (hasGps) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTint,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LocationService.formatCoordinates(
                            _latitude!,
                            _longitude!,
                          ),
                          style: const TextStyle(
                            fontSize: AppTheme.fontBody,
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _clearGps,
                        tooltip: 'Quitar ubicación GPS',
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Párate en el local del distribuidor y toca el botón para guardar el punto exacto.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Notas de ubicación',
                  hintText: 'Pasillo 4, local 12, referencia…',
                  helperText: 'Opcional — complementa el GPS',
                ),
                style: const TextStyle(
                  fontSize: AppTheme.fontBody,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Teléfono de contacto',
                  hintText: 'Número para llamar al proveedor',
                  helperText: 'Opcional',
                ),
                style: const TextStyle(
                  fontSize: AppTheme.fontBody,
                  color: AppTheme.onSurface,
                ),
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
