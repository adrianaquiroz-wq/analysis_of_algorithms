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

enum DijkstraOptimization { minimize, maximize }

class DijkstraAlgorithm {
  static DijkstraResult run({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required String sourceId,
    required String targetId,
    DijkstraOptimization optimization = DijkstraOptimization.minimize,
  }) {
    final nodeIds = nodes.map((node) => node.id).toSet();
    if (!nodeIds.contains(sourceId) || !nodeIds.contains(targetId)) {
      throw const FormatException(
        'El origen y el destino deben pertenecer al grafo.',
      );
    }
    for (final edge in edges) {
      if (edge.type != EdgeType.directed ||
          !nodeIds.contains(edge.sourceId) ||
          !nodeIds.contains(edge.targetId) ||
          edge.sourceId == edge.targetId ||
          edge.weight <= 0) {
        throw const FormatException(
          'Dijkstra necesita aristas dirigidas, sin bucles y con pesos positivos.',
        );
      }
    }
    if (sourceId == targetId) {
      return DijkstraResult(
        steps: const [],
        pathNodeIds: [sourceId],
        pathEdgeIds: const [],
        distance: 0,
      );
    }
    if (optimization == DijkstraOptimization.maximize) {
      return _runMaximumOnDag(
        nodeIds: nodeIds,
        edges: edges,
        sourceId: sourceId,
        targetId: targetId,
      );
    }

    final distances = {for (final id in nodeIds) id: double.infinity};
    final previousNode = <String, String?>{};
    final previousEdge = <String, String?>{};
    final pending = <String>{...nodeIds};
    final visited = <String>{};
    final steps = <DijkstraStep>[];
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
    return _buildResult(
      distances: distances,
      previousNode: previousNode,
      previousEdge: previousEdge,
      steps: steps,
      targetId: targetId,
    );
  }

  static DijkstraResult _runMaximumOnDag({
    required Set<String> nodeIds,
    required List<EdgeModel> edges,
    required String sourceId,
    required String targetId,
  }) {
    final outgoing = {
      for (final id in nodeIds)
        id: edges.where((edge) => edge.sourceId == id).toList(),
    };
    final indegree = {for (final id in nodeIds) id: 0};
    for (final edge in edges) {
      indegree[edge.targetId] = indegree[edge.targetId]! + 1;
    }
    final queue = <String>[
      for (final entry in indegree.entries)
        if (entry.value == 0) entry.key,
    ];
    final order = <String>[];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      order.add(current);
      for (final edge in outgoing[current]!) {
        indegree[edge.targetId] = indegree[edge.targetId]! - 1;
        if (indegree[edge.targetId] == 0) queue.add(edge.targetId);
      }
    }
    if (order.length != nodeIds.length) {
      throw const FormatException(
        'Para maximizar, Dijkstra necesita un grafo dirigido sin ciclos.',
      );
    }

    final distances = {
      for (final id in nodeIds) id: double.negativeInfinity,
    };
    final previousNode = <String, String?>{};
    final previousEdge = <String, String?>{};
    final visited = <String>{};
    final steps = <DijkstraStep>[];
    distances[sourceId] = 0;
    for (final current in order) {
      if (distances[current] == double.infinity) continue;
      visited.add(current);
      steps.add(
        DijkstraStep(
          currentId: current,
          edgeId: null,
          distances: Map.of(distances),
          visited: Set.of(visited),
        ),
      );
      for (final edge in outgoing[current]!) {
        final candidate = distances[current]! + edge.weight;
        if (candidate > distances[edge.targetId]!) {
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
    return _buildResult(
      distances: distances,
      previousNode: previousNode,
      previousEdge: previousEdge,
      steps: steps,
      targetId: targetId,
    );
  }

  static DijkstraResult _buildResult({
    required Map<String, double> distances,
    required Map<String, String?> previousNode,
    required Map<String, String?> previousEdge,
    required List<DijkstraStep> steps,
    required String targetId,
  }) {
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
