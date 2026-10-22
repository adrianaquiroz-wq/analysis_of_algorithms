import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/logic/insertion_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Banner pedagógico para Insertion Sort: explica la pasada actual,
/// la frontera entre elementos ordenados y no ordenados, y la acción en tiempo real.
class InsertionBanner extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final int activePass;
  final int totalPasses;
  final int sortedUpTo;
  final int comparisons;
  final int shifts;
  final String? note;

  const InsertionBanner({
    super.key,
    required this.palette,
    required this.state,
    required this.activePass,
    required this.totalPasses,
    required this.sortedUpTo,
    required this.comparisons,
    required this.shifts,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
      ),
      child: _content(),
    );
  }

  Widget _content() {
    if (state == PlayState.idle) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: palette.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pulsa "Empezar ordenamiento": El panda clave se elevará y se comparará '
              'hacia la izquierda, desplazando a los mayores para insertarse en su lugar correcto.',
              style: TextStyle(color: palette.subtleText, fontSize: 13.5, height: 1.35),
            ),
          ),
        ],
      );
    }

    if (state == PlayState.done) {
      return Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note ?? '¡Todos los pandas han quedado ordenados!',
                  style: TextStyle(
                    color: palette.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: $comparisons comparaciones y $shifts desplazamientos.',
                  style: TextStyle(color: palette.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip('Pasada $activePass de $totalPasses', palette.accent),
            _chip('Ordenados: ${sortedUpTo + 1}', const Color(0xFF22C55E)),
            _chip('$comparisons comparaciones', Colors.amberAccent.shade700),
            _chip('$shifts desplazamientos', Colors.cyan),
          ],
        ),
        const SizedBox(height: 10),
        if (note != null)
          Text(
            note!,
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
}

