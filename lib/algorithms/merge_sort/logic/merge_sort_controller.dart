import 'package:flutter/foundation.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

import 'merge_sort_algorithm.dart';

export 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart'
    show PlayState;

enum MergePhase { idle, dividing, merging, done }

class ActiveSplit {
  final int lo;
  final int mid;
  final int hi;
  final int depth;
  const ActiveSplit(this.lo, this.mid, this.hi, this.depth);

  @override
  bool operator ==(Object other) =>
      other is ActiveSplit &&
      other.lo == lo &&
      other.mid == mid &&
      other.hi == hi &&
      other.depth == depth;

  @override
  int get hashCode => Object.hash(lo, mid, hi, depth);
}

/// Estado de la animación. Reproduce de corrido los eventos que registró
/// [MergeSortAlgorithm]; la pantalla solo escucha y dibuja.
///
class MergeSortController extends ChangeNotifier {
  /// Números con los que arranca Merge Sort (cámbialos a tu gusto, 1 a 100).
  static const List<int> defaultValues = [1, 2, 5, 9, 12, 20, 25, 45];

  List<int> _values = List.of(defaultValues);
  late List<int> _row = List.filled(_values.length, 0);
  late List<int> _slot = List.generate(_values.length, (i) => i);
  bool _descending = false;
  double _speed = 1;
  PlayState _state = PlayState.idle;
  MergePhase _phase = MergePhase.idle;
  MergeSortResult? _result;
  int _cursor = 0;
  int _runId = 0;

  final Set<int> _boundaries = {};
  final List<ActiveSplit> _splits = [];
  ActiveSplit? _newSplit;
  int _splitSerial = 0;

  // Lo que se está haciendo ahora mismo.
  Set<int> _comparing = {};
  int? _placedId;
  int _placeSerial = 0;
  int _depth = 0;
  String? _note;
  int _doneComparisons = 0;
  int _doneMoves = 0;

  List<int> get values => _values;

  /// row[id] = fila (nivel) en la que está el patito id.
  List<int> get rows => _row;

  /// slot[id] = posición horizontal del patito id dentro de su fila.
  List<int> get slots => _slot;

  /// Posiciones donde hay un corte entre segmentos (la mitad de cada split).
  Set<int> get boundaries => _boundaries;

  /// Segmentos partidos que aún no se han fusionado.
  List<ActiveSplit> get splits => _splits;

  /// El split que acaba de ocurrir (la corriente se dibuja animada).
  ActiveSplit? get newSplit => _newSplit;

  /// Cambia con cada split: sirve para reiniciar la animación de la corriente.
  int get splitSerial => _splitSerial;

  /// Patitos que se están comparando.
  Set<int> get comparing => _comparing;

  /// El patito que acaba de entrar a su lugar en la fusión (suelta destello).
  int? get placedId => _placedId;
  int get placeSerial => _placeSerial;

  MergePhase get phase => _phase;
  int get depth => _depth;
  String? get note => _note;
  int get levels => MergeSortAlgorithm.levelsFor(_values.length);
  int get comparisonsSoFar => _doneComparisons;
  int get movesSoFar => _doneMoves;
  bool get descending => _descending;
  double get speed => _speed;
  PlayState get state => _state;
  MergeSortResult? get result => _result;
  bool get isPlaying => _state == PlayState.playing;

  /// Duración del nado de un patito entre dos posiciones.
  Duration get moveDuration => Duration(milliseconds: (640 / _speed).round());

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
    _result = MergeSortAlgorithm.run(_values, descending: _descending);
    _state = PlayState.playing;
    _phase = MergePhase.dividing;
    notifyListeners();
    _play();
  }

  void pause() {
    if (_state != PlayState.playing) return;
    _runId++;
    _state = PlayState.paused;
    _comparing = {};
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

  void _resetState() {
    _runId++;
    _row = List.filled(_values.length, 0);
    _slot = List.generate(_values.length, (i) => i);
    _boundaries.clear();
    _splits.clear();
    _newSplit = null;
    _comparing = {};
    _placedId = null;
    _cursor = 0;
    _depth = 0;
    _note = null;
    _result = null;
    _doneComparisons = 0;
    _doneMoves = 0;
    _phase = MergePhase.idle;
    _state = PlayState.idle;
  }

  /// Valores de los patitos que están en la fila [row], posiciones [lo, hi),
  /// en el orden en que están sentados.
  List<int> _valuesAt(int row, int lo, int hi) {
    final out = List<int?>.filled(hi - lo, null);
    for (var id = 0; id < _values.length; id++) {
      if (_row[id] == row && _slot[id] >= lo && _slot[id] < hi) {
        out[_slot[id] - lo] = _values[id];
      }
    }
    return out.whereType<int>().toList();
  }

  String _fmt(List<int> v) => '[${v.join(', ')}]';

  /// Aplica un evento al estado y devuelve cuánto hay que esperar.
  Duration _apply(MergeEvent e) {
    final move = moveDuration;
    _placedId = null;

    switch (e.kind) {
      case MergeEventKind.split:
        _phase = MergePhase.dividing;
        _depth = e.depth;
        _comparing = {};
        final before = _valuesAt(e.depth, e.lo, e.hi);
        for (var id = 0; id < _values.length; id++) {
          if (_row[id] == e.depth && _slot[id] >= e.lo && _slot[id] < e.hi) {
            _row[id] = e.depth + 1;
          }
        }
        _boundaries.add(e.mid);
        final s = ActiveSplit(e.lo, e.mid, e.hi, e.depth);
        _splits.add(s);
        _newSplit = s;
        _splitSerial++;
        final half = e.mid - e.lo;
        _note =
            'Dividir ${_fmt(before)} en ${_fmt(before.sublist(0, half))} '
            'y ${_fmt(before.sublist(half))}';
        return move + const Duration(milliseconds: 120);

      case MergeEventKind.compare:
        _phase = MergePhase.merging;
        _depth = e.depth;
        _comparing = {e.leftId, e.rightId};
        _doneComparisons++;
        final a = _values[e.leftId];
        final b = _values[e.rightId];
        final leftWins = _descending ? a >= b : a <= b;
        _note =
            'Comparar $a y $b: pasa ${leftWins ? a : b} '
            '(${_descending ? 'el mayor' : 'el menor'})';
        return Duration(milliseconds: (move.inMilliseconds * 0.6).round());

      case MergeEventKind.place:
        _phase = MergePhase.merging;
        _depth = e.depth;
        _comparing = {};
        _row[e.id] = e.depth;
        _slot[e.id] = e.slot;
        _placedId = e.id;
        _placeSerial++;
        _doneMoves++;
        if (e.leftover) {
          _note =
              'Sobra ${_values[e.id]} de la mitad '
              '${e.fromLeft ? 'izquierda' : 'derecha'}: pasa directo';
        }
        return Duration(milliseconds: (move.inMilliseconds * 0.95).round());

      case MergeEventKind.merged:
        _phase = MergePhase.merging;
        _depth = e.depth;
        _comparing = {};
        _boundaries.remove(e.mid);
        _splits.remove(ActiveSplit(e.lo, e.mid, e.hi, e.depth));
        _note =
            'Fusionado: ${_fmt(_valuesAt(e.depth, e.lo, e.hi))} '
            'ya está en orden';
        return Duration(milliseconds: (move.inMilliseconds * 0.7).round());
    }
  }

  Future<void> _play() async {
    final run = ++_runId;
    final events = _result!.events;

    while (_cursor < events.length) {
      final wait = _apply(events[_cursor]);
      _cursor++; // aquí, para que pausar no repita ni se salte el paso
      notifyListeners();
      await Future<void>.delayed(wait);
      if (run != _runId) return;
    }

    _comparing = {};
    _placedId = null;
    _phase = MergePhase.done;
    _note = events.isEmpty
        ? 'No había nada que ordenar.'
        : 'Lista ordenada: ${_fmt(_result!.sorted)}';
    _state = PlayState.done;
    notifyListeners();
  }

  @override
  void dispose() {
    _runId++;
    super.dispose();
  }
}
