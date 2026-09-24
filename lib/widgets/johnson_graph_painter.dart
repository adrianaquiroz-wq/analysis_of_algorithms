import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/johnson_step.dart';

/// Paleta "modo oscuro tecnológico" pedida para el algoritmo.
class JohnsonPalette {
  static const background = Color(0xFF0F172A);
  static const nodeFill = Color(0xFF1E293B);
  static const nodeBorder = Color(0xFF475569);
  static const edgeIdle = Color(0xFF334155);
  static const textMuted = Color(0xFF94A3B8);
  static const neonGreen = Color(0xFF39FF88); // camino / distancia final
  static const neonCyan = Color(0xFF22D3EE); // exploración Dijkstra
  static const neonAmber = Color(0xFFFBBF24); // repesaje
  static const neonRed = Color(0xFFFF4D4D); // ciclo negativo
}

/// Canvas animado de un paso de Johnson: se encarga de correr el "pulso"
/// (para el ripple y el destello viajero) y de suavizar la aparición /
/// desaparición del nodo virtual q.
class JohnsonAnimatedCanvas extends StatefulWidget {
  final Size canvasSize;
  final Map<String, Offset> positions;
  final Map<String, String> labels;
  final List<EdgeModel> edges;
  final JohnsonStep step;

  const JohnsonAnimatedCanvas({
    super.key,
    required this.canvasSize,
    required this.positions,
    required this.labels,
    required this.edges,
    required this.step,
  });

  @override
  State<JohnsonAnimatedCanvas> createState() => _JohnsonAnimatedCanvasState();
}

class _JohnsonAnimatedCanvasState extends State<JohnsonAnimatedCanvas>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _virtualFade;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _virtualFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: widget.step.virtualNodeVisible ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant JohnsonAnimatedCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _pulse
        ..stop()
        ..value = 0
        ..repeat();
      if (widget.step.virtualNodeVisible) {
        _virtualFade.forward();
      } else {
        _virtualFade.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _virtualFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _virtualFade]),
      builder: (context, _) {
        return CustomPaint(
          size: widget.canvasSize,
          painter: JohnsonGraphPainter(
            positions: widget.positions,
            labels: widget.labels,
            edges: widget.edges,
            step: widget.step,
            pulseValue: _pulse.value,
            virtualNodeOpacity: _virtualFade.value,
          ),
        );
      },
    );
  }
}

class JohnsonGraphPainter extends CustomPainter {
  static const double nodeRadius = 26;

  final Map<String, Offset> positions;
  final Map<String, String> labels;
  final List<EdgeModel> edges;
  final JohnsonStep step;
  final double pulseValue; // 0..1, en loop continuo
  final double virtualNodeOpacity; // 0..1

  JohnsonGraphPainter({
    required this.positions,
    required this.labels,
    required this.edges,
    required this.step,
    required this.pulseValue,
    required this.virtualNodeOpacity,
  });

  Color get _activeColor {
    switch (step.phase) {
      case JohnsonPhase.negativeCycle:
        return JohnsonPalette.neonRed;
      case JohnsonPhase.reweight:
      case JohnsonPhase.setup:
        return JohnsonPalette.neonAmber;
      case JohnsonPhase.dijkstra:
      case JohnsonPhase.bellmanFord:
        return JohnsonPalette.neonCyan;
      case JohnsonPhase.removeVirtualNode:
      case JohnsonPhase.done:
        return JohnsonPalette.neonGreen;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawVirtualSpokes(canvas);
    _drawBaseEdges(canvas);
    _drawActiveEdge(canvas);
    _drawVirtualNode(canvas);
    _drawNodes(canvas);
    _drawRipples(canvas);
  }

  // ---------------------------------------------------------------------
  // Aristas base (grises, delgadas)
  // ---------------------------------------------------------------------
  void _drawBaseEdges(Canvas canvas) {
    final paint = Paint()
      ..color = JohnsonPalette.edgeIdle
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final e in edges) {
      final from = positions[e.sourceId];
      final to = positions[e.targetId];
      if (from == null || to == null) continue;
      if (e.id == step.activeEdgeId) continue; // esa se dibuja aparte, encima
      _drawArrow(canvas, from, to, paint, JohnsonPalette.textMuted);
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

    final color = _activeColor;

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
  // Nodo virtual q y sus aristas temporales (con blur fade)
  // ---------------------------------------------------------------------
  void _drawVirtualSpokes(Canvas canvas) {
    if (virtualNodeOpacity <= 0.01) return;
    final q = positions[kJohnsonVirtualNodeId];
    if (q == null) return;

    final blurSigma = (1 - virtualNodeOpacity) * 8;
    final paint = Paint()
      ..color = JohnsonPalette.neonAmber.withOpacity(0.35 * virtualNodeOpacity)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, blurSigma);

    for (final entry in positions.entries) {
      if (entry.key == kJohnsonVirtualNodeId) continue;
      _drawDashedLine(canvas, q, entry.value, paint, dash: 5, gap: 5);
    }
  }

  void _drawVirtualNode(Canvas canvas) {
    if (virtualNodeOpacity <= 0.01) return;
    final q = positions[kJohnsonVirtualNodeId];
    if (q == null) return;

    final blurSigma = (1 - virtualNodeOpacity) * 10;
    final glow = Paint()
      ..color = JohnsonPalette.neonAmber.withOpacity(0.5 * virtualNodeOpacity)
      ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, 10 + blurSigma);
    canvas.drawCircle(q, nodeRadius * 0.8, glow);

    final fill = Paint()
      ..color = JohnsonPalette.nodeFill.withOpacity(virtualNodeOpacity)
      ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(q, nodeRadius * 0.7, fill);

    final border = Paint()
      ..color = JohnsonPalette.neonAmber.withOpacity(virtualNodeOpacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(q, nodeRadius * 0.7, border);

    _drawLabel(
      canvas,
      q,
      'q',
      JohnsonPalette.neonAmber.withOpacity(virtualNodeOpacity),
      fontSize: 13,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint, {
    double dash = 6,
    double gap = 5,
  }) {
    final total = (to - from).distance;
    if (total == 0) return;
    final unit = (to - from) / total;
    double covered = 0;
    while (covered < total) {
      final segEnd = math.min(covered + dash, total);
      canvas.drawLine(from + unit * covered, from + unit * segEnd, paint);
      covered += dash + gap;
    }
  }

  // ---------------------------------------------------------------------
  // Nodos reales
  // ---------------------------------------------------------------------
  void _drawNodes(Canvas canvas) {
    for (final entry in positions.entries) {
      if (entry.key == kJohnsonVirtualNodeId) continue;
      final id = entry.key;
      final center = entry.value;
      final isSettled = step.settledNodeIds.contains(id);
      final isSource = step.sourceNodeId == id;

      Color fill = JohnsonPalette.nodeFill;
      Color border = JohnsonPalette.nodeBorder;

      if (isSettled) {
        fill = JohnsonPalette.neonGreen.withOpacity(0.22);
        border = JohnsonPalette.neonGreen;
      }
      if (isSource) {
        border = JohnsonPalette.neonCyan;
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
          ..strokeWidth = isSource ? 3 : 2
          ..style = PaintingStyle.stroke,
      );

      _drawLabel(canvas, center, labels[id] ?? id, Colors.white);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    String text,
    Color color, {
    double fontSize = 14,
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
      // Segundo anillo, un poco detrás, para reforzar el efecto "radar".
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
  bool shouldRepaint(covariant JohnsonGraphPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.virtualNodeOpacity != virtualNodeOpacity ||
        oldDelegate.positions != positions;
  }
}

/// Insignia numérica animada (h(v) o distancia) que se posiciona sobre un
/// nodo. Cuando el valor cambia, anima "número viejo -> número nuevo" con
/// un pequeño achique + rebote elástico, simulando un contador.
class JohnsonValueBadge extends StatelessWidget {
  final double value;
  final Color color;
  final String prefix;

  const JohnsonValueBadge({
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
          color: JohnsonPalette.background.withOpacity(0.95),
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
