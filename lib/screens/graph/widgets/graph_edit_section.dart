import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';
import 'package:graph_app/widgets/bottom_edit_panel.dart';

class GraphEditSection extends StatelessWidget {
  final GraphController graphController;
  final bool isDarkMode;
  final String activeTool;
  final bool isRightPanelOpen;
  final VoidCallback pushUndoSnapshot;

  /// Normalmente: (fn) => setState(fn)
  final void Function(VoidCallback change) onChange;

  const GraphEditSection({
    super.key,
    required this.graphController,
    required this.isDarkMode,
    required this.activeTool,
    required this.isRightPanelOpen,
    required this.pushUndoSnapshot,
    required this.onChange,
  });

  bool get _visible =>
      (graphController.selectedNode != null ||
          graphController.selectedEdge != null) &&
      activeTool == 'select' &&
      graphController.selectedNodeIds.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    // Aplica un cambio; con snapshot=true guarda antes el estado para deshacer.
    void edit(VoidCallback change, {bool snapshot = false}) {
      if (snapshot) pushUndoSnapshot();
      onChange(change);
    }

    return Padding(
      padding: EdgeInsets.only(right: isRightPanelOpen ? 64.0 : 0.0),
      child: BottomEditPanel(
        isDarkMode: isDarkMode,
        selectedNode: graphController.selectedNode,
        selectedEdge: graphController.selectedEdge,
        onClose: () => onChange(graphController.clearSelection),
        onEditNodeLabel: (label) =>
            edit(() => graphController.updateSelectedNodeLabel(label)),
        onEditNodeAttribute1: (val) =>
            edit(() => graphController.updateSelectedNodeAttribute1(val)),
        onEditNodeAttribute2: (val) =>
            edit(() => graphController.updateSelectedNodeAttribute2(val)),
        onEditNodeColor: (color) => edit(
          () => graphController.updateSelectedNodeColor(color),
          snapshot: true,
        ),
        onSelectEdgeType: (type) => edit(
          () => graphController.updateSelectedEdgeType(type),
          snapshot: true,
        ),
        onEditEdgeWeight: (weight) =>
            edit(() => graphController.updateSelectedEdgeWeight(weight)),
        onEditEdgeColor: (color) => edit(
          () => graphController.updateSelectedEdgeColor(color),
          snapshot: true,
        ),
        onAddReverseEdge: () =>
            edit(graphController.addReverseEdge, snapshot: true),
      ),
    );
  }
}
