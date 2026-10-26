import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_traversal_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Escenario: el árbol dibujado con cocos y el mono encima del nodo actual.
class TreeStage extends StatelessWidget {
  final AppPalette palette;
  final TreeTraversalController controller;

  const TreeStage({super.key, required this.palette, required this.controller});

  static const double colW = 58;
  static const double rowH = 78;
  static const double topY = 62;
  static const double nodeR = 20;
  static const double monkeySize = 44;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final tree = c.tree;
    final dark = palette.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF14261F) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: tree.root == null
          ? SizedBox(
              height: 170,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: monkeySize,
                      height: monkeySize,
                      child: const CustomPaint(painter: MonkeyPainter()),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El árbol está vacío.\nAgrega un número para empezar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.subtleText),
                    ),
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, box) {
                final layout = tree.layout();
                final n = layout.length;
                final contentW = (n - 1) * colW;
                final width = max(box.maxWidth, contentW + 2 * 36);
                final left = (width - contentW) / 2;
                final height = topY + (tree.height - 1) * rowH + nodeR + 26;

                final positions = <int, Offset>{
                  for (final e in layout.entries)
                    e.key: Offset(
                      left + e.value.col * colW,
                      topY + e.value.row * rowH,
                    ),
                };
                final monkeyPos =
                    c.monkeyNode == null ? null : positions[c.monkeyNode!];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TreePainter(
                              root: tree.root!,
                              positions: positions,
                              visited: c.output,
                              pathEdges: c.pathEdges,
                              current: c.monkeyNode,
                              isDark: dark,
                            ),
                          ),
                        ),
                        if (monkeyPos != null)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            left: monkeyPos.dx - monkeySize / 2,
                            top: monkeyPos.dy - nodeR - monkeySize + 12,
                            width: monkeySize,
                            height: monkeySize,
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: MonkeyPainter(
                                  cheer: c.lastKind == StepKind.visit,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final TreeNode root;
  final Map<int, Offset> positions;
  final List<int> visited;
  final Set<String> pathEdges;
  final int? current;
  final bool isDark;

  _TreePainter({
    required this.root,
    required this.positions,
    required this.visited,
    required this.pathEdges,
    required this.current,
    required this.isDark,
  });

  static const Color banana = Color(0xFFFFB300);
  static const Color coconut = Color(0xFF8D6E63);
  static const Color leaf = Color(0xFF43A047);

  @override
  void paint(Canvas canvas, Size size) {
    // Aristas (ramas).
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void edges(TreeNode? n) {
      if (n == null) return;
      for (final ch in [n.left, n.right]) {
        if (ch == null) continue;
        final active = pathEdges.contains(edgeKey(n.value, ch.value));
        edge
          ..color = active
              ? banana
              : (isDark ? Colors.white24 : const Color(0xFF6D4C41))
          ..strokeWidth = active ? 4.5 : 2.5;
        canvas.drawLine(positions[n.value]!, positions[ch.value]!, edge);
        edges(ch);
      }
    }

    edges(root);

    // Nodos (cocos).
    for (final e in positions.entries) {
      final v = e.key;
      final pos = e.value;
      final order = visited.indexOf(v);
      final isVisited = order >= 0;
      final isCurrent = v == current;

      final fill = isCurrent ? leaf : (isVisited ? banana : coconut);
      canvas.drawCircle(pos, TreeStage.nodeR, Paint()..color = fill);
      canvas.drawCircle(
        pos,
        TreeStage.nodeR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCurrent ? 3 : 1.5
          ..color = isCurrent ? Colors.white : Colors.black26,
      );
      _text(
        canvas,
        '$v',
        pos,
        TextStyle(
          color: isVisited && !isCurrent ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: v > 99 ? 13 : 15,
        ),
      );

      if (isVisited) {
        final badge = pos + const Offset(15, 15);
        canvas.drawCircle(badge, 9, Paint()..color = const Color(0xFF3E2723));
        _text(
          canvas,
          '${order + 1}',
          badge,
          const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
  }

  void _text(Canvas canvas, String s, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => true;
}

/// El mono. Si [cheer] es true abre la boca (acaba de visitar un nodo).
class MonkeyPainter extends CustomPainter {
  final bool cheer;
  const MonkeyPainter({this.cheer = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 44, size.height / 44);

    final fur = Paint()..color = const Color(0xFF8D5A2B);
    final skin = Paint()..color = const Color(0xFFF3D2A2);
    final black = Paint()..color = Colors.black87;

    for (final x in [6.0, 38.0]) {
      canvas.drawCircle(Offset(x, 22), 7, fur);
      canvas.drawCircle(Offset(x, 22), 4, skin);
    }
    canvas.drawCircle(const Offset(22, 20), 16, fur);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(22, 25), width: 24, height: 19),
      skin,
    );

    // Ojos con brillo.
    for (final x in [16.5, 27.5]) {
      canvas.drawCircle(Offset(x, 20), 2.3, black);
      canvas.drawCircle(Offset(x + 0.7, 19.3), 0.8, Paint()..color = Colors.white);
    }
    // Nariz.
    canvas.drawCircle(const Offset(20.5, 25), 0.9, black);
    canvas.drawCircle(const Offset(23.5, 25), 0.9, black);

    // Boca.
    if (cheer) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(22, 28.5), width: 11, height: 9),
        0,
        pi,
        true,
        Paint()..color = const Color(0xFFC62828),
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(22, 27.5), width: 10, height: 6),
        0.25,
        pi - 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..color = Colors.black87,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MonkeyPainter old) => old.cheer != cheer;
}