import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../models/saved_graph.dart';

/// Maneja el guardado/carga/borrado de grafos usando SharedPreferences.
///
/// Estructura de almacenamiento:
/// - Una clave índice ('saved_graphs_index') con la lista liviana
///   (id, nombre, fecha) de todos los grafos guardados.
/// - Una clave por grafo ('graph_data_<id>') con el contenido completo
///   (nodos y aristas) en JSON.
class GraphStorageService {
  static const String _indexKey = 'saved_graphs_index';
  static const String _dataKeyPrefix = 'graph_data_';

  Future<List<SavedGraphMeta>> listSavedGraphs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final metas = decoded
        .map((e) => SavedGraphMeta.fromJson(e as Map<String, dynamic>))
        .toList();

    metas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return metas;
  }

  Future<SavedGraph?> loadGraph(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_dataKeyPrefix$id');
    if (raw == null) return null;
    return SavedGraph.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Guarda un grafo. Si se pasa [id] de un grafo existente, lo sobrescribe
  /// (actualiza nombre, fecha y contenido). Si no, crea uno nuevo.
  /// Devuelve el id final del grafo guardado.
  Future<String> saveGraph({
    String? id,
    required String name,
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final graphId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final savedGraph = SavedGraph(
      id: graphId,
      name: name,
      updatedAt: now,
      nodes: nodes,
      edges: edges,
    );

    // Guarda el contenido completo del grafo.
    await prefs.setString(
      '$_dataKeyPrefix$graphId',
      jsonEncode(savedGraph.toJson()),
    );

    // Actualiza el índice liviano.
    final metas = await listSavedGraphs();
    metas.removeWhere((m) => m.id == graphId);
    metas.add(savedGraph.toMeta());

    await prefs.setString(
      _indexKey,
      jsonEncode(metas.map((m) => m.toJson()).toList()),
    );

    return graphId;
  }

  Future<void> deleteGraph(String id) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_dataKeyPrefix$id');

    final metas = await listSavedGraphs();
    metas.removeWhere((m) => m.id == id);
    await prefs.setString(
      _indexKey,
      jsonEncode(metas.map((m) => m.toJson()).toList()),
    );
  }
}
