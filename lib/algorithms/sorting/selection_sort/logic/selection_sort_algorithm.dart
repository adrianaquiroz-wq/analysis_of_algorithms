class SelectionSortStep {
  final int selectedIndex;
  final int scanIndex;
  final int minimumIndex;
  final bool swapped;

  const SelectionSortStep({
    required this.selectedIndex,
    required this.scanIndex,
    required this.minimumIndex,
    required this.swapped,
  });
}

class SelectionSortResult {
  final List<int> sorted;
  final List<SelectionSortStep> steps;
  final int comparisons;
  final int swaps;
  final double avgMicroseconds;

  const SelectionSortResult({
    required this.sorted,
    required this.steps,
    required this.comparisons,
    required this.swaps,
    required this.avgMicroseconds,
  });
}

class SelectionSortAlgorithm {
  static const int timingRuns = 200;

  static SelectionSortResult run(
    List<int> input, {
    required bool descending,
  }) {
    final watch = Stopwatch()..start();
    for (var run = 0; run < timingRuns; run++) {
      _sort(List<int>.of(input), descending, null);
    }
    watch.stop();

    final values = List<int>.of(input);
    final steps = <SelectionSortStep>[];
    final counts = _sort(values, descending, steps);
    return SelectionSortResult(
      sorted: values,
      steps: steps,
      comparisons: counts.$1,
      swaps: counts.$2,
      avgMicroseconds: watch.elapsedMicroseconds / timingRuns,
    );
  }

  static (int, int) _sort(
    List<int> values,
    bool descending,
    List<SelectionSortStep>? steps,
  ) {
    var comparisons = 0;
    var swaps = 0;
    for (var i = 0; i < values.length - 1; i++) {
      var minimum = i;
      for (var j = i + 1; j < values.length; j++) {
        comparisons++;
        final better = descending
            ? values[j] > values[minimum]
            : values[j] < values[minimum];
        if (better) minimum = j;
        steps?.add(
          SelectionSortStep(
            selectedIndex: i,
            scanIndex: j,
            minimumIndex: minimum,
            swapped: false,
          ),
        );
      }
      final swapped = minimum != i;
      if (swapped) {
        final temp = values[i];
        values[i] = values[minimum];
        values[minimum] = temp;
        swaps++;
      }
      steps?.add(
        SelectionSortStep(
          selectedIndex: i,
          scanIndex: minimum,
          minimumIndex: minimum,
          swapped: swapped,
        ),
      );
    }
    return (comparisons, swaps);
  }
}
