import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/screens/saved_graphs/saved_graphs_screen.dart';
import 'package:graph_app/services/graph_storage_service.dart';
import 'package:graph_app/utils/graph_storage_dialogs.dart';

import 'widgets/new_canvas_dialog.dart';

mixin GraphPersistenceMixin<T extends StatefulWidget> on State<T> {
  // Lo que el State de la pantalla debe proveer
  GraphController get graphController;
  bool get isDarkMode;
  void pushUndoSnapshot();

  final GraphStorageService _storageService = GraphStorageService();
  String? _currentGraphId;
  String? _currentGraphName;

  Future<void> saveCurrentGraph() async {
    final name = await GraphStorageDialogs.askGraphName(
      context,
      initialValue: _currentGraphName,
    );
    if (name == null) return;

    final id = await _storageService.saveGraph(
      id: _currentGraphId,
      name: name,
      nodes: graphController.nodes,
      edges: graphController.edges,
    );

    setState(() {
      _currentGraphId = id;
      _currentGraphName = name;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Grafo "$name" guardado.')));
    }
  }

  Future<void> openSavedGraphs() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const SavedGraphsScreen()),
    );
    if (result == null) return;

    pushUndoSnapshot();
    setState(() {
      graphController.nodes
        ..clear()
        ..addAll(result.nodes as List<NodeModel>);
      graphController.edges
        ..clear()
        ..addAll(result.edges as List<EdgeModel>);
      graphController.clearSelection();
      _currentGraphId = result.id as String;
      _currentGraphName = result.name as String;
    });
  }

  /// Limpia el lienzo pero conserva el modo (asignación, noroeste, etc.).
  Future<void> startNewCanvas() async {
    final hasContent =
        graphController.nodes.isNotEmpty || graphController.edges.isNotEmpty;

    if (hasContent && !await confirmNewCanvas(context, isDarkMode)) return;

    pushUndoSnapshot();
    setState(() {
      graphController.nodes.clear();
      graphController.edges.clear();
      graphController.clearSelection();
      _currentGraphId = null;
      _currentGraphName = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lienzo nuevo creado.')));
    }
  }
}
