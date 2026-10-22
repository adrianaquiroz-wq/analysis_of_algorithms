import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/widgets/duck_art.dart';
import 'package:graph_app/theme/theme_controller.dart';

/// Dibujo de la tarjeta: tres patitos de distintos tamaños sobre el agua.
class MergeSortPreview extends StatelessWidget {
  const MergeSortPreview({super.key});

  static const List<int> _values = [3, 6, 4];

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
                width: 28.0 + v * 4,
                height: 30.0 + v * 4,
                child: CustomPaint(
                  painter: DuckPreviewPainter(value: v, isDark: isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
