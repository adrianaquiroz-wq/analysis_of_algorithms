import 'package:flutter/material.dart';

import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/algorithms/dijkstra/logic/dijkstra_algorithm.dart';
import 'package:graph_app/algorithms/kruskal/logic/kruskal_algorithm.dart';
import 'package:graph_app/controllers/graph_controller.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/screens/help/help_screen.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
//import 'package:graph_app/utils/graph_flow_handlers.dart';
import 'package:graph_app/screens/adjacency/adjacency_flow.dart';
import 'package:graph_app/utils/graph_history_mixin.dart';
import 'package:graph_app/utils/graph_interactions_mixin.dart';
import 'package:graph_app/utils/graph_screen_actions.dart';
import 'package:graph_app/widgets/drawer.dart';
import 'package:graph_app/widgets/graph_app_bar.dart';
import 'package:graph_app/widgets/graph_canvas.dart';
import 'package:graph_app/widgets/right_toolbar.dart';
import 'package:graph_app/widgets/selection_actions_bar.dart';
import 'package:graph_app/algorithms/selection_sort/screens/selection_sort_screen.dart';

import 'graph_persistence_mixin.dart';
import 'widgets/algorithm_action_button.dart';
import 'widgets/graph_edit_section.dart';

const _criticalPathColor = Color(0xFFDC2626);

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
  String? _dijkstraSourceId;
  String? _dijkstraTargetId;
  DijkstraResult? _dijkstraResult;
  int _dijkstraStep = 0;
  bool _dijkstraRunning = false;
  bool _dijkstraPaused = false;
  DijkstraOptimization _dijkstraOptimization =
      DijkstraOptimization.minimize;
  int _dijkstraRunId = 0;
  Map<String, double> _dijkstraDistances = {};
  Map<String, Color> _dijkstraNodeColors = {};
  Map<String, Color> _dijkstraEdgeColors = {};
  final Map<String, Color> _normalNodeColors = {};
  final Map<String, Color> _normalEdgeColors = {};
  KruskalResult? _kruskalResult;
  int _kruskalStep = 0;
  bool _kruskalRunning = false;
  bool _kruskalPaused = false;
  KruskalOptimization _kruskalOptimization =
      KruskalOptimization.minimize;
  int _kruskalRunId = 0;
  Map<String, Color> _kruskalNodeColors = {};
  Map<String, Color> _kruskalEdgeColors = {};

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
  EdgeType get newEdgeType =>
      _algorithmType == 'kruskal' ? EdgeType.simple : EdgeType.directed;

  @override
  bool get isKruskalMode => _algorithmType == 'kruskal';

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
          if (_algorithmType == 'dijkstra') _buildDijkstraPanel(),
          if (_algorithmType == 'kruskal') _buildKruskalPanel(),
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
      onOpenAdjacencyMatrix: () =>
          openAdjacencyMatrix(context, graphController),
      onNewCanvas: startNewCanvas,
      onSaveGraph: saveCurrentGraph,
      onOpenSavedGraphs: openSavedGraphs,
      onSelectionSort: _openSelectionSort,
      onOpenHelp: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HelpScreen()),
      ),
      onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
    );
  }

  Future<void> _openSelectionSort() async {
    if (graphController.edges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una arista con peso.')),
      );
      return;
    }

    final sortedEdges = await Navigator.push<List<EdgeModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionSortScreen(graphEdges: graphController.edges),
      ),
    );
    if (!mounted || sortedEdges == null) return;

    pushUndoSnapshot();
    setState(() {
      graphController.edges
        ..clear()
        ..addAll(sortedEdges);
      graphController.clearSelection();
    });
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
          dijkstraDistances: _algorithmType == 'dijkstra'
              ? _dijkstraDistances
              : null,
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
          onNodeTap: _handleNodeTap,
          onCopyNode: (node) => copySelectedArea(),
          onCutNode: (node) => cutSelectedArea(),
          onDeleteNode: handleDeleteNode,
          onDeleteEdge: handleDeleteEdge,
        );
      },
    );
  }

  void _handleNodeTap(NodeModel node) {
    if (_algorithmType != 'dijkstra' || activeTool != 'select') {
      handleNodeTap(node);
      return;
    }
    if (_dijkstraRunning) return;
    setState(() {
      if (_dijkstraSourceId == null || _dijkstraTargetId != null) {
        _resetDijkstra();
        _dijkstraSourceId = node.id;
      } else {
        _dijkstraTargetId = node.id;
      }
      graphController.selectedNodeId = node.id;
      graphController.selectedEdgeId = null;
      graphController.selectedNodeIds.clear();
    });
  }

  Widget _buildKruskalPanel() {
    return Positioned(
      right: 16,
      bottom: 60,
      child: FloatingActionButton.extended(
        onPressed: _showKruskalOptions,
        icon: const Icon(Icons.account_tree_rounded),
        label: const Text('Kruskal'),
      ),
    );
  }

  Future<void> _showKruskalOptions() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) {
          void refresh(VoidCallback action) {
            setState(action);
            dialogSetState(() {});
          }

          final result = _kruskalResult;
          return AlertDialog(
            title: const Text('Kruskal · opciones'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Construye el árbol de expansión mínima '
                      'seleccionando aristas sin formar ciclos.',
                    ),
                    _buildColorLegend(),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<KruskalOptimization>(
                      initialValue: _kruskalOptimization,
                      decoration: const InputDecoration(
                        labelText: 'Objetivo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: KruskalOptimization.minimize,
                          child: Text('Minimizar peso'),
                        ),
                        DropdownMenuItem(
                          value: KruskalOptimization.maximize,
                          child: Text('Maximizar peso'),
                        ),
                      ],
                      onChanged: _kruskalRunning
                          ? null
                          : (value) => refresh(
                                () {
                                  if (value != null) {
                                    _kruskalOptimization = value;
                                    _kruskalResult = null;
                                  }
                                },
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result == null
                          ? 'Todavía no se ha construido el árbol.'
                          : 'Aristas seleccionadas: '
                              '${result.minimumSpanningTreeEdgeIds.length}'
                              ' · ${_kruskalOptimization == KruskalOptimization.minimize ? 'Suma mínima' : 'Suma máxima'}: '
                              '${result.totalWeight}',
                    ),
                    if (result != null &&
                        result.connectedNodeIds.length <
                            graphController.nodes.length)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'El grafo no es conexo: se muestran varios componentes.',
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _kruskalRunning ? null : _startKruskal,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Construir árbol'),
                        ),
                        if (_kruskalRunning)
                          OutlinedButton.icon(
                            onPressed: () => refresh(
                              () => _kruskalPaused = !_kruskalPaused,
                            ),
                            icon: Icon(
                              _kruskalPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                            ),
                            label: Text(
                              _kruskalPaused ? 'Continuar' : 'Pausa',
                            ),
                          ),
                        if (_kruskalRunning)
                          OutlinedButton.icon(
                            onPressed: _kruskalPaused
                                ? () {
                                    _advanceKruskal();
                                    dialogSetState(() {});
                                  }
                                : null,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('Paso'),
                          ),
                        OutlinedButton.icon(
                          onPressed: _kruskalRunning
                              ? null
                              : () {
                                  _resetKruskal();
                                  dialogSetState(() {});
                                },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reiniciar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }

    void _startKruskal() {
      try {
        _saveKruskalColors();
        final result = KruskalAlgorithm.run(
          nodes: graphController.nodes,
          edges: graphController.edges,
          optimization: _kruskalOptimization,
        );
        setState(() {
          _kruskalResult = result;
          _kruskalStep = 0;
          _kruskalRunning = true;
          _kruskalPaused = false;
        });
        _playKruskal(++_kruskalRunId);
      } on FormatException catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }

    Widget _buildColorLegend() {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _legendItem(_criticalPathColor, 'Ruta crítica'),
          ],
        ),
      );
    }

    Widget _legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      );
    }

    Future<void> _playKruskal(int runId) async {
      final result = _kruskalResult!;
      while (_kruskalStep < result.steps.length) {
        if (!mounted || runId != _kruskalRunId) return;
        if (_kruskalPaused) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          continue;
        }
        _advanceKruskal();
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
      if (!mounted || runId != _kruskalRunId) return;
      setState(() {
        _restoreNormalColors();
        final criticalNodeIds = <String>{};
        for (final node in graphController.nodes) {
          node.color = _kruskalNodeColors[node.id] ?? node.color;
        }
        for (final edge in graphController.edges) {
          if (!result.minimumSpanningTreeEdgeIds.contains(edge.id)) continue;
          edge.color = _criticalPathColor;
          criticalNodeIds
            ..add(edge.sourceId)
            ..add(edge.targetId);
        }
        for (final node in graphController.nodes) {
          if (criticalNodeIds.contains(node.id)) {
            node.color = _criticalPathColor;
          }
        }
        _kruskalRunning = false;
        _kruskalPaused = false;
      });
    }

    void _advanceKruskal() {
      final result = _kruskalResult;
      if (result == null || _kruskalStep >= result.steps.length) return;
      _kruskalStep++;
      setState(_restoreNormalColors);
    }

    void _saveKruskalColors() {
      _captureNormalColors();
      _restoreNormalColors();
      _kruskalNodeColors = Map.of(_normalNodeColors);
      _kruskalEdgeColors = Map.of(_normalEdgeColors);
    }

    void _resetKruskal() {
      _kruskalRunId++;
      _restoreNormalColors();
      _kruskalResult = null;
      _kruskalStep = 0;
      _kruskalRunning = false;
      _kruskalPaused = false;
      _kruskalNodeColors.clear();
      _kruskalEdgeColors.clear();
      setState(() {});
  }

  Widget _buildDijkstraPanel() {
    return Positioned(
      right: 16,
      bottom: 60,
      child: FloatingActionButton.extended(
        onPressed: _showDijkstraOptions,
        icon: const Icon(Icons.route_rounded),
        label: const Text('Dijkstra'),
      ),
    );
  }

  Future<void> _showDijkstraOptions() async {
    final nodeIds = graphController.nodes.map((node) => node.id).toSet();
    if (!nodeIds.contains(_dijkstraSourceId)) {
      _dijkstraSourceId = null;
    }
    if (!nodeIds.contains(_dijkstraTargetId)) {
      _dijkstraTargetId = null;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) {
          void refresh(VoidCallback action) {
            setState(action);
            dialogSetState(() {});
          }

          final source = _nodeLabel(_dijkstraSourceId);
          final target = _nodeLabel(_dijkstraTargetId);
          return AlertDialog(
            title: const Text('Dijkstra · opciones'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona el origen y el destino haciendo clic '
                      'sobre los nodos del lienzo.',
                    ),
                    _buildColorLegend(),
                    const SizedBox(height: 12),
                    Text(
                      'Origen: ${source ?? 'pendiente'}\n'
                      'Destino: ${target ?? 'pendiente'}',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _dijkstraSourceId,
                      decoration: const InputDecoration(
                        labelText: 'Nodo de inicio',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final node in graphController.nodes)
                          DropdownMenuItem(
                            value: node.id,
                            child: Text(node.label),
                          ),
                      ],
                      onChanged: _dijkstraRunning
                          ? null
                          : (value) => refresh(
                                () {
                                  _dijkstraSourceId = value;
                                  _dijkstraResult = null;
                                },
                              ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<DijkstraOptimization>(
                      initialValue: _dijkstraOptimization,
                      decoration: const InputDecoration(
                        labelText: 'Objetivo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DijkstraOptimization.minimize,
                          child: Text('Minimizar distancia'),
                        ),
                        DropdownMenuItem(
                          value: DijkstraOptimization.maximize,
                          child: Text('Maximizar distancia'),
                        ),
                      ],
                      onChanged: _dijkstraRunning
                          ? null
                          : (value) => refresh(
                                () {
                                  if (value != null) {
                                    _dijkstraOptimization = value;
                                    _dijkstraResult = null;
                                  }
                                },
                              ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _dijkstraTargetId,
                      decoration: const InputDecoration(
                        labelText: 'Nodo final',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final node in graphController.nodes)
                          DropdownMenuItem(
                            value: node.id,
                            child: Text(node.label),
                          ),
                      ],
                      onChanged: _dijkstraRunning
                          ? null
                          : (value) => refresh(
                                () {
                                  _dijkstraTargetId = value;
                                  _dijkstraResult = null;
                                },
                              ),
                    ),
                    if (_dijkstraResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _dijkstraResult!.pathNodeIds.isEmpty
                            ? 'No existe una ruta entre los nodos seleccionados.'
                            : 'Ruta: ${_dijkstraResult!.pathNodeIds.map(_nodeLabel).join(' → ')}\n'
                                'Distancia: ${_dijkstraResult!.distance}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (_dijkstraStep > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Distancias: ${_dijkstraResult!.steps[_dijkstraStep - 1].distances.entries.map((entry) => '${_nodeLabel(entry.key)}: ${entry.value == double.infinity ? '∞' : entry.value}').join(' · ')}',
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _dijkstraRunning ||
                                  _dijkstraSourceId == null ||
                                  _dijkstraTargetId == null
                              ? null
                              : () {
                                  _startDijkstra();
                                  dialogSetState(() {});
                                },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Ejecutar'),
                        ),
                        if (_dijkstraRunning)
                          OutlinedButton.icon(
                            onPressed: () => refresh(
                              () => _dijkstraPaused = !_dijkstraPaused,
                            ),
                            icon: Icon(
                              _dijkstraPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                            ),
                            label: Text(
                              _dijkstraPaused ? 'Continuar' : 'Pausa',
                            ),
                          ),
                        if (_dijkstraRunning)
                          OutlinedButton.icon(
                            onPressed: _dijkstraPaused
                                ? () {
                                    _advanceDijkstra();
                                    dialogSetState(() {});
                                  }
                                : null,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('Paso'),
                          ),
                        OutlinedButton.icon(
                          onPressed: _dijkstraRunning
                              ? null
                              : () {
                                  _resetDijkstra();
                                  dialogSetState(() {});
                                },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reiniciar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _nodeLabel(String? id) {
    if (id == null) return null;
    for (final node in graphController.nodes) {
      if (node.id == id) return node.label;
    }
    return id;
  }

  void _startDijkstra() {
    try {
      _saveDijkstraColors();
      final result = DijkstraAlgorithm.run(
        nodes: graphController.nodes,
        edges: graphController.edges,
        sourceId: _dijkstraSourceId!,
        targetId: _dijkstraTargetId!,
        optimization: _dijkstraOptimization,
      );
      setState(() {
        _dijkstraResult = result;
        _dijkstraStep = 0;
        _dijkstraDistances = {};
        _dijkstraRunning = true;
        _dijkstraPaused = false;
      });
      _playDijkstra(++_dijkstraRunId);
    } on FormatException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _playDijkstra(int runId) async {
    final result = _dijkstraResult!;
    while (_dijkstraStep < result.steps.length) {
      if (!mounted || runId != _dijkstraRunId) return;
      if (_dijkstraPaused) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        continue;
      }
      _advanceDijkstra();
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }
    if (!mounted || runId != _dijkstraRunId) return;
    setState(() {
      _restoreNormalColors();
      _dijkstraDistances = result.distances;
      for (final id in result.pathNodeIds) {
        _nodeById(id)?.color = _criticalPathColor;
      }
      for (final id in result.pathEdgeIds) {
        _edgeById(id)?.color = _criticalPathColor;
      }
      _dijkstraRunning = false;
      _dijkstraPaused = false;
    });
  }

  void _advanceDijkstra() {
    if (_dijkstraResult == null || _dijkstraStep >= _dijkstraResult!.steps.length) {
      return;
    }
    final step = _dijkstraResult!.steps[_dijkstraStep++];
    setState(() {
      _restoreNormalColors();
      _dijkstraDistances = step.distances;
    });
  }

  NodeModel? _nodeById(String id) {
    for (final node in graphController.nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  EdgeModel? _edgeById(String id) {
    for (final edge in graphController.edges) {
      if (edge.id == id) return edge;
    }
    return null;
  }

  void _saveDijkstraColors() {
    _captureNormalColors();
    _restoreNormalColors();
    _dijkstraNodeColors = Map.of(_normalNodeColors);
    _dijkstraEdgeColors = Map.of(_normalEdgeColors);
  }

  void _resetDijkstra() {
    _dijkstraRunId++;
    _restoreNormalColors();
    _dijkstraSourceId = null;
    _dijkstraTargetId = null;
    _dijkstraResult = null;
    _dijkstraDistances = {};
    _dijkstraStep = 0;
    _dijkstraRunning = false;
    _dijkstraPaused = false;
    _dijkstraNodeColors.clear();
    _dijkstraEdgeColors.clear();
    setState(() {});
  }

  void _captureNormalColors() {
    for (final node in graphController.nodes) {
      _normalNodeColors.putIfAbsent(node.id, () => node.color);
    }
    for (final edge in graphController.edges) {
      _normalEdgeColors.putIfAbsent(edge.id, () => edge.color);
    }
  }

  void _restoreNormalColors() {
    for (final node in graphController.nodes) {
      final color = _normalNodeColors[node.id];
      if (color != null) node.color = color;
    }
    for (final edge in graphController.edges) {
      final color = _normalEdgeColors[edge.id];
      if (color != null) edge.color = color;
    }
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
