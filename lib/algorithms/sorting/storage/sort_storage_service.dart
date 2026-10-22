import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortStorageService {
  static const String _key = 'saved_sorts';

  /// Sube cada vez que se guarda o borra algo, para que las listas se recarguen.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<List<SavedSort>> list({String? sortId}) async {
    final all = await _readAll();
    final result = sortId == null
        ? all
        : all.where((s) => s.sortId == sortId).toList();
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

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
    changes.value++;
  }
}
