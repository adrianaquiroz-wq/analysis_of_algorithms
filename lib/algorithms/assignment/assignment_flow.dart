import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';
import 'package:graph_app/screens/adjacency/adjacency_flow.dart';

import 'screens/assignment_screen.dart';

/// Botón de matriz del lienzo: bipartita, lineal o (si no hay modo) adyacencia.
void openAssignmentMatrix(
  BuildContext context,
  GraphController controller, {
  required bool isLinearFlow,
  required bool isBipartiteFlow,
}) {
  if (!isBipartiteFlow && !isLinearFlow) {
    openAdjacencyMatrix(context, controller);
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AssignmentScreen(
        nodes: controller.nodes,
        edges: controller.edges,
        isBipartiteMode: isBipartiteFlow,
      ),
    ),
  );
}
