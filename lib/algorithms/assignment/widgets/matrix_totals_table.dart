import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/matrix_stats.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Matriz con una columna/fila de "Suma" y otra de "Nodos" (relaciones ≠ 0).
class MatrixTotalsTable extends StatelessWidget {
  final List<String> rowNames;
  final List<String> colNames;
  final List<List<double>> matrix;
  final AppPalette palette;
  final bool compact;
  final String cornerLabel;

  const MatrixTotalsTable({
    super.key,
    required this.rowNames,
    required this.colNames,
    required this.matrix,
    required this.palette,
    this.compact = false,
    this.cornerLabel = '',
  });

  TextStyle _bold(Color c) => TextStyle(fontWeight: FontWeight.bold, color: c);

  DataCell _text(String s, TextStyle style) => DataCell(Text(s, style: style));

  DataCell get _dash =>
      DataCell(Text('-', style: TextStyle(color: palette.subtleText)));

  DataCell _valueCell(double v) => _text(
    fmtMatrixValue(v),
    TextStyle(
      color: v == 0 ? Colors.greenAccent : palette.subtleText,
      fontWeight: v == 0 ? FontWeight.bold : FontWeight.normal,
    ),
  );

  DataRow _dataRow(int r) {
    final row = r < matrix.length ? matrix[r] : const <double>[];

    return DataRow(
      cells: [
        _text(rowNames[r], _bold(palette.text)),
        for (int c = 0; c < colNames.length; c++)
          _valueCell(c < row.length ? row[c] : 0.0),
        _text(
          fmtMatrixValue(MatrixStats.sumRow(row)),
          _bold(Colors.orangeAccent),
        ),
        _text('${MatrixStats.nonZeroInRow(row)}', _bold(palette.accent)),
      ],
    );
  }

  DataRow _totalsRow(String label, Color color, String Function(int) valueAt) {
    return DataRow(
      cells: [
        _text(label, _bold(color)),
        for (int c = 0; c < colNames.length; c++)
          _text(valueAt(c), _bold(color)),
        _dash,
        _dash,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: compact ? 32 : null,
        dataRowMinHeight: compact ? 28 : null,
        dataRowMaxHeight: compact ? 36 : null,
        columns: [
          DataColumn(label: Text(cornerLabel, style: _bold(palette.text))),
          for (final c in colNames)
            DataColumn(label: Text(c, style: _bold(palette.text))),
          DataColumn(label: Text('Suma', style: _bold(Colors.orangeAccent))),
          DataColumn(label: Text('Nodos', style: _bold(palette.accent))),
        ],
        rows: [
          for (int r = 0; r < rowNames.length; r++) _dataRow(r),
          _totalsRow(
            'Suma',
            Colors.orangeAccent,
            (c) => fmtMatrixValue(MatrixStats.sumColumn(matrix, c)),
          ),
          _totalsRow(
            'Nodos',
            palette.accent,
            (c) => '${MatrixStats.nonZeroInColumn(matrix, c)}',
          ),
        ],
      ),
    );
  }
}
