enum SelectionStepKind {
  /// Empieza la pasada [pass]: el búho se para en esa posición.
  startPass,

  /// El búho mira la posición [scan] y la compara con el mínimo actual.
  scan,

  /// Termina la pasada: la rana mínima ocupa la posición [pass].
  place,
}

/// Un paso registrado de Selection Sort. Todas las posiciones son slots
/// (lugares de la fila) en el momento en que ocurre el paso.
class SelectionSortStep {
  final SelectionStepKind kind;

  /// Posición que se está completando en esta pasada (frontera).
  final int pass;

  /// scan: posición que se mira.
  final int scan;

  /// Posición del mínimo (después de este paso).
  final int minimum;

  /// scan: posición del mínimo antes de comparar.
  final int against;

  /// scan: true si lo mirado superó al mínimo y pasa a ser el nuevo mínimo.
  final bool newMinimum;

  const SelectionSortStep({
    required this.kind,
    required this.pass,
    this.scan = -1,
    this.minimum = -1,
    this.against = -1,
    this.newMinimum = false,
  });

  /// place: true si el mínimo estaba lejos y hubo que intercambiarlo.
  bool get swapped => kind == SelectionStepKind.place && minimum != pass;
}

class SelectionSortResult {
  final List<num> sorted;

  /// sortedIndices[k] = índice original del elemento que quedó en la
  /// posición k. Sirve para reordenar aristas, filas, etc.
  final List<int> sortedIndices;
  final List<SelectionSortStep> steps;
  final int comparisons;
  final int swaps;
  final double avgMicroseconds;

  const SelectionSortResult({
    required this.sorted,
    required this.sortedIndices,
    required this.steps,
    required this.comparisons,
    required this.swaps,
    required this.avgMicroseconds,
  });
}

/// Selection Sort: en cada pasada busca el mínimo (o el máximo si es
/// descendente) de la parte sin ordenar y lo intercambia con el primero de
/// esa parte. O(n²) en todos los casos, O(1) de espacio, no es estable.
/// No sabe nada de la animación: solo ordena y registra lo que hizo.
class SelectionSortAlgorithm {
  /// Veces que se repite el ordenamiento para medir un tiempo estable.
  static const int timingRuns = 200;

  static SelectionSortResult run(List<num> input, {required bool descending}) {
    // 1) Tiempo real: promedio de varias corridas sin registrar nada.
    final watch = Stopwatch()..start();
    for (var r = 0; r < timingRuns; r++) {
      _sort(List<num>.of(input), descending, null, null);
    }
    watch.stop();

    // 2) Una corrida que registra cada paso para la animación.
    final values = List<num>.of(input);
    final indices = List<int>.generate(values.length, (i) => i);
    final steps = <SelectionSortStep>[];
    final counts = _sort(values, descending, steps, indices);

    return SelectionSortResult(
      sorted: values,
      sortedIndices: indices,
      steps: steps,
      comparisons: counts.$1,
      swaps: counts.$2,
      avgMicroseconds: watch.elapsedMicroseconds / timingRuns,
    );
  }

  /// Comparaciones que siempre hace Selection Sort: n(n-1)/2.
  static int comparisonsFor(int n) => n * (n - 1) ~/ 2;

  /// Ordena [values] in situ y devuelve (comparaciones, intercambios).
  static (int, int) _sort(
    List<num> values,
    bool descending,
    List<SelectionSortStep>? steps,
    List<int>? indices,
  ) {
    var comparisons = 0;
    var swaps = 0;

    for (var i = 0; i < values.length - 1; i++) {
      var minimum = i;
      steps?.add(
        SelectionSortStep(
          kind: SelectionStepKind.startPass,
          pass: i,
          minimum: i,
        ),
      );

      for (var j = i + 1; j < values.length; j++) {
        comparisons++;
        final better = descending
            ? values[j] > values[minimum]
            : values[j] < values[minimum];
        final against = minimum;
        if (better) minimum = j;
        steps?.add(
          SelectionSortStep(
            kind: SelectionStepKind.scan,
            pass: i,
            scan: j,
            minimum: minimum,
            against: against,
            newMinimum: better,
          ),
        );
      }

      if (minimum != i) {
        final tmp = values[i];
        values[i] = values[minimum];
        values[minimum] = tmp;
        if (indices != null) {
          final t = indices[i];
          indices[i] = indices[minimum];
          indices[minimum] = t;
        }
        swaps++;
      }
      steps?.add(
        SelectionSortStep(
          kind: SelectionStepKind.place,
          pass: i,
          minimum: minimum,
        ),
      );
    }
    return (comparisons, swaps);
  }
}
