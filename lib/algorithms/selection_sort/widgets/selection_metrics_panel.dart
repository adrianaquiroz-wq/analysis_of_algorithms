import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_algorithm.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Tiempo, operaciones y complejidad de Selection Sort para ESTE conjunto.
class SelectionMetricsPanel extends StatelessWidget {
  final AppPalette palette;
  final int n;
  final SelectionSortResult? result;

  const SelectionMetricsPanel({
    super.key,
    required this.palette,
    required this.n,
    required this.result,
  });

  static String _formatTime(double micros) {
    if (micros <= 0) return '< 1 µs';
    if (micros < 1000) return '${micros.toStringAsFixed(2)} µs';
    return '${(micros / 1000).toStringAsFixed(3)} ms';
  }

  Widget _row(String label, String value, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(label, style: TextStyle(color: palette.subtleText)),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: strong ? palette.accent : palette.text,
              fontWeight: FontWeight.bold,
              fontSize: strong ? 16 : 14,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = result;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complejidad y tiempo',
            style: TextStyle(
              color: palette.text,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _row('Complejidad (todos los casos)', 'O(n²)', strong: true),
          _row('Espacio extra', 'O(1)'),
          _row('Estable', 'No'),
          _row(
            'Comparaciones siempre, n = $n',
            '${SelectionSortAlgorithm.comparisonsFor(n)}  (n(n−1)/2)',
          ),
          _row('Saltos como máximo', '${n - 1}'),
          Divider(color: palette.divider, height: 20),
          _row(
            'Tiempo de ejecución',
            r == null ? '—' : _formatTime(r.avgMicroseconds),
            strong: true,
          ),
          _row('Comparaciones', r == null ? '—' : '${r.comparisons}'),
          _row('Saltos (intercambios)', r == null ? '—' : '${r.swaps}'),
          const SizedBox(height: 6),
          Text(
            'Selection Sort siempre recorre toda la parte sin ordenar para '
            'encontrar el mínimo, sin importar cómo venga la lista: por eso '
            'hace n(n−1)/2 comparaciones en el mejor y en el peor caso. A '
            'cambio, hace muy pocos intercambios (a lo sumo n−1).\n'
            'Tiempo: promedio de ${SelectionSortAlgorithm.timingRuns} corridas, '
            'sin contar la animación.',
            style: TextStyle(color: palette.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
