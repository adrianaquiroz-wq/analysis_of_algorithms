import 'package:flutter_test/flutter_test.dart';
import 'package:graph_app/algorithms/kruskal/logic/kruskal_algorithm.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

void main() {
  final nodes = [
    NodeModel(id: 'a', label: 'A', position: Offset.zero),
    NodeModel(id: 'b', label: 'B', position: Offset.zero),
    NodeModel(id: 'c', label: 'C', position: Offset.zero),
  ];

  test('construye el árbol de expansión mínima', () {
    final result = KruskalAlgorithm.run(
      nodes: nodes,
      edges: [
        EdgeModel(id: 'ab', sourceId: 'a', targetId: 'b', weight: 4),
        EdgeModel(id: 'ac', sourceId: 'a', targetId: 'c', weight: 1),
        EdgeModel(id: 'bc', sourceId: 'b', targetId: 'c', weight: 2),
      ],
    );

    expect(result.minimumSpanningTreeEdgeIds, ['ac', 'bc']);
    expect(result.totalWeight, 3);
  });

  test('rechaza aristas dirigidas y pesos negativos', () {
    expect(
      () => KruskalAlgorithm.run(
        nodes: nodes,
        edges: [
          EdgeModel(
            id: 'ab',
            sourceId: 'a',
            targetId: 'b',
            type: EdgeType.directed,
          ),
        ],
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
