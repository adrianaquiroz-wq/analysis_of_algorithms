import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/logic/insertion_sort_algorithm.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Panel de métricas y análisis de complejidad para Insertion Sort.
class InsertionMetricsPanel extends StatelessWidget {
  final AppPalette palette;
  final int n;
  final InsertionSortResult? result;

  const InsertionMetricsPanel({
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

  /// Comparaciones en el peor caso: n(n - 1) / 2
  static int worstCaseComparisons(int n) => (n * (n - 1)) ~/ 2;

  /// Comparaciones en el mejor caso: n - 1
  static int bestCaseComparisons(int n) => (n > 1) ? n - 1 : 0;

  Widget _row(
    String label,
    String value, {
    bool strong = false,
    Color? color,
  }) =>
      Padding(
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
    final best = bestCaseComparisons(n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complejidad y Rendimiento',
            style: TextStyle(
              color: palette.text,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _row('Mejor caso (lista ordenada)', 'O(n) [n - 1 comparaciones]', strong: true, color: const Color(0xFF22C55E)),
          _row('Peor y caso promedio', 'O(n²)', strong: true),
          _row('Espacio auxiliar', 'O(1) (In-place)'),
          _row('Estabilidad', 'Sí (mantiene orden relativo)'),
          _row('Cota mín. teórica (n = $n)', '$best comparaciones'),
          _row('Cota máx. teórica (n = $n)', '$worst comparaciones'),
          Divider(color: palette.divider, height: 22),
          _row(
            'Tiempo medido (200 ejecuciones)',
            r == null ? '—' : _formatTime(r.avgMicroseconds),
            strong: true,
          ),
          _row('Comparaciones realizadas', r == null ? '—' : '${r.comparisons}'),
          _row('Desplazamientos realizados', r == null ? '—' : '${r.shifts}'),
          if (r != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  r.comparisons == best
                      ? Icons.star_rounded
                      : (r.comparisons == worst ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
                  color: r.comparisons == best
                      ? const Color(0xFF22C55E)
                      : (r.comparisons == worst ? Colors.orangeAccent : palette.accent),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.comparisons == best
                        ? '¡Conjunto en el mejor caso! Solo tomó $best comparaciones.'
                        : (r.comparisons == worst
                            ? 'Conjunto en el peor caso (inversamente ordenado).'
                            : 'Rendimiento promedio dentro de la cota cuadrática.'),
                    style: TextStyle(
                      color: palette.subtleText,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

