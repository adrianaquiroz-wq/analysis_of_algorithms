import 'package:flutter/material.dart';

import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/controllers/graph_controller.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/screens/help/help_screen.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/utils/graph_flow_handlers.dart';
import 'package:graph_app/utils/graph_history_mixin.dart';
import 'package:graph_app/utils/graph_interactions_mixin.dart';
import 'package:graph_app/utils/graph_screen_actions.dart';
import 'package:graph_app/widgets/drawer.dart';
import 'package:graph_app/widgets/graph_app_bar.dart';
import 'package:graph_app/widgets/graph_canvas.dart';
import 'package:graph_app/widgets/right_toolbar.dart';
import 'package:graph_app/widgets/selection_actions_bar.dart';

import 'graph_persistence_mixin.dart';
import 'widgets/algorithm_action_button.dart';
import 'widgets/graph_edit_section.dart';

class GraphScreen extends StatefulWidget {
  final bool initialLinearAssignment;
  final bool initialBipartiteAssignment;
  final String algorithmType; // 'free', 'assignment', 'cpm', 'northwest'
  final String algorithmTitle;

  const GraphScreen({
    super.key,
    this.initialLinearAssignment = false,
    this.initialBipartiteAssignment = false,
    this.algorithmType = 'free',
    this.algorithmTitle = 'Lienzo Libre',
  });

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with
        GraphPersistenceMixin<GraphScreen>,
        GraphHistoryMixin<GraphScreen>,
        GraphScreenActions,
        GraphInteractionsMixin {
  @override
  final GraphController graphController = GraphController();

  @override
  final TransformationController transformationController =
      TransformationController();

  @override
  final List<NodeModel> clipboardNodes = [];
  @override
  final List<EdgeModel> clipboardEdges = [];

  @override
  String activeTool = 'select';
  bool _isRightPanelOpen = true;

  // Tema global: se lee y se escribe en el ThemeController.
  @override
  bool get isDarkMode => ThemeController.instance.isDark;

  @override
  set isDarkMode(bool value) {
    ThemeController.instance.set(value);
  }

  // El modo viene de la pantalla de teoría y no cambia en la sesión.
  bool get _isLinearAssignmentFlow => widget.initialLinearAssignment;
  bool get _isBipartiteAssignmentFlow => widget.initialBipartiteAssignment;
  String get _algorithmType => widget.algorithmType;

  @override
  bool get isBipartiteMode => _isBipartiteAssignmentFlow;

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ThemeBuilder(builder: (context, _) => _buildScreen());

  Widget _buildScreen() {
    final backgroundColor = isDarkMode
        ? const Color(0xFF1E293B)
        : const Color.fromARGB(255, 81, 101, 120);
    final appBarColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildCanvas()),
              _buildSelectionBar(appBarColor),
              GraphEditSection(
                graphController: graphController,
                isDarkMode: isDarkMode,
                activeTool: activeTool,
                isRightPanelOpen: _isRightPanelOpen,
                pushUndoSnapshot: pushUndoSnapshot,
                onChange: (change) => setState(change),
              ),
            ],
          ),
          Align(alignment: Alignment.centerRight, child: _buildToolbar()),
          _buildSolverButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- AppBar

  PreferredSizeWidget _buildAppBar() {
    return GraphAppBar(
      isDarkMode: isDarkMode,
      titleText: widget.algorithmTitle,
      canUndo: undoStack.isNotEmpty,
      canRedo: redoStack.isNotEmpty,
      canPaste: clipboardNodes.isNotEmpty,
      canClear:
          graphController.nodes.isNotEmpty || graphController.edges.isNotEmpty,
      onPaste: pasteClipboard,
      onUndo: () => undo(() => setState(() {})),
      onRedo: () => redo(() => setState(() {})),
      onClearCanvas: () => confirmClearCanvasAction(context),
      onThemeChanged: ThemeController.instance.set,
    );
  }

  Widget _buildDrawer() {
    return GraphDrawer(
      isDarkMode: isDarkMode,
      algorithmTitle: widget.algorithmTitle,
      onThemeChanged: ThemeController.instance.set,
      onOpenAdjacencyMatrix: () => GraphFlowHandlers.openAdjacencyMatrix(
        context,
        graphController,
        isDarkMode,
      ),
      onNewCanvas: startNewCanvas,
      onSaveGraph: saveCurrentGraph,
      onOpenSavedGraphs: openSavedGraphs,
      onOpenHelp: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HelpScreen()),
      ),
      onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
    );
  }

  // ---------------------------------------------------------------- Canvas

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        handleViewportConstraints(constraints, kBoardSize);
        return GraphCanvas(
          isDarkMode: isDarkMode,
          nodes: graphController.nodes,
          edges: graphController.edges,
          selectedNodeId: graphController.selectedNodeId,
          selectedEdgeId: graphController.selectedEdgeId,
          pendingSourceNodeId: graphController.pendingSourceNodeId,
          activeTool: activeTool,
          selectedNodeIds: graphController.selectedNodeIds,
          selectedEdgeIds: graphController.selectedEdgeIds,
          marqueeStart: marqueeStart,
          marqueeCurrent: marqueeCurrent,
          transformationController: transformationController,
          onCanvasPanStart: handlePanStart,
          onCanvasPanUpdate: handlePanUpdate,
          onCanvasPanEnd: handlePanEnd,
          onCanvasTapDown: handleCanvasTapDown,
          onEdgeSelected: (edgeId) {
            if (activeTool != 'select') return;
            setState(() {
              graphController.selectedEdgeId = edgeId;
              graphController.selectedNodeId = null;
              graphController.selectedNodeIds.clear();
            });
          },
          onNodeDragStart: (node) => pushUndoSnapshot(),
          onNodePanUpdate: (node, details) {
            if (activeTool != 'select') return;
            setState(() {
              node.position = Offset(
                node.position.dx + details.delta.dx,
                node.position.dy + details.delta.dy,
              );
            });
          },
          onNodeTap: handleNodeTap,
          onCopyNode: (node) => copySelectedArea(),
          onCutNode: (node) => cutSelectedArea(),
          onDeleteNode: handleDeleteNode,
          onDeleteEdge: handleDeleteEdge,
        );
      },
    );
  }

  Widget _buildSelectionBar(Color appBarColor) {
    final show =
        graphController.selectedNodeIds.isNotEmpty &&
        (activeTool == 'select' || activeTool == 'area_select');
    if (!show) return const SizedBox.shrink();

    return Container(
      color: appBarColor,
      child: SelectionActionsBar(
        selectedCount: graphController.selectedNodeIds.length,
        onCut: cutSelectedArea,
        onDelete: deleteSelectedArea,
      ),
    );
  }

  // --------------------------------------------------------------- Toolbar

  Widget _buildToolbar() {
    void selectTool(String tool) {
      setState(() {
        activeTool = tool;
        graphController.clearSelection();
      });
    }

    return RightToolbar(
      isOpen: _isRightPanelOpen,
      isDarkMode: isDarkMode,
      isBipartiteMode: _isBipartiteAssignmentFlow,
      onToggle: () => setState(() => _isRightPanelOpen = !_isRightPanelOpen),
      activeTool: activeTool,
      onSelectTool: selectTool,
      onSelectBipartiteTool: selectTool,
      onZoomIn: zoomIn,
      onZoomOut: zoomOut,
      onZoomReset: () => zoomReset(kBoardSize),
    );
  }

  // ---------------------------------------------------- Botón del método

  Widget _buildSolverButton() {
    final algorithm = solverFor(
      _algorithmType,
      isLinearFlow: _isLinearAssignmentFlow,
      isBipartiteFlow: _isBipartiteAssignmentFlow,
    );
    if (algorithm == null || algorithm.solver == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 60,
      child: AlgorithmActionButton(
        algorithm: algorithm,
        isDarkMode: isDarkMode,
        onPressed: () => algorithm.solver!.open(
          context,
          graphController,
          isDarkMode: isDarkMode,
          isLinearFlow: _isLinearAssignmentFlow,
          isBipartiteFlow: _isBipartiteAssignmentFlow,
        ),
      ),
    );
  }
}
