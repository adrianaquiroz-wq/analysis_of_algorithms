import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Explica en palabras lo que está pasando: pasada, salto y movimiento.
class GapBanner extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final int? gap;
  final int passIndex;
  final int passTotal;
  final String? note;

  const GapBanner({
    super.key,
    required this.palette,
    required this.state,
    required this.gap,
    required this.passIndex,
    required this.passTotal,
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
        'Pulsa "Empezar ordenamiento": Shell Sort compara números separados '
        'por un salto h, y lo va reduciendo hasta llegar a 1.',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip('Pasada $passIndex de $passTotal'),
            _chip('Salto h = ${gap ?? '-'}'),
          ],
        ),
        const SizedBox(height: 8),
        if (note != null) _text(note!, strong: true),
        const SizedBox(height: 4),
        Text(
          'Los puntos de un mismo color forman una sublista: sus elementos '
          'están separados h posiciones y se ordenan entre sí por inserción.',
          style: TextStyle(color: palette.mutedText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: palette.accent.withValues(alpha: 0.18),
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
