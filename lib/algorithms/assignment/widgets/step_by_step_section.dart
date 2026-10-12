import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_result.dart';
import 'package:graph_app/algorithms/assignment/models/matrix_step.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'matrix_totals_table.dart';
import '../../shared/widgets/result_card.dart';

/// Desglose del algoritmo: una tarjeta por paso, con la matriz de ese momento.
class StepByStepSection extends StatelessWidget {
  final MatrixResult result;
  final AppPalette palette;

  const StepByStepSection({
    super.key,
    required this.result,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final steps = result.stepByStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desglose del Algoritmo Paso a Paso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < steps.length; i++)
          _buildStep(i, steps.length, steps[i]),
      ],
    );
  }

  Widget _buildStep(int index, int total, MatrixStep step) {
    return ResultCard(
      palette: palette,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: palette.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${index + 1}/$total',
                style: TextStyle(fontSize: 12, color: palette.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            step.description,
            style: TextStyle(fontSize: 14, color: palette.subtleText),
          ),
          const SizedBox(height: 14),
          Text(
            'Estado de la matriz en este paso:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 8),
          MatrixTotalsTable(
            rowNames: step.rowNames,
            colNames: step.colNames,
            matrix: step.matrixSnapshot,
            palette: palette,
            compact: true,
          ),
        ],
      ),
    );
  }
}
