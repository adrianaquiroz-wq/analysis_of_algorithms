import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';

import 'screens/cpm_screen.dart';

void openCpm(BuildContext context, GraphController controller) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          CpmScreen(nodes: controller.nodes, edges: controller.edges),
    ),
  );
}
