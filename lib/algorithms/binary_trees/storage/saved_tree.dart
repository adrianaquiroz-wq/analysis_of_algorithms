import 'dart:convert';

import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un árbol guardado con todo: valores (en orden de inserción), recorrido
/// elegido, el paso en que estaba y el procedimiento de los 3 recorridos.
class SavedTree {
  final String id;
  final String name;
  final DateTime updatedAt;
  final List<int> values;
  final TraversalType type;
  final int cursor;
  final Map<TraversalType, TraversalResult> results;

  const SavedTree({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.values,
    required this.type,
    required this.cursor,
    required this.results,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'values': values,
    'type': type.name,
    'cursor': cursor,
    'results': {for (final e in results.entries) e.key.name: e.value.toJson()},
  };

  factory SavedTree.fromJson(Map<String, dynamic> j) => SavedTree(
    id: j['id'] as String,
    name: j['name'] as String,
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    values: (j['values'] as List).map((e) => (e as num).toInt()).toList(),
    type: TraversalType.values.byName(j['type'] as String),
    cursor: (j['cursor'] as num?)?.toInt() ?? 0,
    results: (j['results'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        TraversalType.values.byName(k),
        TraversalResult.fromJson(v as Map<String, dynamic>),
      ),
    ),
  );
}

class TreeStorageService {
  static const String _key = 'saved_trees';

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