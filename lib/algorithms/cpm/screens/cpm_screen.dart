import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/node_model.dart';
import '../../../models/edge_model.dart';
import '../models/cpm_step.dart';
import '../logic/cpm_algorithm.dart';
import '../widgets/cpm_graph_painter.dart';

class CpmScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;

  const CpmScreen({super.key, required this.nodes, required this.edges});

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

  String _nm(String id) {
    final l = _labels[id];
    return (l == null || l.trim().isEmpty) ? id : l;
  }

  /// Encabezado de cada paso de la tabla (número + título + fórmula).
  Widget _stepHeader(int n, String title, String formula, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASO $n · $title',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  /// Tabla simple con encabezados de color y filas críticas resaltadas.
  Widget _simpleTable({
    required List<String> headers,
    required List<Color> headerColors,
    required List<List<String>> rows,
    required List<bool> critical,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 40,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 52,
          headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
          columns: [
            for (int i = 0; i < headers.length; i++)
              DataColumn(
                label: Text(
                  headers[i],
                  style: TextStyle(
                    color: headerColors[i],
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
          ],
          rows: [
            for (int r = 0; r < rows.length; r++)
              DataRow(
                color: WidgetStateProperty.all(
                  critical[r]
                      ? CpmPalette.neonGreen.withOpacity(0.12)
                      : Colors.transparent,
                ),
                cells: [
                  for (int c = 0; c < rows[r].length; c++)
                    DataCell(
                      Text(
                        rows[r][c],
                        style: TextStyle(
                          color: critical[r]
                              ? CpmPalette.neonGreen
                              : Colors.white,
                          fontWeight: c == 0 ? FontWeight.bold : null,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Sección 2: tabla CPM explicada paso a paso (ida, vuelta, holgura y
  /// tabla final de actividades).
  Widget _buildActivityTableSection() {
    final r = _result!;
    final es = r.earliestTimes;
    final ls = r.latestTimes;
    final slacks = r.slacks;
    final critNodes = r.criticalNodeIds.toSet();
    const cyan = CpmPalette.neonCyan;
    const amber = CpmPalette.neonAmber;
    const white = Colors.white70;

    // ---- Paso 1: ida (ES de cada evento) ----
    final order = r.topoOrder.isEmpty
        ? widget.nodes.map((n) => n.id).toList()
        : r.topoOrder;
    final esRows = <List<String>>[];
    final esCrit = <bool>[];
    for (final id in order) {
      final preds = widget.edges.where((e) => e.targetId == id).toList();
      String calc;
      if (preds.isEmpty) {
        calc = 'no le llega nada → 0';
      } else {
        final parts = preds
            .map(
              (e) =>
                  '${_nm(e.sourceId)}: ${_fmt(es[e.sourceId] ?? 0)}+${_fmt(e.weight)}'
                  '=${_fmt((es[e.sourceId] ?? 0) + e.weight)}',
            )
            .toList();
        calc = preds.length == 1 ? parts.first : 'máx( ${parts.join(' ; ')} )';
      }
      esRows.add([_nm(id), calc, _fmt(es[id] ?? 0)]);
      esCrit.add(critNodes.contains(id));
    }

    // ---- Paso 2: vuelta (LS de cada evento) ----
    final lsRows = <List<String>>[];
    final lsCrit = <bool>[];
    for (final id in order.reversed) {
      final succs = widget.edges.where((e) => e.sourceId == id).toList();
      String calc;
      if (succs.isEmpty) {
        calc = 'evento final → LS = ES';
      } else {
        final parts = succs
            .map(
              (e) =>
                  '${_nm(e.targetId)}: ${_fmt(ls[e.targetId] ?? 0)}−${_fmt(e.weight)}'
                  '=${_fmt((ls[e.targetId] ?? 0) - e.weight)}',
            )
            .toList();
        calc = succs.length == 1 ? parts.first : 'mín( ${parts.join(' ; ')} )';
      }
      lsRows.add([_nm(id), calc, _fmt(ls[id] ?? 0)]);
      lsCrit.add(critNodes.contains(id));
    }

    // ---- Paso 3: holgura por actividad ----
    final hRows = <List<String>>[];
    final hCrit = <bool>[];
    // ---- Paso 4: tabla final ----
    final finalRows = <List<String>>[];
    for (final e in widget.edges) {
      final d = e.weight;
      final esO = es[e.sourceId] ?? 0.0;
      final lsD = ls[e.targetId] ?? 0.0;
      final h = slacks[e.id] ?? (lsD - esO - d);
      final crit = h.abs() < 1e-9;
      final name = '${_nm(e.sourceId)} → ${_nm(e.targetId)}';
      hRows.add([
        name,
        _fmt(lsD),
        _fmt(esO),
        _fmt(d),
        '${_fmt(lsD)} − ${_fmt(esO)} − ${_fmt(d)} = ${_fmt(h)}',
        crit ? 'SÍ' : 'NO',
      ]);
      hCrit.add(crit);
      finalRows.add([
        name,
        _fmt(d),
        _fmt(esO),
        _fmt(esO + d),
        _fmt(lsD - d),
        _fmt(lsD),
        _fmt(h),
        crit ? 'SÍ' : 'NO',
      ]);
    }

    final critPath = r.criticalNodeIds.map(_nm).join(' → ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  'Duración total: ${_fmt(r.projectDuration)} unidades de tiempo',
                  style: const TextStyle(
                    color: CpmPalette.neonGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruta crítica: $critPath',
                  style: const TextStyle(
                    color: CpmPalette.neonGreen,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Leyenda: ES = inicio más temprano · EF = fin más temprano · '
                  'LS = inicio más tardío · LF = fin más tardío · '
                  'd = duración · H = holgura. Las filas en verde son críticas '
                  '(H = 0).',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          _stepHeader(
            1,
            'IDA (tiempos más tempranos)',
            'Se recorre de izquierda a derecha.\n'
                'ES(evento) = máx de [ES(origen) + duración] de las actividades que le llegan.',
            cyan,
          ),
          _simpleTable(
            headers: const ['Evento', 'Cálculo', 'ES'],
            headerColors: const [white, white, cyan],
            rows: esRows,
            critical: esCrit,
          ),

          _stepHeader(
            2,
            'VUELTA (tiempos más tardíos)',
            'Se recorre de derecha a izquierda, empezando con LS = ES en el final.\n'
                'LS(evento) = mín de [LS(destino) − duración] de las actividades que salen de él.',
            amber,
          ),
          _simpleTable(
            headers: const ['Evento', 'Cálculo', 'LS'],
            headerColors: const [white, white, amber],
            rows: lsRows,
            critical: lsCrit,
          ),

          _stepHeader(
            3,
            'HOLGURA de cada actividad',
            'H = LS(destino) − ES(origen) − duración.\n'
                'Si H = 0 la actividad es crítica (no se puede atrasar).',
            CpmPalette.neonGreen,
          ),
          _simpleTable(
            headers: const [
              'Actividad',
              'LS destino',
              'ES origen',
              'd',
              'Cálculo de H',
              '¿Crítica?',
            ],
            headerColors: const [white, amber, cyan, white, white, white],
            rows: hRows,
            critical: hCrit,
          ),

          _stepHeader(
            4,
            'TABLA FINAL de actividades',
            'EF = ES + d   ·   LF = LS(destino)   ·   LS = LF − d   ·   H = LS − ES.\n'
                'La ruta crítica es la unión de las actividades con H = 0.',
            CpmPalette.neonGreen,
          ),
          _simpleTable(
            headers: const [
              'Actividad',
              'd',
              'ES',
              'EF',
              'LS',
              'LF',
              'H',
              '¿Crítica?',
            ],
            headerColors: const [
              white,
              white,
              cyan,
              cyan,
              amber,
              amber,
              white,
              white,
            ],
            rows: finalRows,
            critical: hCrit,
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CpmPalette.neonGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CpmPalette.neonGreen),
            ),
            child: Text(
              'Ruta crítica: $critPath\n'
              'Duración mínima del proyecto: ${_fmt(r.projectDuration)}',
              style: const TextStyle(
                color: CpmPalette.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
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
          dot(CpmPalette.neonCyan, 'arriba del nodo: ES (ida)'),
          dot(CpmPalette.neonAmber, 'abajo del nodo: LS (vuelta)'),
          dot(Colors.white70, 'd = duración · H = holgura'),
          dot(CpmPalette.neonGreen, 'ruta crítica (H = 0)'),
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
