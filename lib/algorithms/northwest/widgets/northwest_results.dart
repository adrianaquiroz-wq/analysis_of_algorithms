import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/northwest/logic/northwest_corner_algorithm.dart';
import 'package:graph_app/algorithms/northwest/logic/transportation_optimizer.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'transport_matrix_card.dart';

class NorthwestResults extends StatelessWidget {
  final AppPalette palette;
  final NorthwestCornerResult result;
  final List<OptimizationIteration> iterations;

  const NorthwestResults({
    super.key,
    required this.palette,
    required this.result,
    required this.iterations,
  });

  Widget _heading(String text) => Text(
    text,
    style: TextStyle(
      color: palette.text,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _heading('Fase 1: Esquina Noroeste (Solución Básica Inicial)'),
        const SizedBox(height: 10),
        TransportMatrixCard(
          palette: palette,
          rowNames: result.rowNames,
          colNames: result.colNames,
          matrix: result.allocations,
          total: result.total,
          label: 'C_1',
          isFinal: false,
        ),
        const SizedBox(height: 20),
        _heading('Fase 2: Optimización MODI (Iteraciones)'),
        const SizedBox(height: 10),
        for (int i = 0; i < iterations.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TransportMatrixCard(
              palette: palette,
              rowNames: result.rowNames,
              colNames: result.colNames,
              matrix: iterations[i].allocations,
              total: iterations[i].totalValue,
              label: 'C_${i + 2}',
              isFinal: iterations[i].isOptimal,
              enteringRow: iterations[i].enteringRow,
              enteringCol: iterations[i].enteringCol,
              theta: iterations[i].theta,
            ),
          ),
      ],
    );
  }
}
