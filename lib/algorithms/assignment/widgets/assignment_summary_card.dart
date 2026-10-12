import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_result.dart';
import 'package:graph_app/theme/app_palette.dart';

import '../../shared/widgets/result_card.dart';

class AssignmentSummaryCard extends StatelessWidget {
  final MatrixResult result;
  final AppPalette palette;

  const AssignmentSummaryCard({
    super.key,
    required this.result,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay matriz, calculationSteps trae el motivo del error.
    final emptyMessage = result.rowNames.isEmpty
        ? result.calculationSteps
        : 'No se encontraron asignaciones válidas.';

    return ResultCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asignaciones Óptimas (Fila ➔ Columna)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.text,
            ),
          ),
          const Divider(),
          if (result.assignments.isEmpty)
            Text(emptyMessage, style: TextStyle(color: palette.subtleText))
          else
            for (final assignment in result.assignments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        assignment,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: palette.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 12),
          Text(
            'Valor Óptimo Total: ${result.optimalValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.accent,
            ),
          ),
        ],
      ),
    );
  }
}
