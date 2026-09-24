import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../models/johnson_step.dart';
import '../utils/johnson_algorithm.dart';
import '../widgets/johnson_graph_painter.dart';

class JohnsonScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final bool isDarkMode;

  const JohnsonScreen({
    super.key,
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
  });

  @override
  State<JohnsonScreen> createState() => _JohnsonScreenState();
}

class _JohnsonScreenState extends State<JohnsonScreen> {
  static const double _padding = 90;
  static const double _topPadding = 150;
  static const double _virtualNodeY = 60;

  JohnsonResult? _result;
  int _stepIndex = 0;
  Timer? _timer;
  bool _playing = false;
  String? _error;

  Map<String, Offset> _positions = {};
  Map<String, String> _labels = {};
  Size _canvasSize = const Size(400, 300);

  @override
  void initState() {
    super.initState();
    if (widget.nodes.length < 2 || widget.edges.isEmpty) {
      _error =
          'Necesitás al menos 2 nodos conectados por aristas para calcular '
          'Johnson. Volvé al editor y completá tu grafo.';
      return;
    }
    _result = JohnsonAlgorithm.solve(nodes: widget.nodes, edges: widget.edges);
    _computeLayout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _computeLayout() {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (final n in widget.nodes) {
      minX = math.min(minX, n.position.dx);
      minY = math.min(minY, n.position.dy);
      maxX = math.max(maxX, n.position.dx);
      maxY = math.max(maxY, n.position.dy);
    }
    final origin = Offset(minX - _padding, minY - _topPadding);

    final positions = <String, Offset>{
      for (final n in widget.nodes) n.id: n.position - origin,
    };
    final cx =
        positions.values.map((p) => p.dx).reduce((a, b) => a + b) /
        positions.length;
    positions[kJohnsonVirtualNodeId] = Offset(cx, _virtualNodeY);

    setState(() {
      _positions = positions;
      _labels = {for (final n in widget.nodes) n.id: n.label};
      _canvasSize = Size(
        maxX - minX + _padding * 2,
        maxY - minY + _topPadding + _padding,
      );
    });
  }

  JohnsonStep get _currentStep => _result!.steps[_stepIndex];
  bool get _isFirst => _stepIndex == 0;
  bool get _isLast => _stepIndex == _result!.steps.length - 1;

  void _goTo(int index) {
    setState(() {
      _stepIndex = index.clamp(0, _result!.steps.length - 1);
    });
    if (_isLast) _stopPlaying();
  }

  void _next() => _goTo(_stepIndex + 1);
  void _prev() => _goTo(_stepIndex - 1);

  void _togglePlay() {
    if (_playing) {
      _stopPlaying();
      return;
    }
    if (_isLast) _goTo(0);
    setState(() => _playing = true);
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
      if (_isLast) {
        _stopPlaying();
        return;
      }
      _next();
    });
  }

  void _stopPlaying() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Algoritmo de Johnson'),
        actions: _error != null || _result == null
            ? null
            : [
                IconButton(
                  tooltip: 'Ver todos los pasos',
                  icon: const Icon(Icons.list_alt),
                  onPressed: _showStepsList,
                ),
                IconButton(
                  tooltip: 'Ir al resultado final',
                  icon: const Icon(Icons.table_chart),
                  onPressed: _result!.hasNegativeCycle
                      ? null
                      : () {
                          _stopPlaying();
                          _goTo(_result!.steps.length - 1);
                        },
                ),
              ],
      ),
      body: _error != null
          ? _buildError(_error!)
          : Column(
              children: [
                Expanded(child: _buildCanvasArea()),
                _buildLegend(),
                _buildStepPanel(),
                _buildControls(),
                if (_currentStep.phase == JohnsonPhase.done) _buildMatrix(),
              ],
            ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return InteractiveViewer(
      minScale: 0.4,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(200),
      child: SizedBox(
        width: _canvasSize.width,
        height: _canvasSize.height,
        child: Stack(
          children: [
            JohnsonAnimatedCanvas(
              canvasSize: _canvasSize,
              positions: _positions,
              labels: _labels,
              edges: widget.edges,
              step: _currentStep,
            ),
            ..._buildBadges(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBadges() {
    final widgets = <Widget>[];
    final step = _currentStep;

    for (final entry in _positions.entries) {
      if (entry.key == kJohnsonVirtualNodeId) continue;
      final pos = entry.value;

      final h = step.potentials[entry.key];
      if (h != null) {
        widgets.add(
          Positioned(
            left: pos.dx - 24,
            top: pos.dy - 50,
            width: 48,
            child: Center(
              child: JohnsonValueBadge(
                value: h,
                color: JohnsonPalette.neonAmber,
                prefix: 'h=',
              ),
            ),
          ),
        );
      }

      final d = step.distances[entry.key];
      if (d != null) {
        final isSettled = step.settledNodeIds.contains(entry.key);
        widgets.add(
          Positioned(
            left: pos.dx - 24,
            top: pos.dy + 32,
            width: 48,
            child: Center(
              child: JohnsonValueBadge(
                value: d,
                color: isSettled
                    ? JohnsonPalette.neonGreen
                    : JohnsonPalette.neonCyan,
                prefix: 'd=',
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildLegend() {
    Widget dot(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        children: [
          dot(JohnsonPalette.neonAmber, 'q y repesaje'),
          dot(JohnsonPalette.neonCyan, 'explorando (Dijkstra)'),
          dot(JohnsonPalette.neonGreen, 'nodo sellado / resultado'),
          dot(JohnsonPalette.neonRed, 'ciclo negativo'),
        ],
      ),
    );
  }

  void _showStepsList() {
    _stopPlaying();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Todos los pasos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _result!.steps.length,
                    itemBuilder: (context, index) {
                      final step = _result!.steps[index];
                      final color = _phaseColor(step.phase);
                      final isCurrent = index == _stepIndex;
                      return ListTile(
                        selected: isCurrent,
                        selectedTileColor: color.withOpacity(0.12),
                        leading: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          '${index + 1}. ${step.title}',
                          style: TextStyle(
                            color: isCurrent ? color : Colors.white,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          step.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          _goTo(index);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStepPanel() {
    final step = _currentStep;
    final color = _phaseColor(step.phase);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_stepIndex + 1}/${_result!.steps.length}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _phaseColor(JohnsonPhase phase) {
    switch (phase) {
      case JohnsonPhase.negativeCycle:
        return JohnsonPalette.neonRed;
      case JohnsonPhase.setup:
      case JohnsonPhase.reweight:
        return JohnsonPalette.neonAmber;
      case JohnsonPhase.bellmanFord:
      case JohnsonPhase.dijkstra:
        return JohnsonPalette.neonCyan;
      case JohnsonPhase.removeVirtualNode:
      case JohnsonPhase.done:
        return JohnsonPalette.neonGreen;
    }
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _isFirst ? null : _prev,
            icon: const Icon(Icons.skip_previous),
            color: Colors.white,
          ),
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle),
            color: JohnsonPalette.neonCyan,
            iconSize: 34,
          ),
          IconButton(
            onPressed: _isLast ? null : _next,
            icon: const Icon(Icons.skip_next),
            color: Colors.white,
          ),
          Expanded(
            child: Slider(
              value: _stepIndex.toDouble(),
              min: 0,
              max: (_result!.steps.length - 1).toDouble(),
              activeColor: JohnsonPalette.neonCyan,
              inactiveColor: Colors.white24,
              onChanged: (v) {
                _stopPlaying();
                _goTo(v.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrix() {
    final ids = widget.nodes.map((n) => n.id).toList();
    final distances = _result!.distances;

    String fmt(double v) {
      if (v == double.infinity) return '∞';
      return v == v.roundToDouble()
          ? v.toInt().toString()
          : v.toStringAsFixed(1);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matriz de distancias más cortas',
            style: TextStyle(
              color: JohnsonPalette.neonGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFF0F172A),
              ),
              columns: [
                const DataColumn(
                  label: Text('u \\ v', style: TextStyle(color: Colors.white38)),
                ),
                for (final id in ids)
                  DataColumn(
                    label: Text(
                      _labels[id] ?? id,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
              rows: [
                for (final u in ids)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          _labels[u] ?? u,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (final v in ids)
                        DataCell(
                          Text(
                            fmt(distances[u]?[v] ?? double.infinity),
                            style: TextStyle(
                              color: u == v
                                  ? Colors.white24
                                  : JohnsonPalette.neonGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
