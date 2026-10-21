import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Ascendente / Descendente (misma idea que Minimizar / Maximizar).
class DirectionToggle extends StatelessWidget {
  final AppPalette palette;
  final bool descending;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const DirectionToggle({
    super.key,
    required this.palette,
    required this.descending,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: [!descending, descending],
        onPressed: enabled ? (index) => onChanged(index == 1) : null,
        constraints: const BoxConstraints(minHeight: 34, minWidth: 0),
        color: palette.text,
        selectedColor: palette.accent,
        fillColor: palette.accent.withValues(alpha: 0.15),
        textStyle: const TextStyle(fontSize: 12),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Ascendente'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Descendente'),
          ),
        ],
      ),
    );
  }
}
