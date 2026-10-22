import 'dart:math';

enum MergeEventKind {
  /// Un segmento [lo, hi) se parte en [lo, mid) y [mid, hi).
  split,

  /// Se comparan las cabezas de las dos mitades que se fusionan.
  compare,

  /// Un patito entra a su posición final dentro del segmento fusionado.
  place,

  /// Terminó la fusión del segmento [lo, hi).
  merged,
}

/// Un paso registrado de Merge Sort. Los patitos se identifican por su
/// índice original en la lista de valores ([id]).
class MergeEvent {
  final MergeEventKind kind;
  final int lo;
  final int mid;
  final int hi;

  /// Profundidad del segmento (0 = lista completa).
  final int depth;

  /// compare: cabezas izquierda y derecha. place: [id] es el que entra.
  final int leftId;
  final int rightId;
  final int id;

  /// place: posición (slot) final del patito dentro de la fila fusionada.
  final int slot;

  /// place: true si venía de la mitad izquierda.
  final bool fromLeft;

  /// place: true si ya no había nada que comparar (se copia lo que sobra).
  final bool leftover;

  const MergeEvent._(
    this.kind, {
    this.lo = 0,
    this.mid = 0,
    this.hi = 0,
    this.depth = 0,
    this.leftId = -1,
    this.rightId = -1,
    this.id = -1,
    this.slot = -1,
    this.fromLeft = false,
    this.leftover = false,
  });

  const MergeEvent.split(int lo, int mid, int hi, int depth)
    : this._(MergeEventKind.split, lo: lo, mid: mid, hi: hi, depth: depth);

  const MergeEvent.compare(
    int lo,
    int mid,
    int hi,
    int depth,
    int leftId,
    int rightId,
  ) : this._(
        MergeEventKind.compare,
        lo: lo,
        mid: mid,
        hi: hi,
        depth: depth,
        leftId: leftId,
        rightId: rightId,
      );

  const MergeEvent.place(
    int lo,
    int mid,
    int hi,
    int depth,
    int id,
    int slot, {
    required bool fromLeft,
    required bool leftover,
  }) : this._(
         MergeEventKind.place,
         lo: lo,
         mid: mid,
         hi: hi,
         depth: depth,
         id: id,
         slot: slot,
         fromLeft: fromLeft,
         leftover: leftover,
       );

  const MergeEvent.merged(int lo, int mid, int hi, int depth)
    : this._(MergeEventKind.merged, lo: lo, mid: mid, hi: hi, depth: depth);
}

class MergeSortResult {
  final List<int> sorted;
  final List<MergeEvent> events;
  final int comparisons;

  /// Cuántas veces un patito se coloca en su posición fusionada.
  final int moves;

  /// Filas necesarias para dibujar todos los niveles (profundidad máxima + 1).
  final int levels;
  final double avgMicroseconds;

  const MergeSortResult({
    required this.sorted,
    required this.events,
    required this.comparisons,
    required this.moves,
    required this.levels,
    required this.avgMicroseconds,
  });
}

/// Merge Sort descendente-recursivo (divide y vencerás), estable.
/// Peor caso: O(n log n). No sabe nada de la animación: solo ordena y
/// registra lo que hizo.
class MergeSortAlgorithm {
  /// Veces que se repite el ordenamiento para medir un tiempo estable.
  static const int timingRuns = 200;

  static MergeSortResult run(List<int> input, {required bool descending}) {
    // 1) Tiempo real: promedio de varias corridas sin registrar nada.
    final watch = Stopwatch()..start();
    for (var r = 0; r < timingRuns; r++) {
      _sort(input, descending, null);
    }
    watch.stop();

    // 2) Una corrida que registra cada evento para la animación.
    final events = <MergeEvent>[];
    final ids = _sort(input, descending, events);
    final moves = events.where((e) => e.kind == MergeEventKind.place).length;

    return MergeSortResult(
      sorted: [for (final id in ids) input[id]],
      events: events,
      comparisons: events.where((e) => e.kind == MergeEventKind.compare).length,
      moves: moves,
      levels: levelsFor(input.length),
      avgMicroseconds: watch.elapsedMicroseconds / timingRuns,
    );
  }

  /// Filas (niveles) que hacen falta para [n] elementos: ceil(log2 n) + 1.
  static int levelsFor(int n) {
    var depth = 0;
    var size = n;
    while (size > 1) {
      size = (size + 1) ~/ 2;
      depth++;
    }
    return depth + 1;
  }

  /// Cota teórica de comparaciones: n * log2(n).
  static double nLogN(int n) => n <= 1 ? 0 : n * (log(n) / ln2);

  /// Ordena y devuelve los ids en el orden final.
  static List<int> _sort(
    List<int> values,
    bool descending,
    List<MergeEvent>? log,
  ) {
    final ids = List<int>.generate(values.length, (i) => i);
    _split(values, ids, 0, ids.length, 0, descending, log);
    return ids;
  }

  static void _split(
    List<int> values,
    List<int> ids,
    int lo,
    int hi,
    int depth,
    bool descending,
    List<MergeEvent>? log,
  ) {
    if (hi - lo <= 1) return;
    final mid = lo + (hi - lo) ~/ 2;
    log?.add(MergeEvent.split(lo, mid, hi, depth));
    _split(values, ids, lo, mid, depth + 1, descending, log);
    _split(values, ids, mid, hi, depth + 1, descending, log);
    _merge(values, ids, lo, mid, hi, depth, descending, log);
  }

  static void _merge(
    List<int> values,
    List<int> ids,
    int lo,
    int mid,
    int hi,
    int depth,
    bool descending,
    List<MergeEvent>? log,
  ) {
    final left = ids.sublist(lo, mid);
    final right = ids.sublist(mid, hi);
    var i = 0, j = 0, k = lo;

    while (i < left.length && j < right.length) {
      final a = left[i];
      final b = right[j];
      log?.add(MergeEvent.compare(lo, mid, hi, depth, a, b));
      // Con empate gana la izquierda: así el ordenamiento es estable.
      final takeLeft = descending
          ? values[a] >= values[b]
          : values[a] <= values[b];
      final id = takeLeft ? a : b;
      if (takeLeft) {
        i++;
      } else {
        j++;
      }
      ids[k] = id;
      log?.add(
        MergeEvent.place(
          lo,
          mid,
          hi,
          depth,
          id,
          k,
          fromLeft: takeLeft,
          leftover: false,
        ),
      );
      k++;
    }

    void drain(List<int> rest, int from, bool fromLeft) {
      for (var x = from; x < rest.length; x++) {
        ids[k] = rest[x];
        log?.add(
          MergeEvent.place(
            lo,
            mid,
            hi,
            depth,
            rest[x],
            k,
            fromLeft: fromLeft,
            leftover: true,
          ),
        );
        k++;
      }
    }

    drain(left, i, true);
    drain(right, j, false);
    log?.add(MergeEvent.merged(lo, mid, hi, depth));
  }
}
