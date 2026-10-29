import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

enum KruskalDecision { accepted, rejected }

class KruskalStep {
  final String edgeId;
  final KruskalDecision decision;
  final Set<String> selectedEdgeIds;
  final Set<String> connectedNodeIds;

  const KruskalStep({
    required this.edgeId,
    required this.decision,
    required this.selectedEdgeIds,
    required this.connectedNodeIds,
  });
}

class KruskalResult {
  final List<KruskalStep> steps;
  final List<String> minimumSpanningTreeEdgeIds;
  final Set<String> connectedNodeIds;
  final double totalWeight;

  const KruskalResult({
    required this.steps,
    required this.minimumSpanningTreeEdgeIds,
    required this.connectedNodeIds,
    required this.totalWeight,
  });
}

class KruskalAlgorithm {
  static KruskalResult run({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
  }) {
    final nodeIds = nodes.map((node) => node.id).toSet();
    final parent = {for (final id in nodeIds) id: id};
    final rank = {for (final id in nodeIds) id: 0};
    final selectedEdgeIds = <String>{};
    final connectedNodeIds = <String>{};
    final steps = <KruskalStep>[];
    var totalWeight = 0.0;

    for (final edge in edges) {
      if (edge.type != EdgeType.simple ||
          !nodeIds.contains(edge.sourceId) ||
          !nodeIds.contains(edge.targetId) ||
          edge.sourceId == edge.targetId ||
          edge.weight < 0) {
        throw const FormatException(
          'Kruskal necesita aristas no dirigidas, sin bucles y con pesos no negativos.',
        );
      }
    }

    String find(String id) {
      var root = id;
      while (parent[root] != root) {
        root = parent[root]!;
      }
      var current = id;
      while (parent[current] != current) {
        final next = parent[current]!;
        parent[current] = root;
        current = next;
      }
      return root;
    }

    void union(String first, String second) {
      var firstRoot = find(first);
      var secondRoot = find(second);
      if (firstRoot == secondRoot) return;
      if (rank[firstRoot]! < rank[secondRoot]!) {
        final temporary = firstRoot;
        firstRoot = secondRoot;
        secondRoot = temporary;
      }
      parent[secondRoot] = firstRoot;
      if (rank[firstRoot] == rank[secondRoot]) {
        rank[firstRoot] = rank[firstRoot]! + 1;
      }
    }

    final orderedEdges = [...edges]
      ..sort((first, second) => first.weight.compareTo(second.weight));

    for (final edge in orderedEdges) {
      final accepts = find(edge.sourceId) != find(edge.targetId);
      if (accepts) {
        union(edge.sourceId, edge.targetId);
        selectedEdgeIds.add(edge.id);
        connectedNodeIds
          ..add(edge.sourceId)
          ..add(edge.targetId);
        totalWeight += edge.weight;
      }
      steps.add(
        KruskalStep(
          edgeId: edge.id,
          decision: accepts
              ? KruskalDecision.accepted
              : KruskalDecision.rejected,
          selectedEdgeIds: Set.of(selectedEdgeIds),
          connectedNodeIds: Set.of(connectedNodeIds),
        ),
      );
      if (selectedEdgeIds.length == nodeIds.length - 1) break;
    }

    return KruskalResult(
      steps: steps,
      minimumSpanningTreeEdgeIds: selectedEdgeIds.toList(),
      connectedNodeIds: connectedNodeIds,
      totalWeight: totalWeight,
    );
  }
}
