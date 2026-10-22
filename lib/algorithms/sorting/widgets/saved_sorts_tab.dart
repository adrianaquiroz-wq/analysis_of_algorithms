import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:graph_app/algorithms/sorting/storage/sort_storage_service.dart';
import 'package:graph_app/algorithms/sorting/widgets/saved_sort_tile.dart';
import 'package:graph_app/theme/app_palette.dart';

class SavedSortsTab extends StatefulWidget {
  final AppPalette palette;
  final void Function(SavedSort sort) onOpen;

  const SavedSortsTab({super.key, required this.palette, required this.onOpen});

  @override
  State<SavedSortsTab> createState() => _SavedSortsTabState();
}

class _SavedSortsTabState extends State<SavedSortsTab> {
  final _service = SortStorageService();
  List<SavedSort> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SortStorageService.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    SortStorageService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final items = await _service.list();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(SavedSort sort) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "${sort.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await _service.delete(sort.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No hay sorts guardados',
          style: TextStyle(color: widget.palette.mutedText),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final sort = _items[i];
          return SavedSortTile(
            sort: sort,
            palette: widget.palette,
            onOpen: () => widget.onOpen(sort),
            onDelete: () => _confirmDelete(sort),
          );
        },
      ),
    );
  }
}
