import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/selection_sort/widgets/frog_art.dart';
import 'package:graph_app/theme/theme_controller.dart';

/// Dibujo de la tarjeta: tres ranas de distintos tamaños.
class SelectionSortPreview extends StatelessWidget {
  const SelectionSortPreview({super.key});

  static const List<int> _values = [3, 1, 2];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.instance.isDark;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in _values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                width: 30.0 + v * 6,
                height: 30.0 + v * 6,
                child: CustomPaint(
                  painter: FrogPreviewPainter(value: '$v', isDark: isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
