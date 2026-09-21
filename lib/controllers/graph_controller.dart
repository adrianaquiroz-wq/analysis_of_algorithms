import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';

class GraphController {
  final List<NodeModel> nodes = [];
  final List<EdgeModel> edges = [];

  //Almacena el id
  //que está seleccionada actualmente (puede ser null
  String? selectedNodeId;
  String? selectedEdgeId;
  String? pendingSourceNodeId;

  final Set<String> selectedNodeIds = {};
  final Set<String> selectedEdgeIds = {};

  NodeModel? get selectedNode {
    if (selectedNodeId == null) return null;
    try {
      return nodes.firstWhere((n) => n.id == selectedNodeId);
    } catch (_) {
      return null;
    }
  }

  EdgeModel? get selectedEdge {
    if (selectedEdgeId == null) return null;
    try {
      return edges.firstWhere((e) => e.id == selectedEdgeId);
    } catch (_) {
      return null;
    }
  }

  void clearSelection() {
    selectedNodeId = null;
    selectedEdgeId = null;
    pendingSourceNodeId = null;
    selectedNodeIds.clear();
    selectedEdgeIds.clear();
  }

  void addNode(Offset position, String label) {
    nodes.add(
      NodeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: position,
        label: label,
      ),
    );
  }

  void removeNode(String id) {
    edges.removeWhere((e) => e.sourceId == id || e.targetId == id);
    nodes.removeWhere((n) => n.id == id);
    if (selectedNodeId == id) selectedNodeId = null;
    selectedNodeIds.remove(id);
  }

  void addEdge(String sourceId, String targetId) {
    edges.add(
      EdgeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceId: sourceId,
        targetId: targetId,
        type: EdgeType.directed,
      ),
    );
  }

  void updateSelectedNodeLabel(String label) {
    final node = selectedNode;
    if (node != null) node.label = label;
  }

  void updateSelectedNodeColor(Color color) {
    final node = selectedNode;
    if (node != null) node.color = color;
  }

  void updateSelectedEdgeWeight(double weight) {
    final edge = selectedEdge;
    if (edge != null) edge.weight = weight;
  }

  void updateSelectedEdgeColor(Color color) {
    final edge = selectedEdge;
    if (edge != null) edge.color = color;
  }

  void updateSelectedEdgeType(EdgeType type) {
    final edge = selectedEdge;
    if (edge != null) edge.type = type;
  }

  void addReverseEdge() {
    final edge = selectedEdge;
    if (edge == null) return;

    final exists = edges.any(
      (e) => e.sourceId == edge.targetId && e.targetId == edge.sourceId,
    );
    if (exists) return;

    edges.add(
      EdgeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceId: edge.targetId,
        targetId: edge.sourceId,
        type: edge.type,
        weight: edge.weight,
        color: edge.color,
      ),
    );
  }

  void updateSelectedNodeAttribute1(String val) {
    if (selectedNode != null) {
      selectedNode!.attribute1 = val;
    }
  }

  void updateSelectedNodeAttribute2(String val) {
    if (selectedNode != null) {
      selectedNode!.attribute2 = val;
    }
  }

  // Añade este método dentro de tu clase GraphController:
  void removeEdge(String id) {
    edges.removeWhere((e) => e.id == id);
    if (selectedEdgeId == id) selectedEdgeId = null;
    selectedEdgeIds.remove(id);
  }
}
