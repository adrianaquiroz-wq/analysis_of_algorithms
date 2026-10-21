import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/screens/saved_sorts_screen.dart';
import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:graph_app/algorithms/sorting/storage/sort_storage_service.dart';
import 'package:graph_app/utils/graph_storage_dialogs.dart';

/// Guardar / abrir / nuevo para cualquier pantalla de ordenamiento
/// (equivalente a GraphPersistenceMixin). La pantalla solo dice qué datos
/// tiene y cómo cargar otros.
mixin SortPersistenceMixin<T extends StatefulWidget> on State<T> {
  // Lo que la pantalla debe proveer.
  String get sortId;
  List<int> get currentValues;
  bool get currentDescending;
  bool get darkMode;
  void loadData(List<int> values, bool descending);
  void newData();

  final SortStorageService _storage = SortStorageService();
  String? _currentId;
  String? _currentName;

  Future<void> saveCurrent() async {
    final name = await GraphStorageDialogs.askGraphName(
      context,
      initialValue: _currentName,
      isDarkMode: darkMode,
    );
    if (name == null || !mounted) return;

    final id = await _storage.save(
      id: _currentId,
      name: name,
      sortId: sortId,
      values: currentValues,
      descending: currentDescending,
    );
    if (!mounted) return;

    setState(() {
      _currentId = id;
      _currentName = name;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Datos "$name" guardados.')));
  }

  Future<void> openSaved() async {
    final result = await Navigator.push<SavedSort>(
      context,
      MaterialPageRoute(builder: (_) => SavedSortsScreen(sortId: sortId)),
    );
    if (result == null || !mounted) return;

    setState(() {
      _currentId = result.id;
      _currentName = result.name;
    });
    loadData(result.values, result.descending);
  }

  void startNew() {
    setState(() {
      _currentId = null;
      _currentName = null;
    });
    newData();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Datos nuevos cargados.')));
  }
}
