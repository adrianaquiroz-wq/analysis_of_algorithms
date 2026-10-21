import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:graph_app/algorithms/sorting/storage/sort_storage_service.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/utils/graph_storage_dialogs.dart';

/// Lista los conjuntos guardados de un método. Al tocar uno hace pop
/// devolviendo el [SavedSort] para que la pantalla anterior lo cargue.
class SavedSortsScreen extends StatefulWidget {
  final String sortId;

  const SavedSortsScreen({super.key, required this.sortId});

  @override
  State<SavedSortsScreen> createState() => _SavedSortsScreenState();
}

class _SavedSortsScreenState extends State<SavedSortsScreen> {
  final _storage = SortStorageService();
  late Future<List<SavedSort>> _future;

  @override
  void initState() {
    super.initState();
    _future = _storage.list(sortId: widget.sortId);
  }

  void _reload() =>
      setState(() => _future = _storage.list(sortId: widget.sortId));

  Future<void> _delete(SavedSort item, bool isDark) async {
    final ok = await GraphStorageDialogs.confirmDelete(
      context,
      item.name,
      isDarkMode: isDark,
    );
    if (!ok) return;
    await _storage.delete(item.id);
    _reload();
  }

  String _date(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) {
        final p = AppPalette(isDark);

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.appBar,
            title: Text('Datos Guardados', style: TextStyle(color: p.text)),
            iconTheme: IconThemeData(color: p.accent),
          ),
          body: FutureBuilder<List<SavedSort>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(color: p.accent),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No tenés datos guardados todavía.',
                    style: TextStyle(color: p.subtleText),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _tile(items[i], p, isDark),
              );
            },
          ),
        );
      },
    );
  }

  Widget _tile(SavedSort item, AppPalette p, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, item),
        leading: Icon(Icons.format_list_numbered_rounded, color: p.accent),
        title: Text(
          item.name,
          style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${item.values.length} números · '
          '${item.descending ? 'Descendente' : 'Ascendente'} · '
          '${_date(item.updatedAt)}',
          style: TextStyle(color: p.subtleText, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
          ),
          onPressed: () => _delete(item, isDark),
        ),
      ),
    );
  }
}
