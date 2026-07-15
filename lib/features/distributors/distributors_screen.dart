import 'package:flutter/material.dart';

import '../../database/isar_service.dart';
import '../../models/distributor.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import 'distributor_form_dialog.dart';

class DistributorsScreen extends StatefulWidget {
  const DistributorsScreen({super.key});

  @override
  State<DistributorsScreen> createState() => _DistributorsScreenState();
}

class _DistributorsScreenState extends State<DistributorsScreen> {
  List<Distributor> _distributors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await IsarService.instance.getAllDistributors();
    if (mounted) {
      setState(() {
        _distributors = list;
        _loading = false;
      });
    }
  }

  Future<void> _addOrEdit([Distributor? distributor]) async {
    final saved = await showDialog<Distributor>(
      context: context,
      builder: (_) => DistributorFormDialog(distributor: distributor),
    );

    if (saved != null) {
      await IsarService.instance.saveDistributor(saved);
      await _load();
    }
  }

  Future<void> _openMaps(Distributor distributor) async {
    if (!distributor.hasGpsLocation) return;

    try {
      await LocationService.openInMaps(
        latitude: distributor.latitude!,
        longitude: distributor.longitude!,
        label: distributor.name,
      );
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribuidores')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        tooltip: 'Nuevo distribuidor',
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _distributors.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 48,
                          color: AppTheme.onSurfaceMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay distribuidores.\nToca + para agregar uno.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _distributors.length,
                  itemBuilder: (_, i) {
                    final d = _distributors[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          d.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.hasGpsLocation) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      LocationService.formatCoordinates(
                                        d.latitude!,
                                        d.longitude!,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppTheme.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (d.locationNotes != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.notes_outlined,
                                    size: 16,
                                    color: AppTheme.onSurfaceMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      d.locationNotes!,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (d.phoneNumber != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 16,
                                    color: AppTheme.onSurfaceMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    d.phoneNumber!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (d.hasGpsLocation)
                              IconButton(
                                onPressed: () => _openMaps(d),
                                tooltip: 'Abrir en mapa',
                                icon: const Icon(
                                  Icons.map_rounded,
                                  color: AppTheme.primary,
                                ),
                              ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 22,
                              color: AppTheme.onSurfaceMuted,
                            ),
                          ],
                        ),
                        onTap: () => _addOrEdit(d),
                      ),
                    );
                  },
                ),
    );
  }
}
