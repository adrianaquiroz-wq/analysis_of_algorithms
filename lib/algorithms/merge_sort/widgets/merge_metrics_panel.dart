import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/logic/merge_sort_algorithm.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Tiempo, operaciones y complejidad de Merge Sort para ESTE conjunto.
class MergeMetricsPanel extends StatelessWidget {
  final AppPalette palette;
  final int n;
  final MergeSortResult? result;

  const MergeMetricsPanel({
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

  /// Peor caso exacto de comparaciones de Merge Sort:
  /// n·⌈log2 n⌉ − 2^⌈log2 n⌉ + 1.
  static int worstCaseComparisons(int n) {
    final levels = MergeSortAlgorithm.levelsFor(n) - 1; // ⌈log2 n⌉
    return n * levels - (1 << levels) + 1;
  }

  Widget _row(
    String label,
    String value, {
    bool strong = false,
    Color? color,
  }) => Padding(
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
              color: color ?? (strong ? palette.accent : palette.text),
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
    final worst = worstCaseComparisons(n);
    final within = r != null && r.comparisons <= worst;

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
          _row('Complejidad (todos los casos)', 'O(n log n)', strong: true),
          _row('Espacio extra', 'O(n)'),
          _row('Estable', 'Sí (empata la izquierda primero)'),
          _row(
            'Niveles de división, n = $n',
            '${MergeSortAlgorithm.levelsFor(n)}',
          ),
          _row('Cota n·log₂ n', MergeSortAlgorithm.nLogN(n).toStringAsFixed(1)),
          Divider(color: palette.divider, height: 20),
          _row(
            'Tiempo de ejecución',
            r == null ? '—' : _formatTime(r.avgMicroseconds),
            strong: true,
          ),
          _row('Comparaciones', r == null ? '—' : '${r.comparisons}'),
          _row(
            'Peor caso de comparaciones',
            '$worst',
            color: r == null
                ? null
                : (within ? Colors.greenAccent : Colors.orangeAccent),
          ),
          _row('Movimientos de patitos', r == null ? '—' : '${r.moves}'),
          const SizedBox(height: 6),
          Text(
            'Merge Sort siempre divide por la mitad (log₂ n niveles) y en cada '
            'nivel recorre los n elementos, por eso es O(n log n) tanto en el '
            'mejor como en el peor caso. El peor caso exacto de comparaciones '
            'es n·⌈log₂ n⌉ − 2^⌈log₂ n⌉ + 1.\n'
            'Tiempo: promedio de ${MergeSortAlgorithm.timingRuns} corridas, sin '
            'contar la animación.',
            style: TextStyle(color: palette.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
