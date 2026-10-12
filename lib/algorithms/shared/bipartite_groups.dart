import 'package:graph_app/models/node_model.dart';

/// Nombre visible de un nodo: su etiqueta, o su id si no tiene.
String nodeDisplayName(NodeModel n) => n.label.isNotEmpty ? n.label : n.id;

/// Conjunto A (orígenes) y Conjunto B (destinos), ordenados por id.
class BipartiteGroups {
  final List<NodeModel> groupA;
  final List<NodeModel> groupB;

  BipartiteGroups._(this.groupA, this.groupB);

  factory BipartiteGroups.of(List<NodeModel> nodes) {
    final a =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.groupA).toList()
          ..sort((x, y) => x.id.compareTo(y.id));
    final b =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.groupB).toList()
          ..sort((x, y) => x.id.compareTo(y.id));
    return BipartiteGroups._(a, b);
  }

  bool get isComplete => groupA.isNotEmpty && groupB.isNotEmpty;
}
