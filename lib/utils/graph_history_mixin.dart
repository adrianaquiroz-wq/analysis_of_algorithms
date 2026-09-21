import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../controllers/graph_controller.dart';

class GraphSnapshot {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  GraphSnapshot({required this.nodes, required this.edges});
}

// QUITAMOS EL <T extends StatefulWidget> para evitar conflictos en el State
mixin GraphHistoryMixin<T extends StatefulWidget> on State<T> {
  GraphController get graphController;

  final List<GraphSnapshot> undoStack = [];
  final List<GraphSnapshot> redoStack = [];
  static const int maxHistory = 50;

  // Clona la lista de nodos preservando TODOS los campos (incluido
  // bipartiteGroup). Usar copyWith en vez de reconstruir el NodeModel a
  // mano evita que el undo/redo pierda datos que no se listen aquí
  // explícitamente si el modelo crece a futuro.
  List<NodeModel> _cloneNodes(List<NodeModel> nodes) =>
      nodes.map((n) => n.copyWith()).toList();

  List<EdgeModel> _cloneEdges(List<EdgeModel> edges) => edges
      .map(
        (e) => EdgeModel(
          id: e.id,
          sourceId: e.sourceId,
          targetId: e.targetId,
          type: e.type,
          weight: e.weight,
          color: e.color,
        ),
      )
      .toList();

  void pushUndoSnapshot() {
    undoStack.add(
      GraphSnapshot(
        nodes: _cloneNodes(graphController.nodes),
        edges: _cloneEdges(graphController.edges),
      ),
    );
    redoStack.clear();
    if (undoStack.length > maxHistory) undoStack.removeAt(0);
  }

  void undo(VoidCallback onStateChanged) {
    if (undoStack.isEmpty) return;
    final previous = undoStack.removeLast();

    setState(() {
      redoStack.add(
        GraphSnapshot(
          nodes: _cloneNodes(graphController.nodes),
          edges: _cloneEdges(graphController.edges),
        ),
      );
      graphController.nodes
        ..clear()
        ..addAll(previous.nodes);
      graphController.edges
        ..clear()
        ..addAll(previous.edges);
      graphController.clearSelection();
    });
    onStateChanged();
  }

  void redo(VoidCallback onStateChanged) {
    if (redoStack.isEmpty) return;
    final next = redoStack.removeLast();

    setState(() {
      undoStack.add(
        GraphSnapshot(
          nodes: _cloneNodes(graphController.nodes),
          edges: _cloneEdges(graphController.edges),
        ),
      );
      graphController.nodes
        ..clear()
        ..addAll(next.nodes);
      graphController.edges
        ..clear()
        ..addAll(next.edges);
      graphController.clearSelection();
    });
    onStateChanged();
  }
}
