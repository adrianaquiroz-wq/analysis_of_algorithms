import 'dart:math';

import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';

// Cálculo de distancia a un segmento de recta
double distanceToSegment(Offset p, Offset p1, Offset p2) {
  final l2 =
      (p2.dx - p1.dx) * (p2.dx - p1.dx) + (p2.dy - p1.dy) * (p2.dy - p1.dy);
  if (l2 == 0) return (p - p1).distance;

  var t =
      ((p.dx - p1.dx) * (p2.dx - p1.dx) + (p.dy - p1.dy) * (p2.dy - p1.dy)) /
      l2;
  t = t.clamp(0.0, 1.0);

  final projection = Offset(
    p1.dx + t * (p2.dx - p1.dx),
    p1.dy + t * (p2.dy - p1.dy),
  );
  return (p - projection).distance;
}

// Encontrar la arista más cercana al hacer clic (soporta bucles, rectas y curvas bidireccionales)
String? findClosestEdgeId({
  required Offset tapPosition,
  required List<EdgeModel> edges,
  required List<NodeModel> nodes,
}) {
  String? bestEdgeId;
  double minDistance = 20.0;

  for (final edge in edges) {
    final source = nodes.firstWhere(
      (n) => n.id == edge.sourceId,
      orElse: () => nodes.first,
    );
    final target = nodes.firstWhere(
      (n) => n.id == edge.targetId,
      orElse: () => nodes.first,
    );

    double distance;

    if (edge.sourceId == edge.targetId) {
      final center = source.position;
      final angles = <double>[];
      for (final e in edges) {
        if (e.sourceId == e.targetId) continue;
        String? otherId;
        if (e.sourceId == source.id) {
          otherId = e.targetId;
        } else if (e.targetId == source.id) {
          otherId = e.sourceId;
        } else {
          continue;
        }
        final other = nodes.firstWhere(
          (n) => n.id == otherId,
          orElse: () => source,
        );
        if (other.id == source.id) continue;
        angles.add(
          atan2(other.position.dy - center.dy, other.position.dx - center.dx),
        );
      }

      double loopAngle = -pi / 2;
      if (angles.isNotEmpty) {
        angles.sort();
        double maxGap = -1;
        for (int i = 0; i < angles.length; i++) {
          final a1 = angles[i];
          final a2 = i + 1 < angles.length ? angles[i + 1] : angles[0] + 2 * pi;
          final gap = a2 - a1;
          if (gap > maxGap) {
            maxGap = gap;
            loopAngle = a1 + gap / 2;
          }
        }
        while (loopAngle > pi) {
          loopAngle -= 2 * pi;
        }
        while (loopAngle < -pi) {
          loopAngle += 2 * pi;
        }
      }

      final rotation = loopAngle + pi / 2;
      Offset rotatePoint(Offset base) {
        final cosA = cos(rotation);
        final sinA = sin(rotation);
        final vec = base - center;
        return center +
            Offset(
              vec.dx * cosA - vec.dy * sinA,
              vec.dx * sinA + vec.dy * cosA,
            );
      }

      final start = rotatePoint(Offset(center.dx + 12, center.dy - 25 - 2));
      final end = rotatePoint(Offset(center.dx, center.dy - 25));
      final control1 = rotatePoint(Offset(center.dx + 65, center.dy - 25 - 65));
      final control2 = rotatePoint(Offset(center.dx - 25, center.dy - 25 - 65));

      distance = double.infinity;
      for (double t = 0; t <= 1; t += 0.05) {
        final bezierPoint = Offset(
          pow(1 - t, 3) * start.dx +
              3 * pow(1 - t, 2) * t * control1.dx +
              3 * (1 - t) * pow(t, 2) * control2.dx +
              pow(t, 3) * end.dx,
          pow(1 - t, 3) * start.dy +
              3 * pow(1 - t, 2) * t * control1.dy +
              3 * (1 - t) * pow(t, 2) * control2.dy +
              pow(t, 3) * end.dy,
        );
        final d = (tapPosition - bezierPoint).distance;
        if (d < distance) distance = d;
      }
    } else {
      final bool hasReverse = edges.any(
        (e) => e.sourceId == edge.targetId && e.targetId == edge.sourceId,
      );

      if (hasReverse) {
        const double curveBulge = 45.0;
        // Orden canónico fijo entre el par de nodos, igual que en el painter.
        final isSourceCanonicalLow = edge.sourceId.compareTo(edge.targetId) < 0;
        final bulge = isSourceCanonicalLow ? curveBulge : -curveBulge;

        final p1 = source.position;
        final p2 = target.position;
        final low = isSourceCanonicalLow ? p1 : p2;
        final high = isSourceCanonicalLow ? p2 : p1;

        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        final angle = atan2(high.dy - low.dy, high.dx - low.dx);
        final perpAngle = angle + pi / 2;
        final control =
            mid + Offset(bulge * cos(perpAngle), bulge * sin(perpAngle));

        final startAngle = atan2(control.dy - p1.dy, control.dx - p1.dx);
        final start = Offset(
          p1.dx + 25.0 * cos(startAngle),
          p1.dy + 25.0 * sin(startAngle),
        );
        final endAngle = atan2(control.dy - p2.dy, control.dx - p2.dx);
        final end = Offset(
          p2.dx + 25.0 * cos(endAngle),
          p2.dy + 25.0 * sin(endAngle),
        );

        distance = double.infinity;
        for (double t = 0; t <= 1; t += 0.05) {
          final bezierPoint = Offset(
            pow(1 - t, 2) * start.dx +
                2 * (1 - t) * t * control.dx +
                pow(t, 2) * end.dx,
            pow(1 - t, 2) * start.dy +
                2 * (1 - t) * t * control.dy +
                pow(t, 2) * end.dy,
          );
          final d = (tapPosition - bezierPoint).distance;
          if (d < distance) distance = d;
        }
      } else {
        distance = distanceToSegment(
          tapPosition,
          source.position,
          target.position,
        );
      }
    }

    if (distance < minDistance) {
      minDistance = distance;
      bestEdgeId = edge.id;
    }
  }
  return bestEdgeId;
}

// Cálculo del punto medio de la arista (para posicionar el botón de borrado)
Offset calculateEdgeMidpoint({
  required EdgeModel edge,
  required List<NodeModel> nodes,
  required List<EdgeModel> allEdges,
}) {
  final source = nodes.firstWhere(
    (n) => n.id == edge.sourceId,
    orElse: () => nodes.first,
  );
  final target = nodes.firstWhere(
    (n) => n.id == edge.targetId,
    orElse: () => nodes.first,
  );

  if (edge.sourceId == edge.targetId) {
    final center = source.position;
    final angles = <double>[];
    for (final e in allEdges) {
      if (e.sourceId == e.targetId) continue;
      String? otherId;
      if (e.sourceId == source.id) {
        otherId = e.targetId;
      } else if (e.targetId == source.id) {
        otherId = e.sourceId;
      } else {
        continue;
      }
      final other = nodes.firstWhere(
        (n) => n.id == otherId,
        orElse: () => source,
      );
      if (other.id == source.id) continue;
      angles.add(
        atan2(other.position.dy - center.dy, other.position.dx - center.dx),
      );
    }

    double loopAngle = -pi / 2;
    if (angles.isNotEmpty) {
      angles.sort();
      double maxGap = -1;
      for (int i = 0; i < angles.length; i++) {
        final a1 = angles[i];
        final a2 = i + 1 < angles.length ? angles[i + 1] : angles[0] + 2 * pi;
        final gap = a2 - a1;
        if (gap > maxGap) {
          maxGap = gap;
          loopAngle = a1 + gap / 2;
        }
      }
      while (loopAngle > pi) {
        loopAngle -= 2 * pi;
      }
      while (loopAngle < -pi) {
        loopAngle += 2 * pi;
      }
    }

    final rotation = loopAngle + pi / 2;
    Offset rotatePoint(Offset base) {
      final cosA = cos(rotation);
      final sinA = sin(rotation);
      final vec = base - center;
      return center +
          Offset(vec.dx * cosA - vec.dy * sinA, vec.dx * sinA + vec.dy * cosA);
    }

    final start = rotatePoint(Offset(center.dx + 12, center.dy - 25 - 2));
    final end = rotatePoint(Offset(center.dx, center.dy - 25));
    final control1 = rotatePoint(Offset(center.dx + 65, center.dy - 25 - 65));
    final control2 = rotatePoint(Offset(center.dx - 25, center.dy - 25 - 65));

    const t = 0.5;
    return Offset(
      pow(1 - t, 3) * start.dx +
          3 * pow(1 - t, 2) * t * control1.dx +
          3 * (1 - t) * pow(t, 2) * control2.dx +
          pow(t, 3) * end.dx,
      pow(1 - t, 3) * start.dy +
          3 * pow(1 - t, 2) * t * control1.dy +
          3 * (1 - t) * pow(t, 2) * control2.dy +
          pow(t, 3) * end.dy,
    );
  }

  final bool hasReverse = allEdges.any(
    (e) => e.sourceId == edge.targetId && e.targetId == edge.sourceId,
  );

  if (hasReverse) {
    const double curveBulge = 45.0;
    // Orden canónico fijo entre el par de nodos, igual que en el painter.
    final isSourceCanonicalLow = edge.sourceId.compareTo(edge.targetId) < 0;
    final bulge = isSourceCanonicalLow ? curveBulge : -curveBulge;

    final p1 = source.position;
    final p2 = target.position;
    final low = isSourceCanonicalLow ? p1 : p2;
    final high = isSourceCanonicalLow ? p2 : p1;
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

    final angle = atan2(high.dy - low.dy, high.dx - low.dx);
    final perpAngle = angle + pi / 2;
    final control =
        mid + Offset(bulge * cos(perpAngle), bulge * sin(perpAngle));

    final startAngle = atan2(control.dy - p1.dy, control.dx - p1.dx);
    final start = Offset(
      p1.dx + 25.0 * cos(startAngle),
      p1.dy + 25.0 * sin(startAngle),
    );

    final endAngle = atan2(control.dy - p2.dy, control.dx - p2.dx);
    final end = Offset(
      p2.dx + 25.0 * cos(endAngle),
      p2.dy + 25.0 * sin(endAngle),
    );

    return Offset(
      0.25 * start.dx + 0.5 * control.dx + 0.25 * end.dx,
      0.25 * start.dy + 0.5 * control.dy + 0.25 * end.dy,
    );
  }

  return Offset(
    (source.position.dx + target.position.dx) / 2,
    (source.position.dy + target.position.dy) / 2,
  );
}
