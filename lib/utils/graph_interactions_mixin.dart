import 'package:flutter/material.dart';

import '../controllers/graph_controller.dart';
import '../models/node_model.dart';
import '../models/edge_model.dart';
import 'graph_history_mixin.dart';
import 'graph_dialogs.dart';

// Cambiamos la firma para evitar el conflicto genérico con State<T>
mixin GraphInteractionsMixin<T extends StatefulWidget>
    on State<T>, GraphHistoryMixin<T> {
  GraphController get graphController;
  TransformationController get transformationController;

  String get activeTool;
  set activeTool(String value);

  bool get isDarkMode;
  set isDarkMode(bool value);

  // Indica si el flujo de Asignación Bipartida está activo. Cuando está
  // activo, los nodos creados con la herramienta 'node' normal pasan a
  // formar parte del Conjunto A (los de 'bipartite_node' son Conjunto B).
  bool get isBipartiteMode;

  Size? viewportSize;
  bool initialCentered = false;

  Offset? marqueeStart;
  Offset? marqueeCurrent;

  void handleViewportConstraints(BoxConstraints constraints, double boardSize) {
    if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) return;
    viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

    if (!initialCentered) {
      initialCentered = true;
      final double dx = -(boardSize / 2 - constraints.maxWidth / 2);
      final double dy = -(boardSize / 2 - constraints.maxHeight / 2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Usamos setTranslationRaw para mover el Matrix4 sin líos de vectores
        transformationController.value = Matrix4.identity()
          ..setTranslationRaw(dx, dy, 0);
      });
    }
  }

  // --- Funciones de Zoom ---
  void zoomIn() {
    final Matrix4 matrix = transformationController.value.clone();
    final double currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale < 5.0) {
      matrix.scale(1.2);
      transformationController.value = matrix;
    }
  }

  void zoomOut() {
    final Matrix4 matrix = transformationController.value.clone();
    final double currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale > 0.1) {
      matrix.scale(1 / 1.2);
      transformationController.value = matrix;
    }
  }

  void zoomReset(double boardSize) {
    final size = viewportSize;
    if (size == null) {
      transformationController.value = Matrix4.identity();
      return;
    }
    final double dx = -(boardSize / 2 - size.width / 2);
    final double dy = -(boardSize / 2 - size.height / 2);
    transformationController.value = Matrix4.identity()..translate(dx, dy);
  }

  // --- Manejo de Pan / Selección por área ---
  void handlePanStart(Offset localPosition) {
    if (activeTool == 'area_select') {
      setState(() {
        marqueeStart = localPosition;
        marqueeCurrent = localPosition;
        graphController.clearSelection();
      });
    }
  }

  void handlePanUpdate(Offset localPosition) {
    if (activeTool == 'area_select' && marqueeStart != null) {
      setState(() => marqueeCurrent = localPosition);
    }
  }

  void handlePanEnd() {
    if (activeTool == 'area_select' &&
        marqueeStart != null &&
        marqueeCurrent != null) {
      final rect = Rect.fromPoints(marqueeStart!, marqueeCurrent!);
      setState(() {
        for (final node in graphController.nodes) {
          if (rect.contains(node.position)) {
            graphController.selectedNodeIds.add(node.id);
          }
        }
        marqueeStart = null;
        marqueeCurrent = null;
      });
    }
  }

  // --- Toques en el Canvas ---
  void handleCanvasTapDown(TapDownDetails details) {
    if (activeTool == 'node') {
      pushUndoSnapshot();
      setState(() {
        graphController.addNode(
          details.localPosition,
          'N.${graphController.nodes.length + 1}',
        );
        if (isBipartiteMode && graphController.nodes.isNotEmpty) {
          graphController.nodes.last.bipartiteGroup = BipartiteGroup.groupA;
        }
      });
    } else if (activeTool == 'bipartite_node') {
      pushUndoSnapshot();
      setState(() {
        graphController.addNode(
          details.localPosition,
          'N.${graphController.nodes.length + 1}',
        );
        if (graphController.nodes.isNotEmpty) {
          graphController.nodes.last.bipartiteGroup = BipartiteGroup.groupB;
        }
      });
    } else if (activeTool == 'edge') {
      // onTapDown del lienzo se dispara ANTES de que el toque sobre un nodo
      // llegue a handleNodeTap (así funciona el TapGestureRecognizer de
      // Flutter). Si limpiáramos la selección sin condición, el nodo de
      // origen recién marcado se borraría apenas tocás el segundo nodo, y
      // la arista nunca llegaría a crearse. Por eso solo limpiamos si el
      // toque cayó realmente en un área vacía del lienzo.
      final tappedOnNode = graphController.nodes.any(
        (n) => (n.position - details.localPosition).distance <= 25,
      );
      if (!tappedOnNode) {
        setState(() => graphController.clearSelection());
      }
    } else if (activeTool == 'select' || activeTool == 'area_select') {
      setState(() => graphController.clearSelection());
    }
  }

  // --- Toques en Nodos ---
  void handleNodeTap(NodeModel node) {
    if (activeTool == 'select' || activeTool == 'area_select') {
      setState(() {
        graphController.selectedNodeId = node.id;
        graphController.selectedEdgeId = null;
        graphController.selectedNodeIds.clear();
      });
    } else if (activeTool == 'node' || activeTool == 'bipartite_node') {
      setState(() {
        graphController.selectedNodeId = node.id;
        graphController.selectedEdgeId = null;
      });
    } else if (activeTool == 'edge') {
      if (graphController.pendingSourceNodeId == null) {
        setState(() {
          graphController.pendingSourceNodeId = node.id;
          graphController.selectedNodeId = node.id;
        });
      } else if (graphController.pendingSourceNodeId == node.id) {
        final alreadyExists = graphController.edges.any(
          (e) => e.sourceId == node.id && e.targetId == node.id,
        );

        if (alreadyExists) {
          setState(() => graphController.clearSelection());
          return;
        }

        pushUndoSnapshot();
        setState(() {
          graphController.addEdge(node.id, node.id);
          graphController.clearSelection();
        });
      } else {
        final alreadyExists = graphController.edges.any(
          (e) =>
              e.sourceId == graphController.pendingSourceNodeId &&
              e.targetId == node.id,
        );

        if (alreadyExists) {
          setState(() => graphController.clearSelection());
          return;
        }

        pushUndoSnapshot();
        setState(() {
          graphController.addEdge(
            graphController.pendingSourceNodeId!,
            node.id,
          );
          graphController.clearSelection();
        });
      }
    }
  }

  void handleDeleteNode(NodeModel node) {
    pushUndoSnapshot();
    setState(() => graphController.removeNode(node.id));
  }

  void handleDeleteEdge(EdgeModel edge) {
    pushUndoSnapshot();
    setState(() {
      graphController.removeEdge(edge.id);
    });
  }

  Future<void> confirmClearCanvasAction(BuildContext context) async {
    if (graphController.nodes.isEmpty && graphController.edges.isEmpty) return;
    final confirmed = await GraphDialogs.confirmClearCanvas(context);
    if (confirmed) {
      pushUndoSnapshot();
      setState(() {
        graphController.nodes.clear();
        graphController.edges.clear();
        graphController.clearSelection();
      });
    }
  }
}
