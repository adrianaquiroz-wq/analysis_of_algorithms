/// Tipos de pasos que ocurren durante la ejecución de Insertion Sort.
enum InsertionStepType {
  /// Se extrae y eleva el panda clave en la posición [keySlot].
  pickKey,

  /// Se compara el panda clave con el vecino de la izquierda [compareSlot].
  compare,

  /// El vecino izquierdo se desplaza un lugar a la derecha ([shiftFromSlot] -> [shiftToSlot]).
  shift,

  /// El panda clave desciende e ingresa a su posición final [insertSlot].
  insert,

  /// Fin de la pasada: el prefijo hasta [sortedUpTo] ya se encuentra ordenado.
  passDone,
}

/// Un evento registrado durante la ejecución de Insertion Sort.
class InsertionSortStep {
  final InsertionStepType type;

  /// ID del panda clave que se está insertando.
  final int keyId;
  final int keyValue;
  final int keySlot;

  /// Panda con el que se compara a la izquierda (en pasos `compare`).
  final int? compareId;
  final int? compareValue;
  final int? compareSlot;

  /// true si el elemento comparado debe moverse a la derecha.
  final bool shouldShift;

  /// Desplazamiento del vecino izquierdo hacia la derecha (en pasos `shift`).
  final int? shiftFromSlot;
  final int? shiftToSlot;

  /// Posición donde aterriza la clave (en pasos `insert`).
  final int? insertSlot;

  /// Índice hasta el cual la lista está completamente ordenada (frontera).
  final int sortedUpTo;

  /// Explicación pedagógica de lo que ocurre en este paso.
  final String note;

  const InsertionSortStep({
    required this.type,
    required this.keyId,
    required this.keyValue,
    required this.keySlot,
    this.compareId,
    this.compareValue,
    this.compareSlot,
    this.shouldShift = false,
    this.shiftFromSlot,
    this.shiftToSlot,
    this.insertSlot,
    required this.sortedUpTo,
    required this.note,
  });
}

/// Resultado completo de ejecutar Insertion Sort.
class InsertionSortResult {
  final List<int> sorted;
  final List<InsertionSortStep> steps;
  final int comparisons;
  final int shifts;
  final double avgMicroseconds;

  const InsertionSortResult({
    required this.sorted,
    required this.steps,
    required this.comparisons,
    required this.shifts,
    required this.avgMicroseconds,
  });
}

/// Algoritmo Insertion Sort puro: no depende de widgets ni animación.
/// Realiza el benchmark de tiempo real y registra la traza de pasos.
class InsertionSortAlgorithm {
  static const int timingRuns = 200;

  static InsertionSortResult run(List<int> input, {required bool descending}) {
    // 1) Tiempo real: promedio de 200 corridas en seco sin logs.
    final watch = Stopwatch()..start();
    for (var r = 0; r < timingRuns; r++) {
      _sortFast(List<int>.of(input), descending);
    }
    watch.stop();

    // 2) Corrida detallada registrando cada paso para la animación.
    final values = List<int>.of(input);
    final ids = List<int>.generate(values.length, (i) => i);
    final steps = <InsertionSortStep>[];

    var comparisons = 0;
    var shifts = 0;

    for (var i = 1; i < ids.length; i++) {
      final keyId = ids[i];
      final keyVal = values[keyId];

      steps.add(
        InsertionSortStep(
          type: InsertionStepType.pickKey,
          keyId: keyId,
          keyValue: keyVal,
          keySlot: i,
          sortedUpTo: i - 1,
          note: 'Panda $keyVal sale de la fila para buscar su lugar entre los ordenados.',
        ),
      );

      var j = i - 1;
      var currentKeySlot = i;

      while (j >= 0) {
        final leftId = ids[j];
        final leftVal = values[leftId];
        comparisons++;

        final outOfOrder = descending ? leftVal < keyVal : leftVal > keyVal;

        steps.add(
          InsertionSortStep(
            type: InsertionStepType.compare,
            keyId: keyId,
            keyValue: keyVal,
            keySlot: currentKeySlot,
            compareId: leftId,
            compareValue: leftVal,
            compareSlot: j,
            shouldShift: outOfOrder,
            sortedUpTo: i - 1,
            note: outOfOrder
                ? '¿$leftVal va después que $keyVal? Sí, el panda $leftVal se desplaza a la derecha.'
                : '¿$leftVal va después que $keyVal? No, $keyVal encontró su posición.',
          ),
        );

        if (!outOfOrder) {
          break;
        }

        // Desplazamiento a la derecha.
        shifts++;
        ids[j + 1] = leftId;
        currentKeySlot = j;

        steps.add(
          InsertionSortStep(
            type: InsertionStepType.shift,
            keyId: keyId,
            keyValue: keyVal,
            keySlot: currentKeySlot,
            compareId: leftId,
            compareValue: leftVal,
            shiftFromSlot: j,
            shiftToSlot: j + 1,
            sortedUpTo: i - 1,
            note: 'Panda $leftVal se mueve a la posición ${j + 1}. El hueco queda en la posición $j.',
          ),
        );

        j--;
      }

      ids[j + 1] = keyId;

      steps.add(
        InsertionSortStep(
          type: InsertionStepType.insert,
          keyId: keyId,
          keyValue: keyVal,
          keySlot: j + 1,
          insertSlot: j + 1,
          sortedUpTo: i,
          note: 'Panda $keyVal se sienta en la posición ${j + 1}.',
        ),
      );

      steps.add(
        InsertionSortStep(
          type: InsertionStepType.passDone,
          keyId: keyId,
          keyValue: keyVal,
          keySlot: j + 1,
          sortedUpTo: i,
          note: 'Los primeros ${i + 1} pandas ya están ordenados.',
        ),
      );
    }

    final sortedResult = [for (final id in ids) values[id]];

    return InsertionSortResult(
      sorted: sortedResult,
      steps: steps,
      comparisons: comparisons,
      shifts: shifts,
      avgMicroseconds: watch.elapsedMicroseconds / timingRuns,
    );
  }

  /// Ordenamiento rápido in-place sin registrar pasos (para timing).
  static void _sortFast(List<int> a, bool descending) {
    for (var i = 1; i < a.length; i++) {
      final key = a[i];
      var j = i - 1;
      if (descending) {
        while (j >= 0 && a[j] < key) {
          a[j + 1] = a[j];
          j--;
        }
      } else {
        while (j >= 0 && a[j] > key) {
          a[j + 1] = a[j];
          j--;
        }
      }
      a[j + 1] = key;
    }
  }
}

