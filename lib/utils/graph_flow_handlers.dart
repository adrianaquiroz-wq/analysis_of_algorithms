import 'package:flutter/material.dart';

import '../controllers/graph_controller.dart';

import '../screens/adjacency_matrix_screen.dart';

import '../screens/bipartite_matrix_screen.dart';

class GraphFlowHandlers {
  static void openLinearAssignment(
    BuildContext context,

    GraphController graphController,

    bool isDarkMode,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => BipartiteMatrixScreen(
          nodes: graphController.nodes,

          edges: graphController.edges,

          isDarkMode: isDarkMode,

          isBipartiteMode: false,
        ),
      ),
    );
  }

  static void openBipartiteMatrix(
    BuildContext context,

    GraphController graphController,

    bool isDarkMode,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => BipartiteMatrixScreen(
          nodes: graphController.nodes,

          edges: graphController.edges,

          isDarkMode: isDarkMode,

          isBipartiteMode: true,
        ),
      ),
    );
  }

  static void openAdjacencyMatrix(
    BuildContext context,

    GraphController graphController,

    bool isDarkMode,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => AdjacencyMatrixScreen(
          nodes: graphController.nodes,

          edges: graphController.edges,

          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  static void handleMatrixButtonPress({
    required BuildContext context,

    required GraphController graphController,

    required bool isDarkMode,

    required bool isLinearFlow,

    required bool isBipartiteFlow,
  }) {
    if (isBipartiteFlow) {
      openBipartiteMatrix(context, graphController, isDarkMode);
    } else if (isLinearFlow) {
      openLinearAssignment(context, graphController, isDarkMode);
    } else {
      openAdjacencyMatrix(context, graphController, isDarkMode);
    }
  }
}
