import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Explica en palabras lo que está pasando: pasada, comparación y salto.
class SelectionBanner extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final int pass;
  final int passTotal;
  final int comparisons;
  final int swaps;
  final bool descending;
  final String? note;

  const SelectionBanner({
    super.key,
    required this.palette,
    required this.state,
    required this.pass,
    required this.passTotal,
    required this.comparisons,
    required this.swaps,
    required this.descending,
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
    final word = descending ? 'mayor' : 'menor';

    if (state == PlayState.idle) {
      return _text(
        'Pulsa "Empezar": el búho juez recorre la fila buscando a la rana '
        '$word. Cuando la encuentra, esa rana salta al primer puesto sin '
        'ordenar y se intercambia con la que estaba ahí.',
      );
    }
    if (state == PlayState.done) {
      return Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(child: _text(note ?? 'Fila ordenada.', strong: true)),
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
            _chip('Pasada $pass de $passTotal', highlight: true),
            _chip('Comparaciones: $comparisons'),
            _chip('Saltos: $swaps'),
          ],
        ),
        const SizedBox(height: 8),
        if (note != null) _text(note!, strong: true),
        const SizedBox(height: 4),
        Text(
          'Verde: candidata a $word · Ámbar: la que mira el búho · '
          'Dorado: ya está en su puesto.',
          style: TextStyle(color: palette.mutedText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _chip(String label, {bool highlight = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: palette.accent.withValues(alpha: highlight ? 0.28 : 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: palette.accent,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );

  Widget _text(String t, {bool strong = false}) => Text(
    t,
    style: TextStyle(
      color: strong ? palette.text : palette.subtleText,
      fontSize: 14,
      fontWeight: strong ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
