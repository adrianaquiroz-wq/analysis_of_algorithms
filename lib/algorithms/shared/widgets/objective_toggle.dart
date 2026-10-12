import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class ObjectiveToggle extends StatelessWidget {
  final AppPalette palette;
  final bool isMaximization;
  final ValueChanged<bool> onChanged;

  const ObjectiveToggle({
    super.key,
    required this.palette,
    required this.isMaximization,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: [!isMaximization, isMaximization],
        onPressed: (index) => onChanged(index == 1),
        color: palette.text,
        selectedColor: palette.accent,
        fillColor: Colors.blue.withValues(alpha: 0.3),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Minimizar'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Maximizar'),
          ),
        ],
      ),
    );
  }
}
