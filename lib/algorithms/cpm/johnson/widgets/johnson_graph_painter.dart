import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../models/edge_model.dart';
import '../screens/logic/johnson_algorithm.dart';

/// Paleta "modo oscuro tecnológico" del algoritmo.
class JohnsonPalette {
  static const background = Color(0xFF0F172A);
  static const nodeFill = Color(0xFF1E293B);
  static const nodeBorder = Color(0xFF475569);
  static const edgeIdle = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const neonGreen = Color(0xFF39FF88); // camino mínimo
  static const neonCyan = Color(0xFF22D3EE); // origen / destino elegidos
  static const neonAmber = Color(0xFFFBBF24);
  static const neonRed = Color(0xFFFF4D4D); // camino máximo
}

class _EdgeGeo {
  final Offset start;
  final Offset end;
  final Offset? control;
  final Offset label;
  final Offset dir;

  const _EdgeGeo({
    required this.start,
    required this.end,
    required this.control,
    required this.label,
    required this.dir,
  });
}

/// Dibuja el grafo de Johnson: aristas con peso (y holgura), nodos, la ruta
/// resaltada y las etiquetas [temprano | tardío] debajo de cada nodo.
class JohnsonGraphPainter extends CustomPainter {
  static const double nodeRadius = 24;

  final Map<String, Offset> positions;
  final Map<String, String> labels;
  final List<EdgeModel> edges;
  final JohnsonResult? result;
  final bool showRoute;
  final Color accent;
  final String? originId;
  final String? destId;

  JohnsonGraphPainter({
    required this.positions,
    required this.labels,
    required this.edges,
    required this.result,
    required this.showRoute,
    required this.accent,
    required this.originId,
    required this.destId,
  });

  bool get _active => showRoute && result != null && result!.ok;

  @override
  void paint(Canvas canvas, Size size) {
    final routeEdges = _active ? result!.routeEdgeIds.toSet() : <String>{};
    final routeNodes = _active ? result!.routeNodeIds.toSet() : <String>{};

    // aristas que tienen su opuesta -> se dibujan curvas para no pisarse
    final curvedIds = <String>{
      for (final e in edges)
        if (e.sourceId != e.targetId &&
            edges.any(
              (o) =>
                  o.id != e.id &&
                  o.sourceId == e.targetId &&
                  o.targetId == e.sourceId,
            ))
          e.id,
    };

    final pending = <_PendingLabel>[];

    // 1) aristas que no son de la ruta, 2) aristas de la ruta (encima)
    for (final onRoute in [false, true]) {
      for (final e in edges) {
        if (routeEdges.contains(e.id) != onRoute) continue;
        final color = onRoute ? accent : JohnsonPalette.edgeIdle;

        if (e.sourceId == e.targetId) {
          final label = _drawLoop(canvas, e, color, onRoute);
          if (label != null) pending.add(_PendingLabel(e, label, onRoute));
          continue;
        }

        final geo = _geometry(e, curvedIds.contains(e.id));
        if (geo == null) continue;

        if (onRoute) {
          final glow = Paint()
            ..color = color.withValues(alpha: 0.45)
            ..strokeWidth = 7
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawPath(_edgePath(geo), glow);
        }
        final line = Paint()
          ..color = color
          ..strokeWidth = onRoute ? 3.4 : 1.8
          ..style = PaintingStyle.stroke;
        canvas.drawPath(_edgePath(geo), line);
        _drawArrowHead(canvas, geo.end, geo.dir, color);
        pending.add(_PendingLabel(e, geo.label, onRoute));
      }
    }

    // pesos (y holguras) por encima de las líneas
    for (final p in pending) {
      final e = p.edge;
      String text = JohnsonAlgorithm.fmt(e.weight);
      if (_active && result!.slacks.containsKey(e.id)) {
        text += ' (${JohnsonAlgorithm.fmt(result!.slacks[e.id]!)})';
      }
      _drawTag(
        canvas,
        p.position,
        text,
        textColor: p.onRoute ? accent : Colors.white70,
        borderColor: p.onRoute ? accent : JohnsonPalette.nodeBorder,
        fontSize: 11.5,
      );
    }

    // nodos
    for (final entry in positions.entries) {
      final id = entry.key;
      final c = entry.value;
      final onRoute = routeNodes.contains(id);
      final selected = id == originId || id == destId;

      Color fill = JohnsonPalette.nodeFill;
      Color border = JohnsonPalette.nodeBorder;
      double bw = 2;
      if (onRoute) {
        fill = accent.withValues(alpha: 0.25);
        border = accent;
        bw = 3;
      } else if (selected) {
        border = JohnsonPalette.neonCyan;
        bw = 3;
      }

      canvas.drawCircle(c, nodeRadius, Paint()..color = fill);
      canvas.drawCircle(
        c,
        nodeRadius,
        Paint()
          ..color = border
          ..strokeWidth = bw
          ..style = PaintingStyle.stroke,
      );
      _drawText(canvas, c, labels[id] ?? id, Colors.white, 14, true);

      // etiqueta [temprano | tardío]
      if (_active && result!.earliest.containsKey(id)) {
        final t = JohnsonAlgorithm.fmt(result!.earliest[id]!);
        final l = JohnsonAlgorithm.fmt(result!.latest[id]!);
        _drawTag(
          canvas,
          c + const Offset(0, nodeRadius + 15),
          '$t | $l',
          textColor: onRoute ? accent : Colors.white70,
          borderColor: onRoute ? accent : Colors.white38,
          fontSize: 12,
        );
      }
    }
  }

  // ------------------------------------------------------------------
  // Geometría
  // ------------------------------------------------------------------
  _EdgeGeo? _geometry(EdgeModel e, bool curved) {
    final from = positions[e.sourceId];
    final to = positions[e.targetId];
    if (from == null || to == null) return null;
    final d = to - from;
    final dist = d.distance;
    if (dist < 1) return null;
    final unit = d / dist;

    if (!curved) {
      final start = from + unit * nodeRadius;
      final end = to - unit * nodeRadius;
      return _EdgeGeo(
        start: start,
        end: end,
        control: null,
        label: (start + end) / 2,
        dir: unit,
      );
    }

    final perp = Offset(-unit.dy, unit.dx);
    final ctrl = (from + to) / 2 + perp * 34;
    final t0 = ctrl - from;
    final t1 = to - ctrl;
    final u0 = t0 / t0.distance;
    final u1 = t1 / t1.distance;
    final start = from + u0 * nodeRadius;
    final end = to - u1 * nodeRadius;
    return _EdgeGeo(
      start: start,
      end: end,
      control: ctrl,
      label: start * 0.25 + ctrl * 0.5 + end * 0.25,
      dir: u1,
    );
  }

  Path _edgePath(_EdgeGeo g) {
    final path = Path()..moveTo(g.start.dx, g.start.dy);
    if (g.control == null) {
      path.lineTo(g.end.dx, g.end.dy);
    } else {
      path.quadraticBezierTo(
        g.control!.dx,
        g.control!.dy,
        g.end.dx,
        g.end.dy,
      );
    }
    return path;
  }

  Offset? _drawLoop(Canvas canvas, EdgeModel e, Color color, bool onRoute) {
    final p = positions[e.sourceId];
    if (p == null) return null;
    final c = p + const Offset(0, -(nodeRadius + 12));
    canvas.drawCircle(
      c,
      15,
      Paint()
        ..color = color
        ..strokeWidth = onRoute ? 3 : 1.8
        ..style = PaintingStyle.stroke,
    );
    return c + const Offset(0, -24);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset dir, Color color) {
    const size = 10.0;
    final angle = math.atan2(dir.dy, dir.dx);
    final p1 =
        tip -
        Offset(
          math.cos(angle - math.pi / 7) * size,
          math.sin(angle - math.pi / 7) * size,
        );
    final p2 =
        tip -
        Offset(
          math.cos(angle + math.pi / 7) * size,
          math.sin(angle + math.pi / 7) * size,
        );
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // ------------------------------------------------------------------
  // Texto
  // ------------------------------------------------------------------
  void _drawText(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double fontSize,
    bool bold,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawTag(
    Canvas canvas,
    Offset center,
    String text, {
    required Color textColor,
    required Color borderColor,
    double fontSize = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 12,
        height: tp.height + 6,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, Paint()..color = JohnsonPalette.background);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant JohnsonGraphPainter oldDelegate) => true;
}

class _PendingLabel {
  final EdgeModel edge;
  final Offset position;
  final bool onRoute;

  const _PendingLabel(this.edge, this.position, this.onRoute);
}
