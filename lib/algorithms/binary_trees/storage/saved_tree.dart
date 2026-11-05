import 'dart:convert';
import 'dart:ui' show Offset;

import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un árbol guardado con todo: forma exacta, posición de cada nodo, cómo se
/// creó, recorrido elegido, paso en que estaba y el procedimiento de los 3
/// recorridos.
class SavedTree {
  final String id;
  final String name;
  final DateTime updatedAt;
  final String origin;
  final BinaryTree tree;
  final Map<int, Offset> positions;
  final TraversalType type;
  final int cursor;
  final Map<TraversalType, TraversalResult> results;
  final String? ambiguity;

  const SavedTree({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.origin,
    required this.tree,
    required this.positions,
    required this.type,
    required this.cursor,
    required this.results,
    this.ambiguity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'origin': origin,
    'tree': tree.toJson(),
    'positions': {
      for (final e in positions.entries) '${e.key}': [e.value.dx, e.value.dy],
    },
    'type': type.name,
    'cursor': cursor,
    'ambiguity': ambiguity,
    'results': {for (final e in results.entries) e.key.name: e.value.toJson()},
  };

  factory SavedTree.fromJson(Map<String, dynamic> j) => SavedTree(
    id: j['id'] as String,
    name: j['name'] as String,
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    origin: j['origin'] as String? ?? '',
    tree: BinaryTree.fromJson(j['tree'] as Map<String, dynamic>),
    positions: (j['positions'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        int.parse(k),
        Offset((v as List)[0].toDouble(), v[1].toDouble()),
      ),
    ),
    type: TraversalType.values.byName(j['type'] as String),
    cursor: (j['cursor'] as num?)?.toInt() ?? 0,
    ambiguity: j['ambiguity'] as String?,
    results: (j['results'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        TraversalType.values.byName(k),
        TraversalResult.fromJson(v as Map<String, dynamic>),
      ),
    ),
  );
}

class TreeStorageService {
  // v2: formato nuevo (forma del árbol + posiciones). No choca con el anterior.
  static const String _key = 'saved_trees_v2';

  Future<List<SavedTree>> list() async {
    final all = await _readAll();
    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  Future<void> save(SavedTree tree) async {
    final all = await _readAll();
    all.removeWhere((s) => s.id == tree.id);
    all.add(tree);
    await _writeAll(all);
  }

  Future<void> delete(String id) async {
    final all = await _readAll();
    all.removeWhere((s) => s.id == id);
    await _writeAll(all);
  }

  Future<List<SavedTree>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => SavedTree.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<SavedTree> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(all.map((s) => s.toJson()).toList()),
    );
  }
}