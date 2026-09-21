import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/saved_graph.dart';
import '../services/graph_storage_service.dart';
import '../utils/graph_storage_dialogs.dart';

/// Pantalla que lista los grafos guardados. Al tocar uno, se hace
/// pop devolviendo el SavedGraph completo para que la pantalla anterior
/// lo cargue.
class SavedGraphsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool>? onToggleTheme;

  const SavedGraphsScreen({
    super.key,
    this.isDarkMode = true,
    this.onToggleTheme,
  });

  @override
  State<SavedGraphsScreen> createState() => _SavedGraphsScreenState();
}

class _SavedGraphsScreenState extends State<SavedGraphsScreen> {
  final _storage = GraphStorageService();
  late Future<List<SavedGraphMeta>> _futureGraphs;

  @override
  void initState() {
    super.initState();
    _futureGraphs = _storage.listSavedGraphs();
  }

  void _reload() {
    setState(() {
      _futureGraphs = _storage.listSavedGraphs();
    });
  }

  Future<void> _openGraph(SavedGraphMeta meta) async {
    final fullGraph = await _storage.loadGraph(meta.id);
    if (fullGraph == null || !mounted) return;
    Navigator.pop(context, fullGraph);
  }

  Future<void> _deleteGraph(SavedGraphMeta meta) async {
    final confirmed = await GraphStorageDialogs.confirmDelete(
      context,
      meta.name,
    );
    if (!confirmed) return;
    await _storage.deleteGraph(meta.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    // Paleta dinámica (mismo esquema que HelpScreen / AdjacencyMatrixScreen)
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDarkMode ? Colors.white12 : Colors.black12;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final subTextColorLighter = isDarkMode ? Colors.white54 : Colors.black45;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: isDarkMode ? 0 : 1,
        title: Text('Grafos Guardados', style: TextStyle(color: titleColor)),
        iconTheme: IconThemeData(color: accentColor),
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: accentColor,
              ),
              onPressed: () => widget.onToggleTheme!(!isDarkMode),
            ),
        ],
      ),
      body: FutureBuilder<List<SavedGraphMeta>>(
        future: _futureGraphs,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          final graphs = snapshot.data ?? [];
          if (graphs.isEmpty) {
            return Center(
              child: Text(
                'No tenés grafos guardados todavía.',
                style: TextStyle(color: subTextColor),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: graphs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final meta = graphs[index];
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                  .format(meta.updatedAt);

              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cardBorderColor),
                ),
                child: ListTile(
                  title: Text(
                    meta.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Última edición: $formattedDate',
                    style: TextStyle(color: subTextColorLighter),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _deleteGraph(meta),
                  ),
                  onTap: () => _openGraph(meta),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
