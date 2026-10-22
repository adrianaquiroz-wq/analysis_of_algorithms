import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/logic/merge_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Explica en palabras lo que está pasando: fase, nivel y movimiento.
class MergeBanner extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final MergePhase phase;
  final int depth;
  final int levels;
  final int comparisons;
  final String? note;

  const MergeBanner({
    super.key,
    required this.palette,
    required this.state,
    required this.phase,
    required this.depth,
    required this.levels,
    required this.comparisons,
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
      return _text(
        'Pulsa "Empezar ordenamiento": Merge Sort parte la lista por la mitad '
        'una y otra vez hasta tener patitos solos, y luego los fusiona en '
        'orden.',
      );
    }
    if (state == PlayState.done) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Expanded(child: _text(note ?? 'Lista ordenada.', strong: true)),
        ],
      );
    }

    final dividing = phase == MergePhase.dividing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip(dividing ? 'Dividiendo' : 'Fusionando', highlight: true),
            _chip('Nivel ${depth + 1} de $levels'),
            _chip('Comparaciones: $comparisons'),
          ],
        ),
        const SizedBox(height: 8),
        if (note != null) _text(note!, strong: true),
        const SizedBox(height: 4),
        Text(
          dividing
              ? 'Las corrientes luminosas muestran cómo se parte cada grupo en dos mitades.'
              : 'Se comparan las cabezas de las dos mitades; el que gana nada hacia arriba con un destello.',
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
