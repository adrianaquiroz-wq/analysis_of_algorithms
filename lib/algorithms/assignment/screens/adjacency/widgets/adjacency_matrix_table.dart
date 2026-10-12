import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class AdjacencyMatrixTable extends StatelessWidget {
  final List<String> names;
  final List<List<double>> matrix;
  final AppPalette palette;

  const AdjacencyMatrixTable({
    super.key,
    required this.names,
    required this.matrix,
    required this.palette,
  });

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Widget _cell(String text, TextStyle style) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, textAlign: TextAlign.center, style: style),
  );

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    final head = TextStyle(color: palette.text, fontWeight: FontWeight.bold);
    final body = TextStyle(color: palette.subtleText);
    final headerColor = palette.isDark
        ? const Color(0xFF334155)
        : Colors.grey[200];
    final borderColor = palette.isDark ? Colors.white24 : Colors.grey.shade300;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(60),
        border: TableBorder.all(color: borderColor),
        children: [
          TableRow(
            decoration: BoxDecoration(color: headerColor),
            children: [
              _cell('', head),
              for (final name in names) _cell(name, head),
            ],
          ),
          for (int i = 0; i < names.length; i++)
            TableRow(
              decoration: BoxDecoration(color: palette.card),
              children: [
                _cell(names[i], head),
                for (int j = 0; j < names.length; j++)
                  _cell(_fmt(matrix[i][j]), body),
              ],
            ),
        ],
      ),
    );
  }
}
