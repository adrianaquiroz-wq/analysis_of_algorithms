import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

class TransportCostMatrix {
  /// costs[i][j] = peso de la arista del origen i al destino j (0 si no hay).
  static List<List<double>> build({
    required List<NodeModel> groupA,
    required List<NodeModel> groupB,
    required List<EdgeModel> edges,
  }) {
    final rowIndex = {for (int i = 0; i < groupA.length; i++) groupA[i].id: i};
    final colIndex = {for (int j = 0; j < groupB.length; j++) groupB[j].id: j};

    final matrix = List.generate(
      groupA.length,
      (_) => List<double>.filled(groupB.length, 0),
    );

    for (final edge in edges) {
      final row = rowIndex[edge.sourceId];
      final column = colIndex[edge.targetId];

      if (row != null && column != null) {
        matrix[row][column] = edge.weight;
        continue;
      }

      final reverseRow = rowIndex[edge.targetId];
      final reverseColumn = colIndex[edge.sourceId];

      if (edge.type == EdgeType.simple &&
          reverseRow != null &&
          reverseColumn != null) {
        matrix[reverseRow][reverseColumn] = edge.weight;
      }
    }
    return matrix;
  }
}
