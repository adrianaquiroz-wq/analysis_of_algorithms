import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_result.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_stats.dart';
import 'package:graph_app/theme/app_palette.dart';

import '../../shared/widgets/result_card.dart';

/// Matriz original con las celdas de la asignación óptima marcadas.
class OriginalMatrixCard extends StatelessWidget {
  final MatrixResult result;
  final AppPalette palette;

  const OriginalMatrixCard({
    super.key,
    required this.result,
    required this.palette,
  });

  TextStyle get _headStyle =>
      TextStyle(fontWeight: FontWeight.bold, color: palette.text);

  @override
  Widget build(BuildContext context) {
    final assigned = result.assignmentPairs
        .map((p) => '${p.key},${p.value}')
        .toSet();

    return ResultCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matriz Original (con asignaciones marcadas)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '= Asignación óptima',
                style: TextStyle(fontSize: 13, color: palette.subtleText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (result.rowNames.isEmpty)
            Text('Matriz vacía.', style: TextStyle(color: palette.subtleText))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Filas / Cols', style: _headStyle)),
                  for (final c in result.colNames)
                    DataColumn(label: Text(c, style: _headStyle)),
                ],
                rows: [
                  for (int r = 0; r < result.rowNames.length; r++)
                    _buildRow(r, assigned),
                ],
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildRow(int r, Set<String> assigned) {
    final row = r < result.originalMatrix.length
        ? result.originalMatrix[r]
        : const <double>[];

    return DataRow(
      cells: [
        DataCell(Text(result.rowNames[r], style: _headStyle)),
        for (int c = 0; c < result.colNames.length; c++)
          _buildCell(c < row.length ? row[c] : 0.0, assigned.contains('$r,$c')),
      ],
    );
  }

  DataCell _buildCell(double value, bool isAssigned) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: isAssigned
            ? BoxDecoration(
                color: Colors.green.withValues(alpha: 0.25),
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Text(
          fmtMatrixValue(value),
          style: TextStyle(
            fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
            color: isAssigned ? Colors.greenAccent : palette.subtleText,
          ),
        ),
      ),
    );
  }
}
