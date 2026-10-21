import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/penguin_painter.dart';

/// Dibujo de la tarjeta: cinco pingüinos de distintos tamaños.
class ShellSortPreview extends StatelessWidget {
  const ShellSortPreview({super.key});

  static const List<int> _values = [2, 5, 3, 6, 4];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in _values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                width: 30,
                height: 36 + v * 14.0,
                child: CustomPaint(
                  painter: PenguinPainter(
                    bodyColor: HSLColor.fromAHSL(
                      1,
                      200 + 150 * v / 6,
                      0.55,
                      0.42,
                    ).toColor(),
                    value: v,
                    highlighted: false,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
