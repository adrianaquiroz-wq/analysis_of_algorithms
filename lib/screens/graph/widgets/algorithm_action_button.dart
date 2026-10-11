import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/theme/app_palette.dart';

class AlgorithmActionButton extends StatelessWidget {
  final AlgorithmInfo algorithm;
  final bool isDarkMode;
  final VoidCallback onPressed;

  const AlgorithmActionButton({
    super.key,
    required this.algorithm,
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final solver = algorithm.solver!;

    return FloatingActionButton(
      heroTag: 'solver_${algorithm.id}',
      backgroundColor: palette.fab,
      foregroundColor: palette.accent,
      elevation: isDarkMode ? 4 : 2,
      tooltip: solver.tooltip,
      onPressed: onPressed,
      child: Icon(solver.icon, color: palette.accent),
    );
  }
}
