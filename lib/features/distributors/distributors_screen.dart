import 'package:flutter/material.dart';

import '../../database/isar_service.dart';
import '../../models/distributor.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribuidores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add, size: 32),
        label: const Text('Nuevo', style: TextStyle(fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _distributors.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay distribuidores.\nToca "+" para agregar uno.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
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
                        contentPadding: const EdgeInsets.all(20),
                        title: Text(
                          d.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.locationNotes != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.place, size: 20),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      d.locationNotes!,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (d.phoneNumber != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    d.phoneNumber!,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.edit, size: 28),
                        onTap: () => _addOrEdit(d),
                      ),
                    );
                  },
                ),
    );
  }
}
