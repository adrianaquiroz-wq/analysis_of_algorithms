import 'dart:math';

import 'package:flutter/material.dart';

/// Corchete que une los dos pingüinos que se comparan y dice cuántas
/// posiciones los separan (el salto h).
class GapBracketPainter extends CustomPainter {
  final double x1;
  final double x2;
  final String label;
  final Color color;

  const GapBracketPainter({
    required this.x1,
    required this.x2,
    required this.label,
    required this.color,
  });

  static const double _lineY = 24;
  static const double _tick = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final left = min(x1, x2);
    final right = max(x1, x2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(left, _lineY + _tick)
        ..lineTo(left, _lineY)
        ..lineTo(right, _lineY)
        ..lineTo(right, _lineY + _tick),
      paint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((left + right) / 2 - tp.width / 2, _lineY - tp.height - 3),
    );
  }

  @override
  bool shouldRepaint(GapBracketPainter old) =>
      old.x1 != x1 || old.x2 != x2 || old.label != label || old.color != color;
}
