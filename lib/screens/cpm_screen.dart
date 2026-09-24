import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../models/cpm_step.dart';
import '../utils/cpm_algorithm.dart';
import '../widgets/cpm_graph_painter.dart';

class CpmScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final bool isDarkMode;

  const CpmScreen({
    super.key,
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
  });

  @override
  State<CpmScreen> createState() => _CpmScreenState();
}

class _CpmScreenState extends State<CpmScreen> {
  static const double _padding = 90;
  static const double _topPadding = 90;

  CpmResult? _result;
  int _stepIndex = 0;
  Timer? _timer;
  bool _playing = false;
  String? _error;

  // Controlador para alternar entre Lienzo Animado (Página 0) y Tabla de Actividades (Página 1)
  late final PageController _pageController;
  int _currentPage = 0;

  Map<String, Offset> _positions = {};
  Map<String, String> _labels = {};
  Size _canvasSize = const Size(400, 300);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.nodes.length < 2 || widget.edges.isEmpty) {
      _error =
          'Necesitás al menos 2 nodos (eventos) conectados por actividades '
          'para calcular la ruta crítica (CPM). Volvé al editor y completá '
          'tu red.';
      return;
    }
    _result = CpmAlgorithm.solve(nodes: widget.nodes, edges: widget.edges);
    if (_result!.hasCycle) {
      _error =
          'La red tiene un ciclo entre actividades. CPM solo funciona '
          'sobre una red de proyecto sin ciclos (DAG). Corregí el grafo e '
          'intentá de nuevo.';
    }
    _computeLayout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
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

    setState(() {
      _positions = positions;
      _labels = {for (final n in widget.nodes) n.id: n.label};
      _canvasSize = Size(
        maxX - minX + _padding * 2,
        maxY - minY + _topPadding + _padding,
      );
    });
  }

  CpmStep get _currentStep => _result!.steps[_stepIndex];
  bool get _isFirst => _stepIndex == 0;
  bool get _isLast => _stepIndex == _result!.steps.length - 1;

  void _goTo(int index) {
    setState(() {
      _stepIndex = index.clamp(0, _result!.steps.length - 1);
    });

    // Si llega al último paso, detiene la reproducción y conmuta automáticamente a la Tabla de Actividades
    if (_isLast) {
      _stopPlaying();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _currentPage == 0) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
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

  String _fmt(double v) {
    if (v == double.infinity) return '∞';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Método CPM (Ruta Crítica)'),
        actions: _error != null || _result == null
            ? null
            : [
                IconButton(
                  tooltip: _currentPage == 0
                      ? 'Ver Tabla de Actividades'
                      : 'Ver Grafo Animado',
                  icon: Icon(_currentPage == 0 ? Icons.table_chart : Icons.hub),
                  onPressed: () {
                    final targetPage = _currentPage == 0 ? 1 : 0;
                    _pageController.animateToPage(
                      targetPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Ver todos los pasos',
                  icon: const Icon(Icons.list_alt),
                  onPressed: _showStepsList,
                ),
                IconButton(
                  tooltip: 'Ir al resultado final',
                  icon: const Icon(Icons.flag),
                  onPressed: () {
                    _stopPlaying();
                    _goTo(_result!.steps.length - 1);
                  },
                ),
              ],
      ),
      body: _error != null
          ? _buildError(_error!)
          : PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                // PÁGINA 1: Grafo / Red Animada Paso a Paso
                _buildAnimatedGraphSection(),

                // PÁGINA 2: Tabla Completa de Actividades CPM
                _buildActivityTableSection(),
              ],
            ),
    );
  }

  /// Sección 1: Lienzo Animado y Controles Paso a Paso
  Widget _buildAnimatedGraphSection() {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildCanvasArea()),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                _buildLegend(),
                _buildStepPanel(),
                _buildControls(),
                if (_isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CpmPalette.neonGreen,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Ver Tabla de Actividades Completa'),
                      onPressed: () {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sección 2: Tabla Completa de Actividades, Tiempos, Holguras y Ruta Crítica
  /// Sección 2: Tabla Completa de Actividades, Tiempos, Holguras y Ruta Crítica
  Widget _buildActivityTableSection() {
    final esMap = _result!.earliestTimes;
    final lsMap = _result!.latestTimes;
    final slacksMap = _result!.slacks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CpmPalette.neonGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.analytics,
                      color: CpmPalette.neonGreen,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Resumen del Proyecto CPM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Duración Total: ${_fmt(_result!.projectDuration)} unidades de tiempo',
                  style: const TextStyle(
                    color: CpmPalette.neonGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Las actividades destacadas en verde tienen Holgura = 0 y conforman la Ruta Crítica.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabla interactiva de actividades
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF0F172A),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Actividad',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Duración (d)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ES',
                      style: TextStyle(
                        color: CpmPalette.neonCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'EF',
                      style: TextStyle(
                        color: CpmPalette.neonCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LS',
                      style: TextStyle(
                        color: CpmPalette.neonAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LF',
                      style: TextStyle(
                        color: CpmPalette.neonAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Holgura (H)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '¿Ruta Crítica?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: widget.edges.map((e) {
                  final u = e.sourceId;
                  final v = e.targetId;
                  final duration = e.weight;

                  final esVal = esMap[u] ?? 0.0;
                  final efVal = esVal + duration;
                  final lsVal = (lsMap[v] ?? 0.0) - duration;
                  final lfVal = lsMap[v] ?? 0.0;
                  final slackVal = slacksMap[e.id] ?? (lsVal - esVal);
                  final isCritical = slackVal.abs() < 1e-9;

                  final labelU = _labels[u] ?? u;
                  final labelV = _labels[v] ?? v;

                  // CORRECCIÓN AQUÍ: Se genera el nombre de la actividad usando los nodos
                  final actLabel = '$labelU → $labelV';

                  return DataRow(
                    color: WidgetStateProperty.all(
                      isCritical
                          ? CpmPalette.neonGreen.withOpacity(0.12)
                          : Colors.transparent,
                    ),
                    cells: [
                      DataCell(
                        Text(
                          actLabel,
                          style: TextStyle(
                            color: isCritical
                                ? CpmPalette.neonGreen
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(esVal),
                          style: const TextStyle(color: CpmPalette.neonCyan),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(efVal),
                          style: const TextStyle(color: CpmPalette.neonCyan),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(lsVal),
                          style: const TextStyle(color: CpmPalette.neonAmber),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(lfVal),
                          style: const TextStyle(color: CpmPalette.neonAmber),
                        ),
                      ),
                      DataCell(
                        Text(
                          _fmt(slackVal),
                          style: TextStyle(
                            color: isCritical
                                ? CpmPalette.neonGreen
                                : Colors.white70,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCritical
                                ? CpmPalette.neonGreen
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCritical ? 'SÍ' : 'NO',
                            style: TextStyle(
                              color: isCritical
                                  ? const Color(0xFF0F172A)
                                  : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back, color: Colors.white54),
              label: const Text(
                'Volver al Grafo Animado',
                style: TextStyle(color: Colors.white54),
              ),
              onPressed: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
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
            CpmAnimatedCanvas(
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
      final pos = entry.value;

      final es = step.earliestTimes[entry.key];
      if (es != null) {
        widgets.add(
          Positioned(
            left: pos.dx - 30,
            top: pos.dy - 52,
            width: 60,
            child: Center(
              child: CpmValueBadge(
                value: es,
                color: CpmPalette.neonCyan,
                prefix: 'ES=',
              ),
            ),
          ),
        );
      }

      final ls = step.latestTimes[entry.key];
      if (ls != null) {
        widgets.add(
          Positioned(
            left: pos.dx - 30,
            top: pos.dy + 32,
            width: 60,
            child: Center(
              child: CpmValueBadge(
                value: ls,
                color: CpmPalette.neonAmber,
                prefix: 'LS=',
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
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        children: [
          dot(CpmPalette.neonCyan, 'recorrido hacia adelante (ES)'),
          dot(CpmPalette.neonAmber, 'recorrido hacia atrás (LS)'),
          dot(CpmPalette.neonGreen, 'ruta crítica'),
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

  Color _phaseColor(CpmPhase phase) {
    switch (phase) {
      case CpmPhase.topoOrder:
        return CpmPalette.neonRed;
      case CpmPhase.forwardPass:
        return CpmPalette.neonCyan;
      case CpmPhase.backwardPass:
        return CpmPalette.neonAmber;
      case CpmPhase.slack:
      case CpmPhase.criticalPath:
      case CpmPhase.done:
        return CpmPalette.neonGreen;
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
            color: CpmPalette.neonCyan,
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
              activeColor: CpmPalette.neonCyan,
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
}
