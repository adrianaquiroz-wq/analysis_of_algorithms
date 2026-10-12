import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class ObjectiveChips extends StatelessWidget {
  final AppPalette palette;
  final bool isMaximization;
  final ValueChanged<bool> onChanged;

  const ObjectiveChips({
    super.key,
    required this.palette,
    required this.isMaximization,
    required this.onChanged,
  });

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    final dark = palette.isDark;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: dark
          ? const Color(0xFF0E7490).withValues(alpha: 0.35)
          : const Color(0xFF789AB6),
      backgroundColor: dark ? const Color(0xFF334155) : Colors.white,
      labelStyle: TextStyle(
        color: selected
            ? (dark ? const Color(0xFF85AFB4) : Colors.blue[900])
            : palette.text,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip('Maximizar', isMaximization, () => onChanged(true)),
        const SizedBox(width: 12),
        _chip('Minimizar', !isMaximization, () => onChanged(false)),
      ],
    );
  }
}
