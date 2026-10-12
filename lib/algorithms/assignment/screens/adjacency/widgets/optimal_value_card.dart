import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class OptimalValueCard extends StatelessWidget {
  final AppPalette palette;
  final bool isMaximization;
  final double value;

  const OptimalValueCard({
    super.key,
    required this.palette,
    required this.isMaximization,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: palette.isDark ? 0.2 : 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isMaximization
                ? 'VALOR ÓPTIMO DE MAXIMIZACIÓN'
                : 'VALOR ÓPTIMO DE MINIMIZACIÓN',
            style: TextStyle(
              color: palette.subtleText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: palette.accent,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
