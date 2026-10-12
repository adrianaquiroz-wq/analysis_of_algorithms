import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/shared/bipartite_groups.dart';
import 'package:graph_app/algorithms/shared/number_format.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Tabla de transporte: costos (solo lectura, vienen del grafo),
/// oferta en columna vertical y demanda en fila horizontal.
class SupplyDemandCard extends StatelessWidget {
  final AppPalette palette;
  final List<NodeModel> groupA;
  final List<NodeModel> groupB;
  final List<List<double>> costs;
  final List<TextEditingController> supplyControllers;
  final List<TextEditingController> demandControllers;

  const SupplyDemandCard({
    super.key,
    required this.palette,
    required this.groupA,
    required this.groupB,
    required this.costs,
    required this.supplyControllers,
    required this.demandControllers,
  });

  Widget _headerCell(String t, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Center(
      child: Text(
        t,
        style: TextStyle(
          color: color ?? palette.subtleText,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _costCell(double v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Center(
      child: Text(
        fmtNumber(v),
        style: TextStyle(color: palette.text, fontSize: 16),
      ),
    ),
  );

  Widget _inputCell(TextEditingController c, String hint) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: TextField(
      controller: c,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: palette.accent, fontWeight: FontWeight.bold),
      decoration: InputDecoration(hintText: hint, isDense: true),
    ),
  );

  Widget _buildTable() {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(90),
      columnWidths: const {0: FixedColumnWidth(80)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: palette.subtleText.withValues(alpha: 0.35),
      ),
      children: [
        // Encabezado: destinos + columna Oferta
        TableRow(
          children: [
            _headerCell('O / D'),
            ...groupB.map((n) => _headerCell(nodeDisplayName(n))),
            _headerCell('Oferta', color: palette.accent),
          ],
        ),
        // Filas: origen + costos + oferta (vertical)
        ...List.generate(groupA.length, (i) {
          return TableRow(
            children: [
              _headerCell(nodeDisplayName(groupA[i]), color: palette.text),
              ...List.generate(groupB.length, (j) => _costCell(costs[i][j])),
              _inputCell(supplyControllers[i], 'Oferta'),
            ],
          );
        }),
        // Última fila: demanda (horizontal)
        TableRow(
          children: [
            _headerCell('Demanda', color: palette.accent),
            ...List.generate(
              groupB.length,
              (j) => _inputCell(demandControllers[j], 'Demanda'),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oferta y demanda',
            style: TextStyle(
              color: palette.text,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Los costos vienen del grafo. Edita la oferta (columna) y la demanda (fila).',
            style: TextStyle(color: palette.subtleText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(),
          ),
        ],
      ),
    );
  }
}
