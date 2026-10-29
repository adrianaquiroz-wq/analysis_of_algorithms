import 'package:flutter_test/flutter_test.dart';
import 'package:graph_app/algorithms/dijkstra/logic/dijkstra_algorithm.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

void main() {
  final nodes = [
    NodeModel(id: 'a', label: 'A', position: Offset.zero),
    NodeModel(id: 'b', label: 'B', position: Offset.zero),
    NodeModel(id: 'c', label: 'C', position: Offset.zero),
  ];

  test('encuentra la ruta dirigida de menor peso', () {
    final result = DijkstraAlgorithm.run(
      nodes: nodes,
      edges: [
        EdgeModel(
          id: 'ab',
          sourceId: 'a',
          targetId: 'b',
          type: EdgeType.directed,
          weight: 4,
        ),
        EdgeModel(
          id: 'ac',
          sourceId: 'a',
          targetId: 'c',
          type: EdgeType.directed,
          weight: 1,
        ),
        EdgeModel(
          id: 'cb',
          sourceId: 'c',
          targetId: 'b',
          type: EdgeType.directed,
          weight: 2,
        ),
      ],
      sourceId: 'a',
      targetId: 'b',
    );

    expect(result.pathNodeIds, ['a', 'c', 'b']);
    expect(result.pathEdgeIds, ['ac', 'cb']);
    expect(result.distance, 3);
  });

  test('rechaza aristas no dirigidas o pesos no positivos', () {
    expect(
      () => DijkstraAlgorithm.run(
        nodes: nodes,
        edges: [
          EdgeModel(
            id: 'ab',
            sourceId: 'a',
            targetId: 'b',
            weight: 1,
          ),
        ],
        sourceId: 'a',
        targetId: 'b',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('devuelve una ruta vacía si el destino es inalcanzable', () {
    final result = DijkstraAlgorithm.run(
      nodes: nodes,
      edges: const [],
      sourceId: 'a',
      targetId: 'c',
    );

    expect(result.pathNodeIds, isEmpty);
    expect(result.distance, double.infinity);
  });
}
