import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_result.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'matrix_totals_table.dart';
import '../../shared/widgets/result_card.dart';

class FinalMatrixCard extends StatelessWidget {
  final MatrixResult result;
  final AppPalette palette;

  const FinalMatrixCard({
    super.key,
    required this.result,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matriz de Costos / Reducida Final (con Sumas y Nodos)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 12),
          if (result.rowNames.isEmpty)
            Text('Matriz vacía.', style: TextStyle(color: palette.subtleText))
          else
            MatrixTotalsTable(
              rowNames: result.rowNames,
              colNames: result.colNames,
              matrix: result.finalMatrix,
              palette: palette,
              cornerLabel: 'Filas / Cols',
            ),
        ],
      ),
    );
  }
}
