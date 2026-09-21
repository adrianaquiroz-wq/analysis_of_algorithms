import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/node_model.dart';
import '../utils/graph_math_utils.dart';
import 'edge_painter.dart';
import 'graph_node_layer.dart';
import '../components/grid_painter.dart';
import '../components/marquee_painter.dart';
import '../components/edge_action_overlay.dart'; // <-- Nuevo componente extraído

// Tamaño de la pizarra gigante. Se usa tanto para el Container como
// para la grilla de fondo, así quedan siempre alineados.
const double kBoardSize = 5000;

class GraphCanvas extends StatelessWidget {
  final bool isDarkMode;
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final String? selectedNodeId;
  final String? selectedEdgeId;
  final String? pendingSourceNodeId;
  final String activeTool;
  final Set<String> selectedNodeIds;
  final Set<String> selectedEdgeIds;
  final Offset? marqueeStart;
  final Offset? marqueeCurrent;
  final TransformationController transformationController;

  final void Function(Offset localPosition) onCanvasPanStart;
  final void Function(Offset localPosition) onCanvasPanUpdate;
  final VoidCallback onCanvasPanEnd;
  final void Function(TapDownDetails details) onCanvasTapDown;
  final void Function(String edgeId) onEdgeSelected;
  final void Function(NodeModel node) onNodeDragStart;
  final void Function(NodeModel node, DragUpdateDetails details)
  onNodePanUpdate;
  final void Function(NodeModel node) onNodeTap;
  final void Function(NodeModel node) onCopyNode;
  final void Function(NodeModel node) onCutNode;
  final void Function(NodeModel node) onDeleteNode;
  final Function(EdgeModel)? onDeleteEdge;

  const GraphCanvas({
    super.key,
    required this.isDarkMode,
    required this.nodes,
    required this.edges,
    required this.selectedNodeId,
    required this.selectedEdgeId,
    required this.pendingSourceNodeId,
    required this.activeTool,
    required this.selectedNodeIds,
    required this.selectedEdgeIds,
    required this.marqueeStart,
    required this.marqueeCurrent,
    required this.transformationController,
    required this.onCanvasPanStart,
    required this.onCanvasPanUpdate,
    required this.onCanvasPanEnd,
    required this.onCanvasTapDown,
    required this.onEdgeSelected,
    required this.onNodeDragStart,
    required this.onNodePanUpdate,
    required this.onNodeTap,
    required this.onCopyNode,
    required this.onCutNode,
    required this.onDeleteNode,
    required this.onDeleteEdge,
  });

  @override
  Widget build(BuildContext context) {
    bool isAreaSelectTool = activeTool == 'area_select';

    return InteractiveViewer(
      transformationController: transformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      panEnabled: !isAreaSelectTool,
      scaleEnabled: true,
      constrained: false,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: isAreaSelectTool
            ? (details) => onCanvasPanStart(details.localPosition)
            : null,
        onPanUpdate: isAreaSelectTool
            ? (details) => onCanvasPanUpdate(details.localPosition)
            : null,
        onPanEnd: isAreaSelectTool ? (_) => onCanvasPanEnd() : null,
        onTapDown: onCanvasTapDown,
        child: Container(
          width: kBoardSize,
          height: kBoardSize,
          color: const Color(0xFF3B82F6).withOpacity(0.08),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: GridPainter()),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  // Lógica limpia delegada a utilidades matemáticas
                  final bestEdgeId = findClosestEdgeId(
                    tapPosition: details.localPosition,
                    edges: edges,
                    nodes: nodes,
                  );

                  if (bestEdgeId != null) {
                    onEdgeSelected(bestEdgeId);
                  }
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: EdgePainter(
                    edges: edges,
                    nodes: nodes,
                    selectedEdgeId: selectedEdgeId,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
              ...buildGraphNodeWidgets(
                nodes: nodes,
                selectedNodeId: selectedNodeId,
                pendingSourceNodeId: pendingSourceNodeId,
                activeTool: activeTool,
                isDarkMode: isDarkMode,
                onNodeDragStart: onNodeDragStart,
                onNodePanUpdate: onNodePanUpdate,
                onNodeTap: onNodeTap,
                onCopyNode: onCopyNode,
                onCutNode: onCutNode,
                onDeleteNode: onDeleteNode,
              ),
              if (marqueeStart != null && marqueeCurrent != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: MarqueePainter(
                      start: marqueeStart!,
                      current: marqueeCurrent!,
                    ),
                  ),
                ),
              if (selectedEdgeId != null)
                EdgeActionOverlay(
                  selectedEdgeId: selectedEdgeId!,
                  edges: edges,
                  nodes: nodes,
                  onDeleteEdge: onDeleteEdge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
