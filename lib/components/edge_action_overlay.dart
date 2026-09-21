import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/node_model.dart';
import '../utils/graph_math_utils.dart';

class EdgeActionOverlay extends StatelessWidget {
  final String selectedEdgeId;
  final List<EdgeModel> edges;
  final List<NodeModel> nodes;
  final Function(EdgeModel)? onDeleteEdge;

  const EdgeActionOverlay({
    super.key,
    required this.selectedEdgeId,
    required this.edges,
    required this.nodes,
    this.onDeleteEdge,
  });

  @override
  Widget build(BuildContext context) {
    final selectedEdge = edges.firstWhere(
      (e) => e.id == selectedEdgeId,
      orElse: () => edges.first,
    );

    if (selectedEdge.id != selectedEdgeId) {
      return const SizedBox.shrink();
    }

    final midpoint = calculateEdgeMidpoint(
      edge: selectedEdge,
      nodes: nodes,
      allEdges: edges,
    );

    return Positioned(
      left: midpoint.dx - 20,
      top: midpoint.dy - 50,
      child: GestureDetector(
        onTap: () {
          if (onDeleteEdge != null) {
            onDeleteEdge!(selectedEdge);
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyanAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
        ),
      ),
    );
  }
}
