import 'dart:math';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_reconstructor.dart';
import 'package:graph_app/algorithms/binary_trees/storage/saved_tree.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

export 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

/// Estado del árbol, de su dibujo (posiciones) y de la animación del mono.
class TreeTraversalController extends ChangeNotifier {
  static const String _emptyNote =
      'Crea un árbol por teclado, al azar o reconstruyéndolo con dos recorridos.';

  BinaryTree _tree = BinaryTree();
  Map<int, Offset> _positions = {};
  String _origin = '';
  String? _ambiguity;
  int _treeVersion = 0;

  TraversalType _type = TraversalType.inOrder;
  TraversalResult? _result;
  int _cursor = 0;
  PlayState _state = PlayState.idle;
  double _speed = 1;
  int _runId = 0;
  bool _disposed = false;

  int? _monkey;
  StepKind? _lastKind;
  String _note = _emptyNote;
  final List<int> _output = []; // recorrido: {A, B, D...}
  final List<int> _trail = []; // camino completo del mono
  final Set<String> _pathEdges = {};

  BinaryTree get tree => _tree;
  Map<int, Offset> get positions => _positions;
  String get origin => _origin;
  String? get ambiguity => _ambiguity;

  /// Sube cada vez que cambia el árbol entero (para reencuadrar la vista).
  int get treeVersion => _treeVersion;

  TraversalType get type => _type;
  TraversalResult? get result => _result;
  int get cursor => _cursor;
  int get totalSteps => _result?.steps.length ?? 0;
  PlayState get state => _state;
  double get speed => _speed;
  bool get isPlaying => _state == PlayState.playing;
  int? get monkeyNode => _monkey;
  StepKind? get lastKind => _lastKind;
  String get note => _note;
  List<int> get output => _output;
  List<int> get trail => _trail;
  Set<String> get pathEdges => _pathEdges;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _clearProgress() {
    _result = null;
    _cursor = 0;
    _state = PlayState.idle;
    _output.clear();
    _trail.clear();
    _pathEdges.clear();
    _lastKind = null;
  }

  void _replaceTree(
    BinaryTree t,
    String origin, {
    Map<int, Offset>? positions,
    String? ambiguity,
  }) {
    _runId++;
    _clearProgress();
    _tree = t;
    _positions = positions ?? t.autoPositions();
    _origin = origin;
    _ambiguity = ambiguity;
    _monkey = t.root?.value;
    _note = t.root == null
        ? _emptyNote
        : 'Árbol listo (${t.size} nodos). Elige un recorrido y suelta al mono.';
    _treeVersion++;
    _emit();
  }

  // ----------------------------------------------------- Crear el árbol

  /// Crea un árbol de búsqueda con los números escritos (el primero es la raíz).
  /// Devuelve un mensaje de error o null. Si hay error, se conserva el árbol anterior.
  String? createFromText(String text) {
    final r = TreeInput.parse(text);
    if (r.error != null) return r.error;
    final vals = r.values;
    if (vals.length > TreeInput.maxNodes) {
      return 'Máximo ${TreeInput.maxNodes} nodos.';
    }
    if (vals.toSet().length != vals.length) {
      return 'Cada valor debe ser único.';
    }
    _replaceTree(
      BinaryTree.fromValues(vals),
      'Árbol de búsqueda · Inserción por teclado',
    );
    return null;
  }

  /// Árbol de búsqueda con valores distintos al azar dentro de [min, max].
  String? generateRandom(int? min, int? max, int? count) {
    if (min == null || max == null || count == null) {
      return 'Escribe mínimo, máximo y cantidad como números enteros.';
    }
    if (min < TreeInput.minValue || max > TreeInput.maxValue) {
      return 'Los valores deben estar entre ${TreeInput.minValue} y ${TreeInput.maxValue}.';
    }
    if (min > max) return 'El mínimo no puede ser mayor que el máximo.';
    if (count < 1 || count > TreeInput.maxNodes) {
      return 'La cantidad debe estar entre 1 y ${TreeInput.maxNodes}.';
    }
    if (max - min + 1 < count) {
      return 'El rango no tiene $count valores diferentes.';
    }
    final rnd = Random();
    final set = <int>{};
    while (set.length < count) {
      set.add(min + rnd.nextInt(max - min + 1));
    }
    _replaceTree(
      BinaryTree.fromValues(set.toList()),
      'Árbol de búsqueda · Aleatorio',
    );
    return null;
  }

  /// Reconstruye con dos recorridos. Si no son compatibles devuelve el error y
  /// conserva el árbol anterior.
  String? reconstructFromText(ReconstructPair pair, String textA, String textB) {
    final ra = TreeInput.parse(textA);
    if (ra.error != null) return 'Primer recorrido: ${ra.error}';
    final rb = TreeInput.parse(textB);
    if (rb.error != null) return 'Segundo recorrido: ${rb.error}';
    try {
      final res = TreeReconstructor.run(pair, ra.values, rb.values);
      _replaceTree(
        res.tree,
        'Árbol reconstruido · ${pair.label}',
        ambiguity: res.ambiguous
            ? 'Pre-order y Post-order admiten varios árboles cuando un nodo tiene un solo hijo. Se muestra una solución válida con ese hijo a la izquierda.'
            : null,
      );
      return null;
    } on ReconstructException catch (e) {
      return e.message;
    }
  }

  void clear() => _replaceTree(BinaryTree(), '');

  // ------------------------------------------------------------ Lienzo

  void moveNode(int value, Offset position) {
    if (!_positions.containsKey(value)) return;
    _positions[value] = position;
    _emit();
  }

  /// Restaura la distribución automática de los nodos.
  void autoArrange() {
    _positions = _tree.autoPositions();
    _treeVersion++;
    _emit();
  }

  // ----------------------------------------------------------- Recorrido

  void setType(TraversalType t) {
    if (isPlaying) return;
    _runId++;
    _type = t;
    _clearProgress();
    _monkey = _tree.root?.value;
    _note = '${t.label}: ${t.rule}.';
    _emit();
  }

  void setSpeed(double s) {
    _speed = s;
    _emit();
  }

  Future<void> _wait(int ms) =>
      Future.delayed(Duration(milliseconds: (ms / _speed).round()));

  void _prepare() {
    _clearProgress();
    _result = TreeTraversalAlgorithm.run(_tree, _type);
  }

  void _apply(TraversalStep s) {
    _monkey = s.node;
    _note = s.note;
    _lastKind = s.kind;
    if (s.kind == StepKind.visit) {
      _output.add(s.node);
    } else {
      _trail.add(s.node);
      if (s.from != null) _pathEdges.add(edgeKey(s.from!, s.node));
    }
  }

  void start() {
    if (isPlaying) return;
    if (_tree.root == null) {
      _note = 'Primero crea un árbol.';
      _emit();
      return;
    }
    _prepare();
    _play();
  }

  void resume() {
    if (_state == PlayState.paused) _play();
  }

  void pause() {
    if (_state != PlayState.playing) return;
    _state = PlayState.paused;
    _emit();
  }

  Future<void> _play() async {
    final run = ++_runId;
    _state = PlayState.playing;
    _emit();
    final steps = _result!.steps;
    while (_cursor < steps.length) {
      if (run != _runId || _state != PlayState.playing) return;
      final s = steps[_cursor];
      _apply(s);
      _cursor++;
      _emit();
      await _wait(s.kind == StepKind.visit ? 850 : 650);
    }
    if (run != _runId) return;
    _state = PlayState.done;
    _note = 'Recorrido ${_type.label} completo.';
    _emit();
  }

  void stepForward() {
    if (_tree.root == null || isPlaying) return;
    if (_state == PlayState.idle || _state == PlayState.done) _prepare();
    _runId++;
    _state = PlayState.paused;
    final steps = _result!.steps;
    _apply(steps[_cursor]);
    _cursor++;
    if (_cursor >= steps.length) {
      _state = PlayState.done;
      _note = 'Recorrido ${_type.label} completo.';
    }
    _emit();
  }

  void reset() {
    _runId++;
    _clearProgress();
    _monkey = _tree.root?.value;
    _note = _tree.root == null ? _emptyNote : 'Todo listo para un nuevo recorrido.';
    _emit();
  }

  // ------------------------------------------------------------- Guardado

  /// Procedimiento completo de los 3 recorridos (para guardar).
  Map<TraversalType, TraversalResult> allResults() => {
    for (final t in TraversalType.values)
      t: (t == _type && _result != null)
          ? _result!
          : TreeTraversalAlgorithm.run(_tree, t),
  };

  /// Restaura forma, posiciones, recorrido elegido y el paso exacto.
  void loadSaved(SavedTree s) {
    final auto = s.tree.autoPositions();
    final pos = {
      for (final e in auto.entries) e.key: s.positions[e.key] ?? e.value,
    };
    _replaceTree(s.tree, s.origin, positions: pos, ambiguity: s.ambiguity);

    _type = s.type;
    final r = s.results[s.type] ?? TreeTraversalAlgorithm.run(_tree, s.type);
    _result = r;
    final target = s.cursor.clamp(0, r.steps.length).toInt();
    for (var i = 0; i < target; i++) {
      _apply(r.steps[i]);
    }
    _cursor = target;
    _state = target == 0
        ? PlayState.idle
        : (target == r.steps.length ? PlayState.done : PlayState.paused);
    if (target == 0) {
      _monkey = _tree.root?.value;
      _note = '${s.type.label}: ${s.type.rule}.';
    } else if (_state == PlayState.done) {
      _note = 'Recorrido ${s.type.label} completo.';
    }
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    _runId++;
    super.dispose();
  }
}