import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/features/admin/views/desktop/home%20widgets/admin_top_bar.dart';

class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  final List<String> _collections = [
    'users',
    'menu_items',
    'orders',
    'tables',
    'payments',
  ];

  Map<String, int> _collectionCounts = {};
  Map<String, bool> _selectedCollections = {};
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    for (var col in _collections) {
      _selectedCollections[col] = false;
    }
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    setState(() {
      _isLoading = true;
    });
    
    Map<String, int> counts = {};
    for (var col in _collections) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection(col).count().get();
        counts[col] = snapshot.count ?? 0;
      } catch (e) {
        counts[col] = 0;
      }
    }

    if (mounted) {
      setState(() {
        _collectionCounts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelected() async {
    final selectedCols = _selectedCollections.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedCols.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one collection.')),
      );
      return;
    }

    _showDeleteConfirmation(selectedCols);
  }

  Future<void> _deleteAll() async {
    _showDeleteConfirmation(_collections);
  }

  void _showDeleteConfirmation(List<String> collectionsToDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to delete all documents in the following collections:\n\n${collectionsToDelete.join(', ')}\n\nThis action cannot be undone!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeDeletion(collectionsToDelete);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeDeletion(List<String> collectionsToDelete) async {
    setState(() {
      _isDeleting = true;
    });

    final instance = FirebaseFirestore.instance;

    for (var col in collectionsToDelete) {
      try {
        final snapshots = await instance.collection(col).get();
        final batch = instance.batch();
        int count = 0;
        
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
          count++;
          // Firestore batches support up to 500 operations
          if (count == 490) {
            await batch.commit();
            count = 0;
          }
        }
        if (count > 0) {
          await batch.commit();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting $col: $e')),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isDeleting = false;
        // Uncheck all after deletion
        for (var col in collectionsToDelete) {
          _selectedCollections[col] = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected collections cleared.')),
      );
      _fetchCounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    bool allSelected = _collections.isNotEmpty &&
        _selectedCollections.values.every((v) => v == true);
    bool anySelected = _selectedCollections.values.any((v) => v == true);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            const SizedBox(height: 32),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "Data Management",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Manage and monitor your database collections.",
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isDeleting
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                "Deleting data...",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: allSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          for (var col in _collections) {
                                            _selectedCollections[col] =
                                                val ?? false;
                                          }
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Select All",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _fetchCounts,
                                  tooltip: "Refresh Counts",
                                ),
                              ],
                            ),
                            const Divider(),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _collections.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final col = _collections[index];
                                return CheckboxListTile(
                                  title: Text(
                                    col.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                      "${_collectionCounts[col] ?? 0} documents"),
                                  value: _selectedCollections[col],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCollections[col] = val ?? false;
                                    });
                                  },
                                  activeColor: colorScheme.primary,
                                  secondary: Icon(
                                    Icons.storage,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _deleteAll,
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text("DELETE ALL COLLECTIONS"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    side: BorderSide(color: colorScheme.error),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed:
                                      anySelected ? _deleteSelected : null,
                                  icon: const Icon(Icons.delete),
                                  label: const Text("DELETE SELECTED"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.error,
                                    foregroundColor: colorScheme.onError,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
