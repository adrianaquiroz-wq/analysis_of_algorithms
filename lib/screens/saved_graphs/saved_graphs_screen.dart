import 'package:flutter/material.dart';
import 'package:graph_app/models/saved_graph.dart';
import 'package:graph_app/services/graph_storage_service.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/utils/graph_storage_dialogs.dart';

import 'widgets/saved_graph_tile.dart';

/// Lista los grafos guardados. Al tocar uno hace pop devolviendo el
/// SavedGraph completo para que la pantalla anterior lo cargue.
class SavedGraphsScreen extends StatefulWidget {
  const SavedGraphsScreen({super.key});

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

  void _reload() => setState(() => _futureGraphs = _storage.listSavedGraphs());

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
    return ThemeBuilder(
      builder: (context, isDark) {
        final palette = AppPalette(isDark);

        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            backgroundColor: palette.appBar,
            elevation: isDark ? 0 : 1,
            title: Text(
              'Grafos Guardados',
              style: TextStyle(color: palette.text),
            ),
            iconTheme: IconThemeData(color: palette.accent),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: palette.accent,
                ),
                onPressed: ThemeController.instance.toggle,
              ),
            ],
          ),
          body: FutureBuilder<List<SavedGraphMeta>>(
            future: _futureGraphs,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(color: palette.accent),
                );
              }

              final graphs = snapshot.data ?? [];
              if (graphs.isEmpty) {
                return Center(
                  child: Text(
                    'No tenés grafos guardados todavía.',
                    style: TextStyle(color: palette.subtleText),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: graphs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => SavedGraphTile(
                  meta: graphs[index],
                  palette: palette,
                  onOpen: () => _openGraph(graphs[index]),
                  onDelete: () => _deleteGraph(graphs[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
