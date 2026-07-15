import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/isar_service.dart';
import '../../models/distributor.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  String? _imagePath;
  List<Distributor> _allDistributors = [];
  final Set<Id> _selectedDistributorIds = {};

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _allDistributors = await IsarService.instance.getAllDistributors();

    if (_isEditing) {
      final product = widget.product!;
      _nameController.text = product.name;
      if (product.currentStock != null) {
        _stockController.text = '${product.currentStock}';
      }
      if (product.description != null) {
        _descController.text = product.description!;
      }
      _imagePath = product.localImagePath;
      await product.distributors.load();
      _selectedDistributorIds.addAll(
        product.distributors.map((d) => d.id),
      );
    }

    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final saved = await File(file.path).copy(p.join(imagesDir.path, fileName));

    setState(() => _imagePath = saved.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final product = widget.product ?? Product();
    product.name = _nameController.text.trim();
    product.currentStock = int.tryParse(_stockController.text.trim());
    product.description = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();
    product.localImagePath = _imagePath;

    await IsarService.instance.saveProduct(
      product,
      distributorIds: _selectedDistributorIds.toList(),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PhotoPicker(
              imagePath: _imagePath,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                hintText: 'Ej: Arroz, Aceite, Detergente…',
                helperText: 'Campo obligatorio',
              ),
              style: const TextStyle(fontSize: AppTheme.fontBody),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock actual en tienda',
                hintText: 'Cuántas unidades quedan en tu local',
                helperText: 'Opcional — ayuda a ver la urgencia',
              ),
              style: const TextStyle(fontSize: AppTheme.fontBody),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas o descripción',
                hintText: 'Marca preferida, presentación, etc.',
                helperText: 'Opcional',
              ),
              style: const TextStyle(fontSize: AppTheme.fontBody),
            ),
            const SizedBox(height: 24),
            Text(
              'Distribuidores habituales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_allDistributors.isEmpty)
              const Text('Aún no hay distribuidores registrados.')
            else
              ..._allDistributors.map(
                (d) => CheckboxListTile(
                  value: _selectedDistributorIds.contains(d.id),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedDistributorIds.add(d.id);
                      } else {
                        _selectedDistributorIds.remove(d.id);
                      }
                    });
                  },
                  title: Text(d.name, style: const TextStyle(fontSize: 18)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
  });

  final String? imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Foto del producto',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: imagePath != null && File(imagePath!).existsSync()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(imagePath!),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Sin foto — toca un botón abajo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text('Tomar foto'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppTheme.minTouchTarget),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library, size: 28),
                label: const Text('Galería'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppTheme.minTouchTarget),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
