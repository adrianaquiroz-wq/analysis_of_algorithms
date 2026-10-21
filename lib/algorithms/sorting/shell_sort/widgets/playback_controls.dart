import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Botón principal (empezar / pausar / continuar), reiniciar y velocidad.
class PlaybackControls extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final double speed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final ValueChanged<double> onSpeed;

  const PlaybackControls({
    super.key,
    required this.palette,
    required this.state,
    required this.speed,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSpeed,
  });

  static const List<double> speeds = [0.25, 0.5, 1, 2, 4];

  @override
  Widget build(BuildContext context) {
    final (label, icon, action) = switch (state) {
      PlayState.idle => ('Empezar ordenamiento', Icons.play_arrow, onStart),
      PlayState.playing => ('Pausar', Icons.pause, onPause),
      PlayState.paused => ('Continuar', Icons.play_arrow, onResume),
      PlayState.done => ('Ordenar de nuevo', Icons.replay, onStart),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: action,
                icon: Icon(icon),
                label: Text(label),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: state == PlayState.idle ? null : onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reiniciar'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Velocidad',
          style: TextStyle(color: palette.subtleText, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final s in speeds)
              ChoiceChip(
                label: Text(
                  s == s.roundToDouble() ? '${s.toInt()}x' : '${s}x',
                  style: TextStyle(color: palette.text),
                ),
                selected: speed == s,
                selectedColor: palette.accent.withValues(alpha: 0.25),
                backgroundColor: palette.card,
                onSelected: (_) => onSpeed(s),
              ),
          ],
        ),
      ],
    );
  }
}
