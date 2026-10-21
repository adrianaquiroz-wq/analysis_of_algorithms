import 'package:flutter/foundation.dart';

import 'complexity_estimator.dart';
import 'shell_sort_algorithm.dart';
import 'sort_input.dart';

enum PlayState { idle, playing, paused, done }

/// Estado de la animación. Reproduce de corrido las comparaciones que
/// registró [ShellSortAlgorithm]; la pantalla solo escucha y dibuja.
///
///  - Par que ya respeta el orden: se marca en amarillo un instante y no se mueve.
///  - Par desordenado: se levantan los dos, uno salta por encima del otro
///    y luego bajan (3 fases).
class ShellSortController extends ChangeNotifier {
  List<int> _values = List.of(SortInput.defaultValues);
  late List<int> _order = _identity();
  bool _descending = false;
  double _speed = 1;
  PlayState _state = PlayState.idle;
  ShellSortResult? _result;
  ComplexityEstimate? _complexity;
  int _cursor = 0;
  int _runId = 0;

  // Lo que se está comparando ahora mismo.
  Set<int> _movers = {};
  int? _hopper;
  bool _lifted = false;
  int? _activeI;
  int? _activeJ;
  int? _gap;
  String? _note;

  List<int> get values => _values;

  /// order[slot] = índice (en [values]) del pingüino que está en ese slot.
  List<int> get order => _order;

  /// Pingüinos (por índice) que se están comparando.
  Set<int> get movers => _movers;

  /// El pingüino que salta por encima del otro (el que va hacia la derecha).
  int? get hopper => _hopper;

  /// true mientras el par se levanta para intercambiarse.
  bool get lifted => _lifted;

  /// Slots del par que se está comparando.
  int? get activeI => _activeI;
  int? get activeJ => _activeJ;

  /// Salto (h) de la pasada actual.
  int? get gap => _gap;
  String? get note => _note;

  int get passTotal => _result?.gaps.length ?? 0;
  int get passIndex {
    final g = _gap;
    final r = _result;
    return (g == null || r == null) ? 0 : r.gaps.indexOf(g) + 1;
  }

  bool get descending => _descending;
  double get speed => _speed;
  PlayState get state => _state;
  ShellSortResult? get result => _result;
  ComplexityEstimate? get complexity => _complexity;
  bool get isPlaying => _state == PlayState.playing;

  /// Duración de cada fase (marcar, deslizar, bajar).
  Duration get phaseDuration => Duration(milliseconds: (220 / _speed).round());

  List<int> _identity() => List.generate(_values.length, (i) => i);

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

  /// Ordena y reproduce. Si estaba en pausa, continúa donde se quedó.
  void start() {
    if (_state == PlayState.paused) {
      resume();
      return;
    }
    _resetState();
    _result = ShellSortAlgorithm.run(_values, descending: _descending);
    _complexity = ComplexityEstimator.estimate(
      _values,
      descending: _descending,
    );
    _state = PlayState.playing;
    notifyListeners();
    _play();
  }

  void pause() {
    if (_state != PlayState.playing) return;
    _runId++;
    _state = PlayState.paused;
    _clearActive();
    notifyListeners();
  }

  void resume() {
    if (_state != PlayState.paused) return;
    _state = PlayState.playing;
    notifyListeners();
    _play();
  }

  void reset() {
    _resetState();
    notifyListeners();
  }

  void _clearActive() {
    _movers = {};
    _hopper = null;
    _lifted = false;
    _activeI = null;
    _activeJ = null;
  }

  void _resetState() {
    _runId++;
    _order = _identity();
    _cursor = 0;
    _clearActive();
    _gap = null;
    _note = null;
    _result = null;
    _complexity = null;
    _state = PlayState.idle;
  }

  Future<void> _play() async {
    final run = ++_runId;
    final steps = _result!.steps;

    while (_cursor < steps.length) {
      final s = steps[_cursor];
      final a = _order[s.i]; // el de la izquierda (j - h)
      final b = _order[s.j]; // el de la derecha (j)

      // Fase 1: se marca el par con su salto.
      _gap = s.gap;
      _activeI = s.i;
      _activeJ = s.j;
      _movers = {a, b};
      _hopper = s.swapped ? a : null;
      _lifted = s.swapped;
      _note = s.swapped
          ? 'Desordenados: ${_values[a]} ↔ ${_values[b]}, se intercambian'
          : 'En orden: ${_values[a]} y ${_values[b]} se respetan, no se mueven';
      notifyListeners();
      await Future<void>.delayed(phaseDuration);
      if (run != _runId) return;

      if (!s.swapped) {
        // Ya respetaban el orden: solo se avanza a la siguiente comparación.
        _cursor++;
        _clearActive();
        notifyListeners();
        continue;
      }

      // Fase 2: se deslizan a sus nuevas posiciones.
      _order[s.i] = b;
      _order[s.j] = a;
      _cursor++; // aquí, para que pausar no repita ni se salte el paso
      notifyListeners();
      await Future<void>.delayed(phaseDuration);
      if (run != _runId) return;

      // Fase 3: bajan.
      _clearActive();
      notifyListeners();
      await Future<void>.delayed(phaseDuration);
      if (run != _runId) return;
    }

    _gap = null;
    _note = _result!.swapCount == 0
        ? 'La lista ya estaba ordenada.'
        : 'Lista ordenada.';
    _state = PlayState.done;
    notifyListeners();
  }

  @override
  void dispose() {
    _runId++;
    super.dispose();
  }
}
