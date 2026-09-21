import 'node_model.dart';
import 'edge_model.dart';

/// Información liviana de un grafo guardado, para mostrar en listas
/// sin necesidad de cargar todos los nodos/aristas.
class SavedGraphMeta {
  final String id;
  final String name;
  final DateTime updatedAt;

  SavedGraphMeta({
    required this.id,
    required this.name,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SavedGraphMeta.fromJson(Map<String, dynamic> json) {
    return SavedGraphMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Un grafo guardado completo, con todos sus nodos y aristas.
class SavedGraph {
  final String id;
  final String name;
  final DateTime updatedAt;
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;

  SavedGraph({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.nodes,
    required this.edges,
  });

  SavedGraphMeta toMeta() =>
      SavedGraphMeta(id: id, name: name, updatedAt: updatedAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'edges': edges.map((e) => e.toJson()).toList(),
  };

  factory SavedGraph.fromJson(Map<String, dynamic> json) {
    return SavedGraph(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      nodes: (json['nodes'] as List)
          .map((n) => NodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List)
          .map((e) => EdgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
