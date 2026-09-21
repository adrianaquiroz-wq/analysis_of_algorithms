import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  const GridPainter();

  static const double _spacing = 40.0;
  static const double _dotRadius = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);

    for (double x = 0; x < size.width; x += _spacing) {
      for (double y = 0; y < size.height; y += _spacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => false;
}
