/// Una comparación entre las posiciones [i] y [j] = i + h.
/// Si [swapped] es true estaban desordenadas y se intercambiaron; si es
/// false ya respetaban el orden y no se movieron.
class SortStep {
  final int i;
  final int j;
  final bool swapped;
  const SortStep(this.i, this.j, this.swapped);

  /// Salto (h) con el que se comparó este par.
  int get gap => j - i;
}

class ShellSortResult {
  final List<int> sorted;

  /// Todas las comparaciones, en orden (las que mueven y las que no).
  final List<SortStep> steps;
  final List<int> gaps;
  final int comparisons;
  final double avgMicroseconds;

  const ShellSortResult({
    required this.sorted,
    required this.steps,
    required this.gaps,
    required this.comparisons,
    required this.avgMicroseconds,
  });

  int get swapCount => steps.where((s) => s.swapped).length;
}

/// Shell Sort con la secuencia de Knuth (1, 4, 13, 40, ...).
/// Peor caso: O(n^(3/2)). No sabe nada de la animación: solo ordena
/// y registra lo que hizo.
class ShellSortAlgorithm {
  /// Veces que se repite el ordenamiento para medir un tiempo estable.
  static const int timingRuns = 200;

  static ShellSortResult run(List<int> input, {required bool descending}) {
    // 1) Tiempo real: promedio de varias corridas sin registrar nada.
    final watch = Stopwatch()..start();
    for (var r = 0; r < timingRuns; r++) {
      _sort(List<int>.of(input), descending, null);
    }
    watch.stop();

    // 2) Una corrida que registra cada comparación para la animación.
    final data = List<int>.of(input);
    final steps = <SortStep>[];
    final comparisons = _sort(data, descending, steps);

    return ShellSortResult(
      sorted: data,
      steps: steps,
      gaps: gapsFor(input.length),
      comparisons: comparisons,
      avgMicroseconds: watch.elapsedMicroseconds / timingRuns,
    );
  }

  /// Solo cuenta las comparaciones (sin tocar [input]). Lo usa el
  /// estimador de complejidad.
  static int comparisonsOf(List<int> input, {required bool descending}) =>
      _sort(List<int>.of(input), descending, null);

  /// Saltos de Knuth en orden decreciente para [n] elementos.
  static List<int> gapsFor(int n) {
    var h = 1;
    while (h < n ~/ 3) {
      h = 3 * h + 1;
    }
    final gaps = <int>[];
    for (var g = h; g >= 1; g ~/= 3) {
      gaps.add(g);
    }
    return gaps;
  }

  /// Ordena [a] in situ y devuelve la cantidad de comparaciones.
  static int _sort(List<int> a, bool descending, List<SortStep>? log) {
    var comparisons = 0;
    for (final h in gapsFor(a.length)) {
      for (var i = h; i < a.length; i++) {
        for (var j = i; j >= h; j -= h) {
          comparisons++;
          final outOfOrder = descending ? a[j - h] < a[j] : a[j - h] > a[j];
          log?.add(SortStep(j - h, j, outOfOrder));
          if (!outOfOrder) break;
          final tmp = a[j];
          a[j] = a[j - h];
          a[j - h] = tmp;
        }
      }
    }
    return comparisons;
  }
}
