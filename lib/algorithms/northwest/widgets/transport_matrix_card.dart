import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/shared/number_format.dart';
import 'package:graph_app/theme/app_palette.dart';

class TransportMatrixCard extends StatelessWidget {
  final AppPalette palette;
  final List<String> rowNames;
  final List<String> colNames;
  final List<List<double>> matrix;
  final double total;
  final String label;
  final bool isFinal;
  final int? enteringRow;
  final int? enteringCol;
  final double? theta;

  const TransportMatrixCard({
    super.key,
    required this.palette,
    required this.rowNames,
    required this.colNames,
    required this.matrix,
    required this.total,
    required this.label,
    required this.isFinal,
    this.enteringRow,
    this.enteringCol,
    this.theta,
  });

  TextStyle get _headStyle =>
      TextStyle(color: palette.subtleText, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: isFinal
            ? Border.all(color: Colors.greenAccent, width: 3)
            : null,
        boxShadow: isFinal
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          const SizedBox(height: 16),
          if (enteringRow != null) ...[
            Text(
              'Entra a la base: ${rowNames[enteringRow!]} → '
              '${colNames[enteringCol!]} (θ = ${fmtNumber(theta ?? 0)})',
              style: TextStyle(color: palette.subtleText),
            ),
            const SizedBox(height: 12),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isFinal ? '¡Resultado Final Óptimo!' : 'Iteración',
          style: TextStyle(
            color: isFinal ? Colors.greenAccent : palette.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$label = ${fmtNumber(total)}',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return DataTable(
      headingRowHeight: 40,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 40,
      columns: [
        DataColumn(label: Text('O / D', style: _headStyle)),
        ...colNames.map((c) => DataColumn(label: Text(c, style: _headStyle))),
      ],
      rows: List.generate(matrix.length, (r) {
        return DataRow(
          cells: [
            DataCell(Text(rowNames[r], style: _headStyle)),
            ...List.generate(matrix[r].length, (c) {
              final val = matrix[r][c];
              return DataCell(
                Text(
                  val == 0 ? '-' : fmtNumber(val),
                  style: TextStyle(
                    color: palette.text,
                    fontWeight: val > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
