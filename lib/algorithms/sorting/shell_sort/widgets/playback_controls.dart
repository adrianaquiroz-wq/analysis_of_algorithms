import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Botón principal (empezar / pausar / continuar), paso a paso, reiniciar y velocidad.
class PlaybackControls extends StatelessWidget {
  final AppPalette palette;
  final PlayState state;
  final double speed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final ValueChanged<double> onSpeed;
  final VoidCallback? onStepNext;

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
    this.onStepNext,
  });

  static const List<double> speeds = [0.25, 0.5, 1, 2, 4];

  @override
  Widget build(BuildContext context) {
    final (label, icon, action) = switch (state) {
      PlayState.idle => ('Empezar', Icons.play_arrow_rounded, onStart),
      PlayState.playing => ('Pausar', Icons.pause_rounded, onPause),
      PlayState.paused => ('Continuar', Icons.play_arrow_rounded, onResume),
      PlayState.done => ('Repetir', Icons.replay_rounded, onStart),
    };

    final canStep = onStepNext != null &&
        state != PlayState.playing &&
        state != PlayState.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: ElevatedButton.icon(
                onPressed: action,
                icon: Icon(icon),
                label: Text(label),
              ),
            ),
            if (onStepNext != null) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: canStep ? onStepNext : null,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Paso'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: canStep ? palette.accent : palette.mutedText,
                ),
              ),
            ],
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: state == PlayState.idle ? null : onReset,
              icon: const Icon(Icons.restart_alt_rounded),
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
