import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../models/node_model.dart';
import '../../../../models/edge_model.dart';
import 'logic/johnson_algorithm.dart';
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
  static const double _topPadding = 90;
  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);

  JohnsonMode _mode = JohnsonMode.max;
  String? _originId;
  String? _destId;
  JohnsonResult? _result;
  bool _showRoute = true;
  String? _error;

  Map<String, Offset> _positions = {};
  Map<String, String> _labels = {};
  Size _canvasSize = const Size(400, 300);

  Color get _accent => _mode == JohnsonMode.max
      ? JohnsonPalette.neonRed
      : JohnsonPalette.neonGreen;

  @override
  void initState() {
    super.initState();
    if (widget.nodes.length < 2 || widget.edges.isEmpty) {
      _error =
          'Necesitás al menos 2 nodos conectados por aristas para calcular '
          'Johnson. Volvé al editor y completá tu grafo.';
      return;
    }
    _setDefaults();
    _computeLayout();
  }

  void _setDefaults() {
    final ids = widget.nodes.map((n) => n.id).toList();
    final hasIn = {for (final e in widget.edges) e.targetId};
    final hasOut = {for (final e in widget.edges) e.sourceId};
    final origin = ids.firstWhere((id) => !hasIn.contains(id),
        orElse: () => ids.first);
    final dest = ids.lastWhere(
      (id) => !hasOut.contains(id) && id != origin,
      orElse: () => ids.firstWhere((id) => id != origin),
    );
    _originId = origin;
    _destId = dest;
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

    _positions = {for (final n in widget.nodes) n.id: n.position - origin};
    _labels = {for (final n in widget.nodes) n.id: n.label};
    _canvasSize = Size(
      math.max(maxX - minX + _padding * 2, 300),
      math.max(maxY - minY + _topPadding + _padding, 240),
    );
  }

  String _nm(String id) {
    final l = _labels[id];
    return (l == null || l.trim().isEmpty) ? id : l;
  }

  void _calculate() {
    if (_originId == null || _destId == null) return;
    final res = JohnsonAlgorithm.solve(
      nodes: widget.nodes,
      edges: widget.edges,
      originId: _originId!,
      destId: _destId!,
      mode: _mode,
    );
    setState(() {
      _result = res;
      _showRoute = true;
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _showRoute = true;
      _mode = JohnsonMode.max;
      _setDefaults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('Algoritmo de Johnson'),
      ),
      body: _error != null
          ? _buildError(_error!)
          : Column(
              children: [
                Expanded(flex: 5, child: _buildCanvasArea()),
                Expanded(flex: 6, child: _buildPanel()),
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
      minScale: 0.5,
      maxScale: 4,
      scaleFactor: 600,
      boundaryMargin: const EdgeInsets.all(120),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _canvasSize.width,
            height: _canvasSize.height,
            child: CustomPaint(
              size: _canvasSize,
              painter: JohnsonGraphPainter(
                positions: _positions,
                labels: _labels,
                edges: widget.edges,
                result: _result,
                showRoute: _showRoute,
                accent: _accent,
                originId: _originId,
                destId: _destId,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Panel inferior: selección + resultado
  // ---------------------------------------------------------------------
  Widget _buildPanel() {
    final res = _result;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF111C33),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona origen y destino',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _modeToggle(),
            const SizedBox(height: 12),
            _dropdown('Nodo de inicio', _originId, (v) {
              setState(() {
                _originId = v;
                _result = null;
              });
            }),
            const SizedBox(height: 10),
            _dropdown('Nodo de destino', _destId, (v) {
              setState(() {
                _destId = v;
                _result = null;
              });
            }),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _calculate,
                child: const Text(
                  'Calcular ruta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            if (res != null) ...[
              const SizedBox(height: 16),
              res.ok ? _buildResultCard(res) : _buildFailureCard(res),
              const SizedBox(height: 12),
              _buildActions(res),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeToggle() {
    Widget btn(JohnsonMode m, String text, IconData icon, Color color) {
      final sel = _mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _mode = m;
            _result = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: sel ? color.withValues(alpha: 0.18) : _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel ? color : Colors.white12,
                width: sel ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: sel ? color : Colors.white54),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: sel ? color : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn(JohnsonMode.max, 'Máximo', Icons.trending_up,
            JohnsonPalette.neonRed),
        const SizedBox(width: 10),
        btn(JohnsonMode.min, 'Mínimo', Icons.trending_down,
            JohnsonPalette.neonGreen),
      ],
    );
  }

  Widget _dropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: _card,
              iconEnabledColor: Colors.white54,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: [
                for (final n in widget.nodes)
                  DropdownMenuItem(value: n.id, child: Text(_nm(n.id))),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultCard(JohnsonResult res) {
    final accent = _accent;
    final isMax = res.mode == JohnsonMode.max;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              isMax ? 'Camino máximo' : 'Camino mínimo',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          _sectionLabel('Ruta encontrada'),
          Text(
            res.routeNodeIds.map(_nm).join(' → '),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          _sectionLabel('Peso total'),
          Text(
            JohnsonAlgorithm.fmt(res.total),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          _sectionLabel('Desglose'),
          Text(
            res.breakdown,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          _sectionLabel('¿Por qué este camino?'),
          for (final r in res.reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: accent, fontSize: 13)),
                  Expanded(
                    child: Text(
                      r,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'En el grafo: cada nodo muestra temprano | tardío, y cada arista '
            'peso (holgura). Holgura 0 = la arista está en el camino.',
            style: TextStyle(color: Colors.white38, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard(JohnsonResult res) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JohnsonPalette.neonAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: JohnsonPalette.neonAmber.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: JohnsonPalette.neonAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              res.error ?? 'No se pudo calcular la ruta.',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(JohnsonResult res) {
    return Row(
      children: [
        if (res.ok)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => setState(() => _showRoute = !_showRoute),
              child: Text(_showRoute ? 'Ocultar ruta' : 'Mostrar ruta'),
            ),
          ),
        if (res.ok) const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF334155),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _reset,
            child: const Text(
              'Nueva configuración',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
