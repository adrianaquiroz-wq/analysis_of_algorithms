import 'dart:math';

import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/node_model.dart';

class EdgePainter extends CustomPainter {
  final List<EdgeModel> edges;
  final List<NodeModel> nodes;
  final String? selectedEdgeId;
  final bool isDarkMode;

  EdgePainter({
    required this.edges,
    required this.nodes,
    this.selectedEdgeId,
    this.isDarkMode = true,
  });

  static const double _nodeRadius = 25.0;
  static const double _curveBulge = 45.0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);

    final nodeMap = {for (var node in nodes) node.id: node};

    for (var edge in edges) {
      final sourceNode = nodeMap[edge.sourceId];
      final targetNode = nodeMap[edge.targetId];

      if (sourceNode == null || targetNode == null) continue;

      final isSelected = selectedEdgeId == edge.id;
      final paint = Paint()
        ..color = isSelected ? Colors.cyanAccent : edge.color
        ..strokeWidth = isSelected ? 4.0 : 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final p1 = Offset(sourceNode.position.dx, sourceNode.position.dy);
      final p2 = Offset(targetNode.position.dx, targetNode.position.dy);

      if (edge.sourceId == edge.targetId) {
        _paintSelfLoop(canvas, edge, sourceNode, nodeMap, paint);
      } else {
        final hasOppositeEdge = edges.any(
          (e) => e.sourceId == edge.targetId && e.targetId == edge.sourceId,
        );

        if (hasOppositeEdge) {
          // Orden canónico fijo entre el par de nodos, independiente de
          // cuál sea source/target de ESTA arista en particular.
          final isSourceCanonicalLow =
              edge.sourceId.compareTo(edge.targetId) < 0;
          _paintCurvedEdge(
            canvas,
            edge,
            p1,
            p2,
            paint,
            sourceIsCanonicalLow: isSourceCanonicalLow,
          );
        } else {
          _paintStraightEdge(canvas, edge, p1, p2, paint);
        }
      }
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = isDarkMode ? Colors.white10 : Colors.black12
      ..strokeWidth = 1;

    const double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }
  }

  void _paintSelfLoop(
    Canvas canvas,
    EdgeModel edge,
    NodeModel node,
    Map<String, NodeModel> nodeMap,
    Paint paint,
  ) {
    final center = node.position;
    final loopAngle = _findFreeLoopAngle(node, nodeMap);
    final rotation = loopAngle + pi / 2;

    Offset rotatePoint(Offset base) =>
        center + _rotateOffset(base - center, rotation);

    final start = rotatePoint(
      Offset(center.dx + 12, center.dy - _nodeRadius - 2),
    );
    final end = rotatePoint(Offset(center.dx, center.dy - _nodeRadius));
    final control1 = rotatePoint(
      Offset(center.dx + 65, center.dy - _nodeRadius - 65),
    );
    final control2 = rotatePoint(
      Offset(center.dx - 25, center.dy - _nodeRadius - 65),
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);

    if (edge.type == EdgeType.directed) {
      final arrowFrom = rotatePoint(
        Offset(center.dx - 8, center.dy - _nodeRadius - 12),
      );
      _drawArrowHead(canvas, arrowFrom, end, paint);
    }

    final labelPos = rotatePoint(
      Offset(center.dx + 20, center.dy - _nodeRadius - 52),
    );
    _drawWeightLabel(canvas, labelPos, edge.weight);
  }

  double _findFreeLoopAngle(NodeModel node, Map<String, NodeModel> nodeMap) {
    final angles = <double>[];

    for (final e in edges) {
      if (e.sourceId == e.targetId) continue;

      String? otherId;
      if (e.sourceId == node.id) {
        otherId = e.targetId;
      } else if (e.targetId == node.id) {
        otherId = e.sourceId;
      } else {
        continue;
      }

      final other = nodeMap[otherId];
      if (other == null) continue;

      angles.add(
        atan2(
          other.position.dy - node.position.dy,
          other.position.dx - node.position.dx,
        ),
      );
    }

    if (angles.isEmpty) return -pi / 2;

    angles.sort();
    double bestAngle = -pi / 2;
    double maxGap = -1;

    for (int i = 0; i < angles.length; i++) {
      final a1 = angles[i];
      final a2 = i + 1 < angles.length ? angles[i + 1] : angles[0] + 2 * pi;
      final gap = a2 - a1;
      if (gap > maxGap) {
        maxGap = gap;
        bestAngle = a1 + gap / 2;
      }
    }

    while (bestAngle > pi) {
      bestAngle -= 2 * pi;
    }
    while (bestAngle < -pi) {
      bestAngle += 2 * pi;
    }
    return bestAngle;
  }

  Offset _rotateOffset(Offset vector, double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    return Offset(
      vector.dx * cosA - vector.dy * sinA,
      vector.dx * sinA + vector.dy * cosA,
    );
  }

  void _paintStraightEdge(
    Canvas canvas,
    EdgeModel edge,
    Offset p1,
    Offset p2,
    Paint paint,
  ) {
    final points = _getAdjustedPoints(p1, p2, _nodeRadius);
    final start = points[0];
    final end = points[1];

    canvas.drawLine(start, end, paint);

    if (edge.type == EdgeType.directed) {
      _drawArrowHead(canvas, start, end, paint);
    }

    _drawWeightLabel(
      canvas,
      Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
      edge.weight,
    );
  }

  void _paintCurvedEdge(
    Canvas canvas,
    EdgeModel edge,
    Offset p1,
    Offset p2,
    Paint paint, {
    required bool sourceIsCanonicalLow,
  }) {
    // El bulge (lado de la curva) depende únicamente de si ESTA arista va
    // en el sentido "canónico" o el opuesto, no de p1/p2 directamente.
    final bulge = sourceIsCanonicalLow ? _curveBulge : -_curveBulge;

    // "low"/"high" son fijos para el par de nodos (A,B), sin importar
    // cuál de los dos sea source/target de esta arista puntual. Esto
    // asegura que el eje perpendicular sea el mismo para ambas aristas
    // del par, y sólo el signo del bulge las separe.
    final low = sourceIsCanonicalLow ? p1 : p2;
    final high = sourceIsCanonicalLow ? p2 : p1;

    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    final control = mid + _perpendicularOffset(low, high, bulge);

    final startAngle = atan2(control.dy - p1.dy, control.dx - p1.dx);
    final start = Offset(
      p1.dx + _nodeRadius * cos(startAngle),
      p1.dy + _nodeRadius * sin(startAngle),
    );

    final endAngle = atan2(control.dy - p2.dy, control.dx - p2.dx);
    final end = Offset(
      p2.dx + _nodeRadius * cos(endAngle),
      p2.dy + _nodeRadius * sin(endAngle),
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    if (edge.type == EdgeType.directed) {
      final tangent = Offset(
        2 * (1 - 0.98) * (control.dx - start.dx) +
            2 * 0.98 * (end.dx - control.dx),
        2 * (1 - 0.98) * (control.dy - start.dy) +
            2 * 0.98 * (end.dy - control.dy),
      );
      _drawArrowHeadCustom(canvas, end, tangent, paint);
    }

    final curveMidpoint = Offset(
      0.25 * start.dx + 0.5 * control.dx + 0.25 * end.dx,
      0.25 * start.dy + 0.5 * control.dy + 0.25 * end.dy,
    );
    _drawWeightLabel(canvas, curveMidpoint, edge.weight);
  }

  Offset _perpendicularOffset(Offset p1, Offset p2, double distance) {
    final angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    final perpAngle = angle + pi / 2;
    return Offset(distance * cos(perpAngle), distance * sin(perpAngle));
  }

  List<Offset> _getAdjustedPoints(Offset p1, Offset p2, double radius) {
    final angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    final newStart = Offset(
      p1.dx + radius * cos(angle),
      p1.dy + radius * sin(angle),
    );
    final newEnd = Offset(
      p2.dx - radius * cos(angle),
      p2.dy - radius * sin(angle),
    );
    return [newStart, newEnd];
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowSize = 12.0;
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);

    final path = Path();
    path.moveTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * cos(angle - pi / 6),
      to.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      to.dx - arrowSize * cos(angle + pi / 6),
      to.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, arrowPaint);
  }

  void _drawArrowHeadCustom(
    Canvas canvas,
    Offset tip,
    Offset tangent,
    Paint paint,
  ) {
    const arrowSize = 12.0;
    final angle = atan2(tangent.dy, tangent.dx);

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * cos(angle - pi / 6),
      tip.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      tip.dx - arrowSize * cos(angle + pi / 6),
      tip.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, arrowPaint);
  }

  void _drawWeightLabel(Canvas canvas, Offset position, double weight) {
    final label = weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toStringAsFixed(1);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          backgroundColor: backgroundColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant EdgePainter oldDelegate) {
    return oldDelegate.edges != edges ||
        oldDelegate.nodes != nodes ||
        oldDelegate.selectedEdgeId != selectedEdgeId ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
