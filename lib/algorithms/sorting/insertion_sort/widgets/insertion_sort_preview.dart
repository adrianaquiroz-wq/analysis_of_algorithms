import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/panda_painter.dart';

/// Vista previa para la tarjeta del carrusel en Home:
/// Ositos panda tiernos y gorditos, uno de ellos buscando su lugar con su brote de bambú.
class InsertionSortPreview extends StatelessWidget {
  const InsertionSortPreview({super.key});

  static const List<int> _values = [15, 48, 22, 65];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _values.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 44, // Más ancho para que luzcan gorditos
                height: 52 + _values[i] * 1.05 + (i == 2 ? 18 : 0),
                child: CustomPaint(
                  painter: PandaPainter(
                    value: _values[i],
                    isLifted: i == 2,
                    isSorted: i < 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
