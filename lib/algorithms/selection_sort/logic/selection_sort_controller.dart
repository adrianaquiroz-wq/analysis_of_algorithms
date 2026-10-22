import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/shared/number_format.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

import 'selection_sort_algorithm.dart';

// Mismo estado de reproducción que los otros ordenamientos, para poder usar
// los mismos controles (empezar / pausar / paso / reiniciar).
export 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

/// Estado de la animación. Reproduce de corrido los pasos que registró
/// [SelectionSortAlgorithm]; la pantalla solo escucha y dibuja.
///
/// Cada rana vive en un lugar (slot) de la fila:
///  - El búho juez recorre la parte sin ordenar buscando a la más pequeña.
///  - Al terminar la pasada, esa rana salta al primer lugar libre y se
///    intercambia con la que estaba ahí.
///  - Ese lugar queda ordenado y la siguiente pasada empieza un lugar más
///    a la derecha.
class SelectionSortController extends ChangeNotifier {
  /// Números con los que arranca (cámbialos a tu gusto).
  static const List<int> defaultValues = [38, 12, 77, 5, 91, 24, 60, 45];

  List<num> _values;
  List<num> _initialValues;
  late List<int> _order = List.generate(_values.length, (i) => i);
  bool _descending = false;
  double _speed = 1;
  PlayState _state = PlayState.idle;
  SelectionSortResult? _result;
  int _cursor = 0;
  int _runId = 0;

  int _sortedCount = 0;
  int? _selectedSlot;
  int? _scanSlot;
  int? _minSlot;
  int? _owlSlot;
  int? _jumperId;
  int _swapSerial = 0;
  int _pass = 0;
  int _comparisonsDone = 0;
  int _swapsDone = 0;
  String? _note;

  SelectionSortController([List<num>? initialValues])
    : _values = List.of(initialValues ?? defaultValues),
      _initialValues = List.of(initialValues ?? defaultValues);

  /// Valores por rana (índice = identidad de la rana, no su lugar).
  List<num> get values => _values;

  /// order[slot] = id de la rana que está en ese lugar.
  List<int> get order => _order;

  /// Cuántos lugares de la izquierda ya están en su posición final.
  int get sortedCount => _sortedCount;
  int? get selectedSlot => _selectedSlot;
  int? get scanSlot => _scanSlot;
  int? get minSlot => _minSlot;

  /// Lugar donde está (o hacia donde va) el búho.
  int? get owlSlot => _owlSlot;

  /// Rana que acaba de saltar (la mínima de la pasada).
  int? get jumperId => _jumperId;
  int get swapSerial => _swapSerial;

  int get pass => _pass;
  int get passTotal => _values.length - 1;
  int get comparisonsDone => _comparisonsDone;
  int get swapsDone => _swapsDone;
  String? get note => _note;

  num? get minimumValue => _minSlot == null ? null : _values[_order[_minSlot!]];

  bool get descending => _descending;
  double get speed => _speed;
  PlayState get state => _state;
  SelectionSortResult? get result => _result;
  bool get isPlaying => _state == PlayState.playing;
  bool get isDone => _state == PlayState.done;

  /// Duración del salto de una rana.
  Duration get jumpDuration => Duration(milliseconds: (760 / _speed).round());

  /// Lo que dura cada mirada del búho.
  Duration get scanDuration => Duration(milliseconds: (240 / _speed).round());

  void setValues(List<num> next) {
    _initialValues = List.of(next);
    _values = List.of(next);
    reset();
  }

  void setDescending(bool next) {
    if (_descending == next) return;
    _descending = next;
    reset();
  }

  void setSpeed(double next) {
    _speed = next;
    notifyListeners();
  }

  /// Ordena y reproduce. Si estaba en pausa, continúa donde se quedó.
  void start() {
    if (_state == PlayState.paused) {
      resume();
      return;
    }
    reset(notify: false);
    _result = SelectionSortAlgorithm.run(_values, descending: _descending);
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

  /// Avanza un solo paso (botón "Paso").
  void stepForward() {
    if (_state == PlayState.done || _state == PlayState.playing) return;
    _result ??= SelectionSortAlgorithm.run(_values, descending: _descending);
    _state = PlayState.paused;
    if (_cursor >= _result!.steps.length) {
      _finish();
    } else {
      _apply(_result!.steps[_cursor++]);
    }
    notifyListeners();
  }

  void reset({bool notify = true}) {
    _runId++;
    _values = List.of(_initialValues);
    _order = List.generate(_values.length, (i) => i);
    _cursor = 0;
    _result = null;
    _sortedCount = 0;
    _selectedSlot = null;
    _scanSlot = null;
    _minSlot = null;
    _owlSlot = null;
    _jumperId = null;
    _pass = 0;
    _comparisonsDone = 0;
    _swapsDone = 0;
    _note = null;
    _state = PlayState.idle;
    if (notify) notifyListeners();
  }

  String _f(num v) => fmtNumber(v.toDouble());

  String _v(int slot) => _f(_values[_order[slot]]);

  /// Aplica un paso al estado y devuelve cuánto hay que esperar.
  Duration _apply(SelectionSortStep s) {
    final word = _descending ? 'mayor' : 'menor';
    _jumperId = null;

    switch (s.kind) {
      case SelectionStepKind.startPass:
        _pass = s.pass + 1;
        _selectedSlot = s.pass;
        _minSlot = s.pass;
        _scanSlot = null;
        _owlSlot = s.pass;
        _note =
            'Pasada $_pass: el búho busca al $word desde el puesto '
            '${s.pass + 1}. Por ahora el candidato es ${_v(s.pass)}.';
        return scanDuration;

      case SelectionStepKind.scan:
        _scanSlot = s.scan;
        _minSlot = s.minimum;
        _owlSlot = s.scan;
        _comparisonsDone++;
        _note = s.newMinimum
            ? '${_v(s.scan)} es $word que ${_v(s.against)}: '
                  'es el nuevo candidato.'
            : '${_v(s.scan)} no es $word que ${_v(s.minimum)}: '
                  'el candidato sigue igual.';
        return scanDuration;

      case SelectionStepKind.place:
        final i = s.pass;
        final m = s.minimum;
        _scanSlot = null;
        _selectedSlot = null;
        _minSlot = null;
        _owlSlot = i;
        if (s.swapped) {
          final a = _order[i];
          final b = _order[m];
          _note =
              'La rana ${_f(_values[b])} salta al puesto '
              '${i + 1} y se intercambia con la ${_f(_values[a])}.';
          _order[i] = b;
          _order[m] = a;
          _jumperId = b;
          _swapSerial++;
          _swapsDone++;
          _sortedCount = i + 1;
          return jumpDuration + const Duration(milliseconds: 160);
        }
        _note =
            'La rana ${_v(i)} ya era la $word: se queda en el puesto '
            '${i + 1}.';
        _sortedCount = i + 1;
        return scanDuration * 2;
    }
  }

  void _finish() {
    _sortedCount = _values.length;
    _scanSlot = null;
    _selectedSlot = null;
    _minSlot = null;
    _owlSlot = null;
    _jumperId = null;
    _state = PlayState.done;
    _note = _result == null || _result!.steps.isEmpty
        ? 'No había nada que ordenar.'
        : 'Carrera terminada: la fila quedó en orden.';
  }

  Future<void> _play() async {
    final run = ++_runId;
    final steps = _result!.steps;

    while (_cursor < steps.length) {
      final wait = _apply(steps[_cursor]);
      _cursor++; // aquí, para que pausar no repita ni se salte el paso
      notifyListeners();
      await Future<void>.delayed(wait);
      if (run != _runId) return;
    }

    _finish();
    notifyListeners();
  }

  @override
  void dispose() {
    _runId++;
    super.dispose();
  }
}
