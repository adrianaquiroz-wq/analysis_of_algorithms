import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';

import 'screens/northwest_screen.dart';

void openNorthwestCorner(BuildContext context, GraphController controller) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          NorthwestScreen(nodes: controller.nodes, edges: controller.edges),
    ),
  );
}
