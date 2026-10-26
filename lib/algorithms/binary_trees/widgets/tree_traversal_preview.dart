import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/binary_trees/widgets/tree_stage.dart';

/// Dibujo de la tarjeta: un mini árbol con un mono sobre la raíz.
class TreeTraversalPreview extends StatelessWidget {
  const TreeTraversalPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 120,
        height: 72,
        child: CustomPaint(painter: _MiniTreePainter()),
      ),
    );
  }
}

class _MiniTreePainter extends CustomPainter {
  const _MiniTreePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const root = Offset(60, 36);
    const l = Offset(28, 62);
    const r = Offset(92, 62);
    final line = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5;
    canvas.drawLine(root, l, line);
    canvas.drawLine(root, r, line);
    for (final p in [root, l, r]) {
      canvas.drawCircle(p, 8, Paint()..color = const Color(0xFF8D6E63));
    }
    canvas.save();
    canvas.translate(root.dx - 14, root.dy - 8 - 28 + 5);
    canvas.scale(28 / 44);
    const MonkeyPainter().paint(canvas, const Size(44, 44));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}