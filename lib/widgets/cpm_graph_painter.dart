import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/cpm_step.dart';

/// Paleta "modo oscuro tecnológico" para CPM.
class CpmPalette {
  static const background = Color(0xFF0F172A);
  static const nodeFill = Color(0xFF1E293B);
  static const nodeBorder = Color(0xFF475569);
  static const edgeIdle = Color(0xFF334155);
  static const textMuted = Color(0xFF94A3B8);
  static const neonGreen = Color(0xFF39FF88); // ruta crítica
  static const neonCyan = Color(0xFF22D3EE); // recorrido hacia adelante (ES)
  static const neonAmber = Color(0xFFFBBF24); // recorrido hacia atrás (LS)
  static const neonRed = Color(0xFFFF4D4D); // ciclo / error
}

/// Canvas animado de un paso de CPM: corre el "pulso" que anima el ripple
/// de los nodos activos y el destello viajero sobre la arista activa /
/// crítica.
class CpmAnimatedCanvas extends StatefulWidget {
  final Size canvasSize;
  final Map<String, Offset> positions;
  final Map<String, String> labels;
  final List<EdgeModel> edges;
  final CpmStep step;

  const CpmAnimatedCanvas({
    super.key,
    required this.canvasSize,
    required this.positions,
    required this.labels,
    required this.edges,
    required this.step,
  });

  @override
  State<CpmAnimatedCanvas> createState() => _CpmAnimatedCanvasState();
}

class _CpmAnimatedCanvasState extends State<CpmAnimatedCanvas>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CpmAnimatedCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _pulse
        ..stop()
        ..value = 0
        ..repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return CustomPaint(
          size: widget.canvasSize,
          painter: CpmGraphPainter(
            positions: widget.positions,
            labels: widget.labels,
            edges: widget.edges,
            step: widget.step,
            pulseValue: _pulse.value,
          ),
        );
      },
    );
  }
}

class CpmGraphPainter extends CustomPainter {
  static const double nodeRadius = 26;

  final Map<String, Offset> positions;
  final Map<String, String> labels;
  final List<EdgeModel> edges;
  final CpmStep step;
  final double pulseValue; // 0..1, en loop continuo

  CpmGraphPainter({
    required this.positions,
    required this.labels,
    required this.edges,
    required this.step,
    required this.pulseValue,
  });

  Color get _activeColor {
    switch (step.phase) {
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

  @override
  void paint(Canvas canvas, Size size) {
    _drawBaseEdges(canvas);
    _drawCriticalEdges(canvas);
    _drawActiveEdge(canvas);
    _drawNodes(canvas);
    _drawRipples(canvas);
  }

  // ---------------------------------------------------------------------
  // Aristas base (grises, delgadas)
  // ---------------------------------------------------------------------
  void _drawBaseEdges(Canvas canvas) {
    final paint = Paint()
      ..color = CpmPalette.edgeIdle
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final e in edges) {
      final from = positions[e.sourceId];
      final to = positions[e.targetId];
      if (from == null || to == null) continue;
      if (e.id == step.activeEdgeId) continue;
      if (step.criticalEdgeIds.contains(e.id)) continue;
      _drawArrow(canvas, from, to, paint, CpmPalette.textMuted);
    }
  }

  /// Ruta crítica: se dibuja siempre con glow verde persistente, no solo
  /// mientras se calcula.
  void _drawCriticalEdges(Canvas canvas) {
    if (step.criticalEdgeIds.isEmpty) return;
    for (final id in step.criticalEdgeIds) {
      if (id == step.activeEdgeId) continue; // esa se dibuja aparte, encima
      final edge = edges
          .where((e) => e.id == id)
          .cast<EdgeModel?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (edge == null) continue;
      final from = positions[edge.sourceId];
      final to = positions[edge.targetId];
      if (from == null || to == null) continue;

      final glowPaint = Paint()
        ..color = CpmPalette.neonGreen.withOpacity(0.45)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      _drawArrow(canvas, from, to, glowPaint, CpmPalette.neonGreen, drawHead: false);

      final corePaint = Paint()
        ..color = CpmPalette.neonGreen
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      _drawArrow(canvas, from, to, corePaint, CpmPalette.neonGreen);
    }
  }

  /// Efecto "trazo líquido": la arista activa se dibuja con glow y un
  /// destello (comet) que viaja de un extremo al otro.
  void _drawActiveEdge(Canvas canvas) {
    final id = step.activeEdgeId;
    if (id == null) return;
    final edge = edges.where((e) => e.id == id).cast<EdgeModel?>().firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
    if (edge == null) return;
    final from = positions[edge.sourceId];
    final to = positions[edge.targetId];
    if (from == null || to == null) return;

    final isCritical = step.criticalEdgeIds.contains(id);
    final color = isCritical ? CpmPalette.neonGreen : _activeColor;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.55)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    _drawArrow(canvas, from, to, glowPaint, color, drawHead: false);

    final corePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    _drawArrow(canvas, from, to, corePaint, color);

    // Destello viajero (comet) a lo largo de la arista.
    final t = Curves.easeInOut.transform(
      (math.sin(pulseValue * 2 * math.pi) + 1) / 2,
    );
    final cometCenter = Offset.lerp(from, to, t)!;
    final cometGlow = Paint()
      ..color = color.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(cometCenter, 7, cometGlow);
    canvas.drawCircle(cometCenter, 3, Paint()..color = Colors.white);
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    Color headColor, {
    bool drawHead = true,
  }) {
    final direction = (to - from);
    final distance = direction.distance;
    if (distance == 0) return;
    final unit = direction / distance;
    final start = from + unit * nodeRadius;
    final end = to - unit * nodeRadius;

    canvas.drawLine(start, end, paint);

    if (drawHead) {
      const arrowSize = 9.0;
      final angle = math.atan2(unit.dy, unit.dx);
      final p1 =
          end -
          Offset(
            math.cos(angle - math.pi / 7) * arrowSize,
            math.sin(angle - math.pi / 7) * arrowSize,
          );
      final p2 =
          end -
          Offset(
            math.cos(angle + math.pi / 7) * arrowSize,
            math.sin(angle + math.pi / 7) * arrowSize,
          );
      final path = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = headColor);
    }
  }

  // ---------------------------------------------------------------------
  // Nodos (eventos)
  // ---------------------------------------------------------------------
  void _drawNodes(Canvas canvas) {
    for (final entry in positions.entries) {
      final id = entry.key;
      final center = entry.value;
      final isCritical = step.criticalNodeIds.contains(id);
      final isActive = step.activeNodeIds.contains(id);

      Color fill = CpmPalette.nodeFill;
      Color border = CpmPalette.nodeBorder;

      if (isCritical) {
        fill = CpmPalette.neonGreen.withOpacity(0.22);
        border = CpmPalette.neonGreen;
      }
      if (isActive && !isCritical) {
        border = _activeColor;
      }

      canvas.drawCircle(
        center,
        nodeRadius,
        Paint()..color = fill..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        nodeRadius,
        Paint()
          ..color = border
          ..strokeWidth = isCritical ? 3 : 2
          ..style = PaintingStyle.stroke,
      );

      // Línea vertical divisoria clásica del diagrama de eventos CPM.
      canvas.drawLine(
        center + const Offset(0, -nodeRadius + 3),
        center + const Offset(0, nodeRadius - 3),
        Paint()
          ..color = border.withOpacity(0.5)
          ..strokeWidth = 1,
      );

      _drawLabel(
        canvas,
        center + const Offset(-8, 0),
        labels[id] ?? id,
        Colors.white,
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    String text,
    Color color, {
    double fontSize = 13,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  // ---------------------------------------------------------------------
  // Efecto "onda expansiva" sobre los nodos activos
  // ---------------------------------------------------------------------
  void _drawRipples(Canvas canvas) {
    final color = _activeColor;
    final t = Curves.easeOut.transform(pulseValue);
    final ids = {...step.activeNodeIds};

    for (final id in ids) {
      final center = positions[id];
      if (center == null) continue;
      final radius = nodeRadius + t * 34;
      final opacity = (1 - t).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withOpacity(opacity * 0.8)
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke,
      );
      final radius2 = nodeRadius + ((t + 0.4) % 1.0) * 34;
      final opacity2 = (1 - ((t + 0.4) % 1.0)).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius2,
        Paint()
          ..color = color.withOpacity(opacity2 * 0.5)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CpmGraphPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.positions != positions;
  }
}

/// Insignia numérica animada (ES, LS u holgura) que se posiciona sobre un
/// nodo o arista. Cuando el valor cambia, anima "número viejo -> número
/// nuevo" con un pequeño achique + rebote elástico, simulando un contador.
class CpmValueBadge extends StatelessWidget {
  final double value;
  final Color color;
  final String prefix;

  const CpmValueBadge({
    super.key,
    required this.value,
    required this.color,
    this.prefix = '',
  });

  String _fmt(double v) {
    if (v == double.infinity) return '∞';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$prefix-${_fmt(value)}'),
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: CpmPalette.background.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Text(
          '$prefix${_fmt(value)}',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
