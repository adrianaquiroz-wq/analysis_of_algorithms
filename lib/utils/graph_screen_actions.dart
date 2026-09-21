import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../controllers/graph_controller.dart';

mixin GraphScreenActions<T extends StatefulWidget> on State<T> {
  GraphController get graphController;
  List<NodeModel> get clipboardNodes;
  List<EdgeModel> get clipboardEdges;

  void pushUndoSnapshot();

  void copySelectedArea() {
    if (graphController.selectedNodeIds.isEmpty) return;
    setState(() {
      clipboardNodes.clear();
      clipboardEdges.clear();

      for (final id in graphController.selectedNodeIds) {
        final node = graphController.nodes.firstWhere((n) => n.id == id);
        clipboardNodes.add(node);
      }

      for (final edge in graphController.edges) {
        if (graphController.selectedNodeIds.contains(edge.sourceId) &&
            graphController.selectedNodeIds.contains(edge.targetId)) {
          clipboardEdges.add(edge);
        }
      }
    });
  }

  void cutSelectedArea() {
    if (graphController.selectedNodeIds.isEmpty) return;
    pushUndoSnapshot();
    setState(() {
      copySelectedArea();
      for (final id in graphController.selectedNodeIds.toList()) {
        graphController.removeNode(id);
      }
      graphController.selectedNodeIds.clear();
    });
  }

  void deleteSelectedArea() {
    if (graphController.selectedNodeIds.isEmpty) return;
    pushUndoSnapshot();
    setState(() {
      for (final id in graphController.selectedNodeIds.toList()) {
        graphController.removeNode(id);
      }
      graphController.selectedNodeIds.clear();
    });
  }

  void pasteClipboard() {
    if (clipboardNodes.isEmpty) return;
    pushUndoSnapshot();
    setState(() {
      final Map<String, String> idMapping = {};
      graphController.selectedNodeIds.clear();

      for (final node in clipboardNodes) {
        final newId =
            DateTime.now().millisecondsSinceEpoch.toString() + node.id;
        idMapping[node.id] = newId;

        final newNode = NodeModel(
          id: newId,
          position: Offset(node.position.dx + 40, node.position.dy + 40),
          label: '${node.label}\'',
          color: node.color,
        );

        graphController.nodes.add(newNode);
        graphController.selectedNodeIds.add(newId);
      }

      for (final edge in clipboardEdges) {
        if (idMapping.containsKey(edge.sourceId) &&
            idMapping.containsKey(edge.targetId)) {
          graphController.edges.add(
            EdgeModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sourceId: idMapping[edge.sourceId]!,
              targetId: idMapping[edge.targetId]!,
              type: edge.type,
              weight: edge.weight,
              color: edge.color,
            ),
          );
        }
      }
    });
  }
}
