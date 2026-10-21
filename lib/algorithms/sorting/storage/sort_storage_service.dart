import 'dart:convert';

import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y carga conjuntos de números con SharedPreferences, igual que
/// GraphStorageService hace con los grafos. Todo va en una sola clave.
class SortStorageService {
  static const String _key = 'saved_sorts';

  /// Lista los guardados (los más recientes primero). Con [sortId] solo
  /// los de ese método.
  Future<List<SavedSort>> list({String? sortId}) async {
    final all = await _readAll();
    final result = sortId == null
        ? all
        : all.where((s) => s.sortId == sortId).toList();
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  /// Guarda. Si [id] es de uno existente lo sobrescribe. Devuelve el id.
  Future<String> save({
    String? id,
    required String name,
    required String sortId,
    required List<int> values,
    required bool descending,
  }) async {
    final all = await _readAll();
    final savedId = id ?? DateTime.now().millisecondsSinceEpoch.toString();

    all.removeWhere((s) => s.id == savedId);
    all.add(
      SavedSort(
        id: savedId,
        name: name,
        sortId: sortId,
        updatedAt: DateTime.now(),
        values: values,
        descending: descending,
      ),
    );
    await _writeAll(all);
    return savedId;
  }

  Future<void> delete(String id) async {
    final all = await _readAll();
    all.removeWhere((s) => s.id == id);
    await _writeAll(all);
  }

  Future<List<SavedSort>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => SavedSort.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<SavedSort> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(all.map((s) => s.toJson()).toList()),
    );
  }
}
