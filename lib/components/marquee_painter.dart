import 'package:flutter/material.dart';

class MarqueePainter extends CustomPainter {
  final Offset start;
  final Offset current;

  MarqueePainter({required this.start, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, current);
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MarqueePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.current != current;
  }
}
