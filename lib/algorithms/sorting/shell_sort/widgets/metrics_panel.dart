import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/complexity_estimator.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_algorithm.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Complejidad de ESTE conjunto de números y medidas reales del ordenamiento.
class MetricsPanel extends StatelessWidget {
  final AppPalette palette;
  final int n;
  final ShellSortResult? result;
  final ComplexityEstimate? complexity;

  const MetricsPanel({
    super.key,
    required this.palette,
    required this.n,
    required this.result,
    required this.complexity,
  });

  static String _formatTime(double micros) {
    if (micros <= 0) return '< 1 µs';
    if (micros < 1000) return '${micros.toStringAsFixed(2)} µs';
    return '${(micros / 1000).toStringAsFixed(3)} ms';
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
    final c = complexity;

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
          _row(
            'Complejidad de este conjunto',
            c == null ? '—' : '≈ ${c.label}',
            strong: true,
          ),
          _row(
            'Desorden del conjunto',
            c == null
                ? '—'
                : '${(c.disorder * 100).round()} % de pares invertidos',
          ),
          _row(
            'Frente a la cota teórica',
            c == null
                ? '—'
                : (c.withinBound
                      ? 'Dentro de O(n^(3/2))'
                      : 'Supera O(n^(3/2))'),
            color: c == null
                ? null
                : (c.withinBound ? Colors.greenAccent : Colors.orangeAccent),
          ),
          _row('Peor caso teórico (Knuth)', 'O(n^(3/2))'),
          _row(
            'Saltos usados, n = $n',
            ShellSortAlgorithm.gapsFor(n).join(' → '),
          ),
          Divider(color: palette.divider, height: 20),
          _row(
            'Tiempo de ejecución',
            r == null ? '—' : _formatTime(r.avgMicroseconds),
            strong: true,
          ),
          _row('Comparaciones', r == null ? '—' : '${r.comparisons}'),
          _row('Intercambios', r == null ? '—' : '${r.swapCount}'),
          const SizedBox(height: 6),
          Text(
            'Complejidad: Big O describe el crecimiento al aumentar n, así que '
            'se estima ejecutando Shell Sort con listas de ${ComplexityEstimator.sizes.first} '
            'a ${ComplexityEstimator.sizes.last} elementos con el mismo nivel de '
            'desorden que tu conjunto. Es una estimación empírica.\n'
            'Tiempo: promedio de ${ShellSortAlgorithm.timingRuns} corridas, sin '
            'contar la animación.',
            style: TextStyle(color: palette.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
