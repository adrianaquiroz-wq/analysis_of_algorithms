import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/storage/saved_tree.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

export 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

/// Estado del árbol y de la animación del mono. La pantalla solo escucha.
class TreeTraversalController extends ChangeNotifier {
  static const int minValue = 1;
  static const int maxValue = 999;
  static const int maxNodes = 20;

  BinaryTree _tree = BinaryTree();
  final List<int> _values = []; // orden en que se insertaron
  TraversalType _type = TraversalType.inOrder;
  TraversalResult? _result;
  int _cursor = 0;
  PlayState _state = PlayState.idle;
  double _speed = 1;
  bool _inserting = false;
  int _runId = 0;
  bool _disposed = false;

  int? _monkey;
  StepKind? _lastKind;
  String _note = 'Planta el primer número: será la raíz del árbol.';
  final List<int> _output = []; // recorrido: {A, B, D...}
  final List<int> _trail = []; // camino completo del mono
  final Set<String> _pathEdges = {};

  BinaryTree get tree => _tree;
  List<int> get values => List.unmodifiable(_values);
  TraversalType get type => _type;
  TraversalResult? get result => _result;
  int get cursor => _cursor;
  int get totalSteps => _result?.steps.length ?? 0;
  PlayState get state => _state;
  double get speed => _speed;
  bool get isPlaying => _state == PlayState.playing;
  bool get inserting => _inserting;
  int? get monkeyNode => _monkey;
  StepKind? get lastKind => _lastKind;
  String get note => _note;
  List<int> get output => _output;
  List<int> get trail => _trail;
  Set<String> get pathEdges => _pathEdges;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _wait(int ms) =>
      Future.delayed(Duration(milliseconds: (ms / _speed).round()));

  void _clearProgress() {
    _result = null;
    _cursor = 0;
    _state = PlayState.idle;
    _output.clear();
    _trail.clear();
    _pathEdges.clear();
    _lastKind = null;
  }

  // ------------------------------------------------------- Construir árbol

  /// Agrega un valor con animación (el mono baja hasta su lugar).
  /// Devuelve un mensaje de error o null si todo salió bien.
  Future<String?> addValue(int v) async {
    if (isPlaying || _inserting) return 'Espera a que termine la animación.';
    if (v < minValue || v > maxValue) {
      return 'Usa enteros entre $minValue y $maxValue.';
    }
    if (_tree.contains(v)) return 'El $v ya está en el árbol.';
    if (_tree.size >= maxNodes) return 'Máximo $maxNodes nodos.';

    _clearProgress();
    final run = ++_runId;
    _inserting = true;
    _note = _tree.root == null
        ? 'El mono planta la raíz $v.'
        : 'El mono busca dónde colgar el $v…';
    _emit();

    for (final id in _tree.insertPath(v)) {
      _monkey = id;
      _emit();
      await _wait(450);
      if (run != _runId) return null;
    }

    _tree.insert(v);
    _values.add(v);
    _monkey = v;
    _inserting = false;
    _note = 'El $v quedó colgado en el árbol.';
    _emit();
    return null;
  }

  /// Reemplaza todo el árbol de golpe (aleatorio, cargar, limpiar).
  void setValues(List<int> vals) {
    _runId++;
    _inserting = false;
    _clearProgress();
    _tree = BinaryTree();
    _values.clear();
    for (final v in vals) {
      if (_tree.size >= maxNodes) break;
      if (_tree.insert(v)) _values.add(v);
    }
    _monkey = _tree.root?.value;
    _note = _values.isEmpty
        ? 'Planta el primer número: será la raíz del árbol.'
        : 'Árbol listo (${_values.length} nodos). Elige un recorrido y suelta al mono.';
    _emit();
  }

  void clear() => setValues(const []);

  // ----------------------------------------------------------- Recorrido

  void setType(TraversalType t) {
    if (isPlaying || _inserting) return;
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
    if (_inserting || isPlaying) return;
    if (_tree.root == null) {
      _note = 'Primero planta al menos un número.';
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
    if (_inserting || _tree.root == null || isPlaying) return;
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
    _inserting = false;
    _clearProgress();
    _monkey = _tree.root?.value;
    _note = 'Todo listo para un nuevo recorrido.';
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

  /// Restaura árbol, recorrido elegido y el paso exacto en que se guardó.
  void loadSaved(SavedTree s) {
    setValues(s.values);
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