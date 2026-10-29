import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

class DijkstraStep {
  final String currentId;
  final String? edgeId;
  final Map<String, double> distances;
  final Set<String> visited;

  const DijkstraStep({
    required this.currentId,
    required this.edgeId,
    required this.distances,
    required this.visited,
  });
}

class DijkstraResult {
  final List<DijkstraStep> steps;
  final List<String> pathNodeIds;
  final List<String> pathEdgeIds;
  final double distance;

  const DijkstraResult({
    required this.steps,
    required this.pathNodeIds,
    required this.pathEdgeIds,
    required this.distance,
  });
}

class DijkstraAlgorithm {
  static DijkstraResult run({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required String sourceId,
    required String targetId,
  }) {
    final nodeIds = nodes.map((node) => node.id).toSet();
    if (!nodeIds.contains(sourceId) || !nodeIds.contains(targetId)) {
      throw const FormatException(
        'El origen y el destino deben pertenecer al grafo.',
      );
    }
    if (sourceId == targetId) {
      return DijkstraResult(
        steps: const [],
        pathNodeIds: [sourceId],
        pathEdgeIds: const [],
        distance: 0,
      );
    }

    final distances = {for (final id in nodeIds) id: double.infinity};
    final previousNode = <String, String?>{};
    final previousEdge = <String, String?>{};
    final pending = <String>{...nodeIds};
    final visited = <String>{};
    final steps = <DijkstraStep>[];

    for (final edge in edges) {
      if (edge.type != EdgeType.directed ||
          !nodeIds.contains(edge.sourceId) ||
          !nodeIds.contains(edge.targetId) ||
          edge.weight <= 0) {
        throw const FormatException(
          'Dijkstra necesita aristas dirigidas con pesos positivos.',
        );
      }
    }

    distances[sourceId] = 0;
    while (pending.isNotEmpty) {
      String? current;
      var best = double.infinity;
      for (final id in pending) {
        if (distances[id]! < best) {
          best = distances[id]!;
          current = id;
        }
      }
      if (current == null || best == double.infinity) break;

      pending.remove(current);
      visited.add(current);
      steps.add(
        DijkstraStep(
          currentId: current,
          edgeId: null,
          distances: Map.of(distances),
          visited: Set.of(visited),
        ),
      );

      if (current == targetId) break;

      for (final edge in edges.where((edge) => edge.sourceId == current)) {
        if (!pending.contains(edge.targetId)) continue;
        final candidate = distances[current]! + edge.weight;
        if (candidate < distances[edge.targetId]!) {
          distances[edge.targetId] = candidate;
          previousNode[edge.targetId] = current;
          previousEdge[edge.targetId] = edge.id;
          steps.add(
            DijkstraStep(
              currentId: current,
              edgeId: edge.id,
              distances: Map.of(distances),
              visited: Set.of(visited),
            ),
          );
        }
      }
    }

    if (distances[targetId] == double.infinity) {
      return DijkstraResult(
        steps: steps,
        pathNodeIds: const [],
        pathEdgeIds: const [],
        distance: double.infinity,
      );
    }

    final pathNodeIds = <String>[];
    final pathEdgeIds = <String>[];
    String? current = targetId;
    while (current != null) {
      pathNodeIds.add(current);
      final edgeId = previousEdge[current];
      if (edgeId != null) pathEdgeIds.add(edgeId);
      current = previousNode[current];
    }

    return DijkstraResult(
      steps: steps,
      pathNodeIds: pathNodeIds.reversed.toList(),
      pathEdgeIds: pathEdgeIds.reversed.toList(),
      distance: distances[targetId]!,
    );
  }
}
