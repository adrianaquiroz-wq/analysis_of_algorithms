import 'package:flutter/material.dart';

import '../controllers/graph_controller.dart';
import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../widgets/right_toolbar.dart';
import '../widgets/graph_canvas.dart';
import '../widgets/bottom_edit_panel.dart';
import '../widgets/graph_app_bar.dart';
import '../widgets/selection_actions_bar.dart';
import '../widgets/drawer.dart';
import '../utils/graph_screen_actions.dart';
import '../utils/graph_history_mixin.dart';
import '../utils/graph_interactions_mixin.dart';
import '../utils/graph_flow_handlers.dart';
import 'help_screen.dart';
import 'saved_graphs_screen.dart';
import '../services/graph_storage_service.dart';
import '../utils/graph_storage_dialogs.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with
        GraphHistoryMixin<GraphScreen>,
        GraphScreenActions,
        GraphInteractionsMixin {
  @override
  final GraphController graphController = GraphController();

  @override
  final TransformationController transformationController =
      TransformationController();

  @override
  String activeTool = 'select';
  bool _isRightPanelOpen = true;
  @override
  bool isDarkMode = true;

  bool _isLinearAssignmentFlow = false;
  bool _isBipartiteAssignmentFlow = false;

  // Expone al mixin si el flujo bipartido está activo, para que
  // handleCanvasTapDown sepa asignar Conjunto A / Conjunto B al crear nodos.
  @override
  bool get isBipartiteMode => _isBipartiteAssignmentFlow;

  @override
  final List<NodeModel> clipboardNodes = [];
  @override
  final List<EdgeModel> clipboardEdges = [];

  final GraphStorageService _storageService = GraphStorageService();
  String? _currentGraphId;
  String? _currentGraphName;

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentGraph() async {
    final name = await GraphStorageDialogs.askGraphName(
      context,
      initialValue: _currentGraphName,
    );
    if (name == null) return;

    final id = await _storageService.saveGraph(
      id: _currentGraphId,
      name: name,
      nodes: graphController.nodes,
      edges: graphController.edges,
    );

    setState(() {
      _currentGraphId = id;
      _currentGraphName = name;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Grafo "$name" guardado.')));
    }
  }

  Future<void> _openSavedGraphs() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => SavedGraphsScreen(isDarkMode: isDarkMode),
      ),
    );
    if (result == null) return;

    pushUndoSnapshot();
    setState(() {
      graphController.nodes
        ..clear()
        ..addAll(result.nodes as List<NodeModel>);
      graphController.edges
        ..clear()
        ..addAll(result.edges as List<EdgeModel>);
      graphController.clearSelection();
      _currentGraphId = result.id as String;
      _currentGraphName = result.name as String;
    });
  }

  void _selectLinearAssignmentMode() {
    setState(() {
      _isLinearAssignmentFlow = true;
      _isBipartiteAssignmentFlow = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Modo Asignación Lineal activado. Edita tu grafo y presiona el botón de matriz para calcular.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _selectBipartiteAssignmentMode() {
    setState(() {
      _isBipartiteAssignmentFlow = true;
      _isLinearAssignmentFlow = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Modo Asignación Bipartida activado. Dibuja tus nodos en conjuntos y presiona el botón de matriz.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _startNewCanvas() async {
    final hasContent =
        graphController.nodes.isNotEmpty || graphController.edges.isNotEmpty;

    if (hasContent) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Nuevo Lienzo',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Vas a empezar un grafo en blanco. Los cambios sin guardar se perderán. ¿Querés continuar?',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Nuevo Lienzo',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    pushUndoSnapshot();
    setState(() {
      graphController.nodes.clear();
      graphController.edges.clear();
      graphController.clearSelection();
      _currentGraphId = null;
      _currentGraphName = null;
      _isLinearAssignmentFlow = false;
      _isBipartiteAssignmentFlow = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lienzo nuevo creado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF1E293B)
        : const Color.fromARGB(255, 81, 101, 120);
    final appBarColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: GraphAppBar(
        isDarkMode: isDarkMode,
        canUndo: undoStack.isNotEmpty,
        canRedo: redoStack.isNotEmpty,
        canPaste: clipboardNodes.isNotEmpty,
        canClear:
            graphController.nodes.isNotEmpty ||
            graphController.edges.isNotEmpty,
        onPaste: pasteClipboard,
        onUndo: () => undo(() => setState(() {})),
        onRedo: () => redo(() => setState(() {})),
        onClearCanvas: () => confirmClearCanvasAction(context),
        onThemeChanged: (value) => setState(() => isDarkMode = value),
      ),
      drawer: GraphDrawer(
        isDarkMode: isDarkMode,
        onThemeChanged: (value) => setState(() => isDarkMode = value),
        isLinearAssignmentActive: _isLinearAssignmentFlow,
        isBipartiteAssignmentActive: _isBipartiteAssignmentFlow,
        onOpenAdjacencyMatrix: () => GraphFlowHandlers.openAdjacencyMatrix(
          context,
          graphController,
          isDarkMode,
        ),
        onNewCanvas: _startNewCanvas,
        onSaveGraph: _saveCurrentGraph,
        onOpenSavedGraphs: _openSavedGraphs,
        onLinearAssignment: _selectLinearAssignmentMode,
        onBipartiteAssignment: _selectBipartiteAssignmentMode,
        onJohnsonAlgorithm: () => GraphFlowHandlers.openJohnson(
          context,
          graphController,
          isDarkMode,
        ),
        onOpenHelp: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HelpScreen(isDarkMode: isDarkMode),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          handleViewportConstraints(constraints, kBoardSize);
                          return GraphCanvas(
                            isDarkMode: isDarkMode,
                            nodes: graphController.nodes,
                            edges: graphController.edges,
                            selectedNodeId: graphController.selectedNodeId,
                            selectedEdgeId: graphController.selectedEdgeId,
                            pendingSourceNodeId:
                                graphController.pendingSourceNodeId,
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
                      ),
                    ),
                    if (graphController.selectedNodeIds.isNotEmpty &&
                        (activeTool == 'select' || activeTool == 'area_select'))
                      Container(
                        color: appBarColor,
                        child: SelectionActionsBar(
                          selectedCount: graphController.selectedNodeIds.length,
                          onCut: cutSelectedArea,
                          onDelete: deleteSelectedArea,
                        ),
                      ),
                    if ((graphController.selectedNode != null ||
                            graphController.selectedEdge != null) &&
                        activeTool == 'select' &&
                        graphController.selectedNodeIds.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          right: _isRightPanelOpen ? 64.0 : 0.0,
                        ),
                        child: BottomEditPanel(
                          isDarkMode: isDarkMode,
                          selectedNode: graphController.selectedNode,
                          selectedEdge: graphController.selectedEdge,
                          onClose: () =>
                              setState(() => graphController.clearSelection()),
                          onEditNodeLabel: (label) => setState(
                            () =>
                                graphController.updateSelectedNodeLabel(label),
                          ),
                          onEditNodeAttribute1: (val) => setState(
                            () => graphController.updateSelectedNodeAttribute1(
                              val,
                            ),
                          ),
                          onEditNodeAttribute2: (val) => setState(
                            () => graphController.updateSelectedNodeAttribute2(
                              val,
                            ),
                          ),
                          onEditNodeColor: (color) {
                            pushUndoSnapshot();
                            setState(
                              () => graphController.updateSelectedNodeColor(
                                color,
                              ),
                            );
                          },
                          onSelectEdgeType: (type) {
                            pushUndoSnapshot();
                            setState(
                              () =>
                                  graphController.updateSelectedEdgeType(type),
                            );
                          },
                          onEditEdgeWeight: (weight) => setState(
                            () => graphController.updateSelectedEdgeWeight(
                              weight,
                            ),
                          ),
                          onEditEdgeColor: (color) {
                            pushUndoSnapshot();
                            setState(
                              () => graphController.updateSelectedEdgeColor(
                                color,
                              ),
                            );
                          },
                          onAddReverseEdge: () {
                            pushUndoSnapshot();
                            setState(() => graphController.addReverseEdge());
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RightToolbar(
              isOpen: _isRightPanelOpen,
              isDarkMode: isDarkMode,
              isBipartiteMode:
                  _isBipartiteAssignmentFlow, // <--- Pasamos el estado aquí
              onToggle: () =>
                  setState(() => _isRightPanelOpen = !_isRightPanelOpen),
              activeTool: activeTool,
              onSelectTool: (tool) {
                setState(() {
                  activeTool = tool;
                  graphController.clearSelection();
                });
              },
              // Opcional: Si el botón extra selecciona una herramienta especial para conjuntos bipartitos
              onSelectBipartiteTool: (tool) {
                setState(() {
                  activeTool =
                      tool; // Ej: 'node_set_b' o la herramienta que uses
                  graphController.clearSelection();
                });
              },
              onZoomIn: zoomIn,
              onZoomOut: zoomOut,
              onZoomReset: () => zoomReset(kBoardSize),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'matrixResultsButton',
            backgroundColor: isDarkMode ? const Color(0xFF334155) : Colors.white,
            foregroundColor: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
            elevation: isDarkMode ? 4 : 2,
            tooltip: "Ver Matriz / Resultados",
            child: Icon(
              Icons.grid_view_rounded,
              color: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
            ),
            onPressed: () {
              GraphFlowHandlers.handleMatrixButtonPress(
                context: context,
                graphController: graphController,
                isDarkMode: isDarkMode,
                isLinearFlow: _isLinearAssignmentFlow,
                isBipartiteFlow: _isBipartiteAssignmentFlow,
              );
            },
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'northwestCornerButton',
            backgroundColor: isDarkMode ? const Color(0xFF334155) : Colors.white,
            foregroundColor: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
            elevation: isDarkMode ? 4 : 2,
            tooltip: "Northwest Corner",
            child: Icon(
              Icons.alt_route_rounded,
              color: isDarkMode ? Colors.cyanAccent : Colors.blueAccent,
            ),
            onPressed: () {
              GraphFlowHandlers.openNorthwestCorner(
                context,
                graphController,
                isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }
}
