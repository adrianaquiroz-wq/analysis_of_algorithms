import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';

import 'adjacency_matrix_screen.dart';

void openAdjacencyMatrix(BuildContext context, GraphController controller) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AdjacencyMatrixScreen(
        nodes: controller.nodes,
        edges: controller.edges,
      ),
    ),
  );
}
