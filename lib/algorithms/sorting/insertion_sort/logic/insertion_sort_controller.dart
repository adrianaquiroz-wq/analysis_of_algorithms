import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

import 'insertion_sort_algorithm.dart';

export 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

/// Controlador de la simulación de Insertion Sort con pandas.
/// Administra el estado de la animación, los pandas levantados/comparados,
/// el desplazamiento con bamboleo, el aplastamiento elástico (squash) al aterrizar
/// y el paso a paso manual.
class InsertionSortController extends ChangeNotifier {
  static const List<int> defaultValues = [45, 12, 85, 32, 8, 64, 19, 50];

  List<int> _values = List.of(defaultValues);
  late List<int> _order = List.generate(_values.length, (i) => i);
  late List<int> _slotOf = List.generate(_values.length, (i) => i);

  bool _descending = false;
  double _speed = 1.0;
  PlayState _state = PlayState.idle;
  InsertionSortResult? _result;

  int _cursor = 0;
  int _runId = 0;

  int? _liftedId;
  int? _comparingId;
  int? _shiftingId;
  int? _squashingId;
  bool? _lastComparisonShift;
  int _sortedUpTo = 0;
  int _activePass = 1;

  int _doneComparisons = 0;
  int _doneShifts = 0;
  String? _note;

  List<int> get values => _values;

  /// _order[slot] = id del panda ubicado en esa posición.
  List<int> get order => _order;

  /// _slotOf[id] = posición actual (horizontal) del panda.
  List<int> get slotOf => _slotOf;

  /// Panda que está flotando arriba (clave a insertar).
  int? get liftedId => _liftedId;

  /// Panda con el que se compara actualmente.
  int? get comparingId => _comparingId;

  /// Panda que se está desplazando a la derecha (para activar tambaleo).
  int? get shiftingId => _shiftingId;

  /// Panda que acaba de aterrizar en la plataforma (para activar efecto squash & stretch).
  int? get squashingId => _squashingId;

  /// true si la última comparación indicó que debe desplazarse.
  bool? get lastComparisonShift => _lastComparisonShift;

  /// Índice hasta el que está ordenada la lista.
  int get sortedUpTo => _sortedUpTo;

  /// Pasada actual (1 a n - 1).
  int get activePass => _activePass;
  int get totalPasses => (_values.length > 1) ? _values.length - 1 : 1;

  int get comparisonsSoFar => _doneComparisons;
  int get shiftsSoFar => _doneShifts;

  String? get note => _note;
  bool get descending => _descending;
  double get speed => _speed;
  PlayState get state => _state;
  InsertionSortResult? get result => _result;
  bool get isPlaying => _state == PlayState.playing;
  bool get isDone => _state == PlayState.done;

  /// Duración de cada fase: calibrada para que el usuario pueda apreciar
  /// claramente la elevación, comparación, desplazamiento y descenso.
  Duration get phaseDuration =>
      Duration(milliseconds: (460 / _speed).round().clamp(120, 1800));

  void setValues(List<int> newValues) {
    _values = List.of(newValues);
    _resetState();
    notifyListeners();
  }

  void setDescending(bool value) {
    if (value == _descending) return;
    _descending = value;
    _resetState();
    notifyListeners();
  }

  void setSpeed(double value) {
    _speed = value;
    notifyListeners();
  }

  void start() {
    if (_state == PlayState.paused) {
      resume();
      return;
    }
    _resetState();
    _result = InsertionSortAlgorithm.run(_values, descending: _descending);
    _state = PlayState.playing;
    notifyListeners();
    _play();
  }

  void pause() {
    if (_state != PlayState.playing) return;
    _runId++;
    _state = PlayState.paused;
    notifyListeners();
  }

  void resume() {
    if (_state != PlayState.paused) return;
    _state = PlayState.playing;
    notifyListeners();
    _play();
  }

  /// Ejecuta un solo paso de la simulación y se detiene en pausa.
  void stepForward() {
    if (_state == PlayState.done) return;
    if (_state == PlayState.idle) {
      _resetState();
      _result = InsertionSortAlgorithm.run(_values, descending: _descending);
      _state = PlayState.paused;
      _cursor = 0;
    }
    if (_result == null || _cursor >= _result!.steps.length) {
      _sortedUpTo = _values.length - 1;
      _liftedId = null;
      _comparingId = null;
      _shiftingId = null;
      _squashingId = null;
      _state = PlayState.done;
      _note = _doneShifts == 0
          ? '¡La lista ya estaba ordenada! (Mejor caso O(n))'
          : '¡Lista ordenada exitosamente!';
      notifyListeners();
      return;
    }

    final s = _result!.steps[_cursor];
    _applyStep(s);
    _cursor++;

    if (_cursor >= _result!.steps.length) {
      _sortedUpTo = _values.length - 1;
      _liftedId = null;
      _comparingId = null;
      _shiftingId = null;
      _squashingId = null;
      _state = PlayState.done;
      _note = _doneShifts == 0
          ? '¡La lista ya estaba ordenada! (Mejor caso O(n))'
          : '¡Lista ordenada exitosamente!';
    }
    notifyListeners();
  }

  void reset() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _runId++;
    final n = _values.length;
    _order = List.generate(n, (i) => i);
    _slotOf = List.generate(n, (i) => i);
    _cursor = 0;
    _liftedId = null;
    _comparingId = null;
    _shiftingId = null;
    _squashingId = null;
    _lastComparisonShift = null;
    _sortedUpTo = 0;
    _activePass = 1;
    _doneComparisons = 0;
    _doneShifts = 0;
    _note = null;
    _result = null;
    _state = PlayState.idle;
  }

  void _applyStep(InsertionSortStep s) {
    _squashingId = null;
    switch (s.type) {
      case InsertionStepType.pickKey:
        _liftedId = s.keyId;
        _activePass = s.keySlot;
        _sortedUpTo = s.sortedUpTo;
        _comparingId = null;
        _shiftingId = null;
        _lastComparisonShift = null;
        _note = s.note;
        break;

      case InsertionStepType.compare:
        _comparingId = s.compareId;
        _shiftingId = null;
        _lastComparisonShift = s.shouldShift;
        _doneComparisons++;
        _note = s.note;
        break;

      case InsertionStepType.shift:
        _doneShifts++;
        final shiftedId = s.compareId!;
        _shiftingId = shiftedId;
        _order[s.shiftToSlot!] = shiftedId;
        _slotOf[shiftedId] = s.shiftToSlot!;
        // El panda clave flota horizontalmente acompañando el nuevo hueco
        _slotOf[s.keyId] = s.shiftFromSlot!;
        _comparingId = null;
        _note = s.note;
        break;

      case InsertionStepType.insert:
        _order[s.insertSlot!] = s.keyId;
        _slotOf[s.keyId] = s.insertSlot!;
        _squashingId = s.keyId;
        _liftedId = null;
        _comparingId = null;
        _shiftingId = null;
        _lastComparisonShift = null;
        _note = s.note;
        break;

      case InsertionStepType.passDone:
        _sortedUpTo = s.sortedUpTo;
        _shiftingId = null;
        _comparingId = null;
        _note = s.note;
        break;
    }
  }

  Future<void> _play() async {
    final run = ++_runId;
    final steps = _result!.steps;

    while (_cursor < steps.length) {
      final s = steps[_cursor];
      _applyStep(s);
      notifyListeners();

      final wait = switch (s.type) {
        InsertionStepType.compare => Duration(
            milliseconds: (phaseDuration.inMilliseconds * 1.15).round(),
          ),
        InsertionStepType.shift => Duration(
            milliseconds: (phaseDuration.inMilliseconds * 1.10).round(),
          ),
        InsertionStepType.insert => Duration(
            milliseconds: (phaseDuration.inMilliseconds * 1.45).round(),
          ),
        InsertionStepType.passDone => Duration(
            milliseconds: (phaseDuration.inMilliseconds * 0.70).round(),
          ),
        InsertionStepType.pickKey => phaseDuration,
      };

      await Future<void>.delayed(wait);
      if (run != _runId) return;

      _cursor++;
    }

    _sortedUpTo = _values.length - 1;
    _liftedId = null;
    _comparingId = null;
    _shiftingId = null;
    _squashingId = null;
    _state = PlayState.done;
    _note = _doneShifts == 0
        ? '¡La lista ya estaba ordenada! (Mejor caso O(n))'
        : '¡Lista ordenada exitosamente!';
    notifyListeners();
  }

  @override
  void dispose() {
    _runId++;
    super.dispose();
  }
}
