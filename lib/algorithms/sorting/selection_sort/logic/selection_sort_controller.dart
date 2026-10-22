import 'package:flutter/foundation.dart';
import 'selection_sort_algorithm.dart';

enum SelectionPlayState { idle, playing, paused, done }

class SelectionSortController extends ChangeNotifier {
  List<int> values;
  bool descending = false;
  double speed = 1;
  SelectionPlayState state = SelectionPlayState.idle;
  SelectionSortResult? result;
  int cursor = 0;
  int? selectedIndex;
  int? scanIndex;
  int? minimumIndex;
  String? note;
  int _runId = 0;

  SelectionSortController(List<int> initialValues) : values = List.of(initialValues);

  bool get isPlaying => state == SelectionPlayState.playing;
  Duration get stepDuration => Duration(milliseconds: (260 / speed).round());

  void setValues(List<int> next) {
    values = List.of(next);
    reset();
  }

  void setDescending(bool next) {
    if (descending == next) return;
    descending = next;
    reset();
  }

  void setSpeed(double next) {
    speed = next;
    notifyListeners();
  }

  void start() {
    if (state == SelectionPlayState.paused) {
      state = SelectionPlayState.playing;
      notifyListeners();
      _play();
      return;
    }
    reset(notify: false);
    result = SelectionSortAlgorithm.run(values, descending: descending);
    state = SelectionPlayState.playing;
    notifyListeners();
    _play();
  }

  void pause() {
    if (!isPlaying) return;
    _runId++;
    state = SelectionPlayState.paused;
    notifyListeners();
  }

  void stepForward() {
    if (state == SelectionPlayState.done) return;
    if (result == null) {
      result = SelectionSortAlgorithm.run(values, descending: descending);
      state = SelectionPlayState.paused;
    }
    if (cursor >= result!.steps.length) {
      state = SelectionPlayState.done;
      note = 'Lista ordenada.';
      notifyListeners();
      return;
    }
    _apply(result!.steps[cursor++]);
    state = SelectionPlayState.paused;
    notifyListeners();
  }

  void reset({bool notify = true}) {
    _runId++;
    cursor = 0;
    result = null;
    selectedIndex = null;
    scanIndex = null;
    minimumIndex = null;
    note = null;
    state = SelectionPlayState.idle;
    if (notify) notifyListeners();
  }

  void _apply(SelectionSortStep step) {
    selectedIndex = step.selectedIndex;
    scanIndex = step.scanIndex;
    minimumIndex = step.minimumIndex;
    note = step.swapped
        ? 'Se coloca el menor elemento restante en la posición ${step.selectedIndex}.'
        : 'Se busca el menor elemento desde la posición ${step.selectedIndex}.';
  }

  Future<void> _play() async {
    final run = ++_runId;
    while (result != null && cursor < result!.steps.length) {
      _apply(result!.steps[cursor++]);
      notifyListeners();
      await Future<void>.delayed(stepDuration);
      if (run != _runId) return;
    }
    if (run != _runId) return;
    state = SelectionPlayState.done;
    note = 'Lista ordenada.';
    notifyListeners();
  }
}
