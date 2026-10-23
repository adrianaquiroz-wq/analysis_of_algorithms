import 'package:flutter_test/flutter_test.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_algorithm.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_controller.dart';

void main() {
  test('ordena de menor a mayor', () {
    final result = SelectionSortAlgorithm.run(<num>[
      64,
      25,
      12,
      22,
      11,
    ], descending: false);

    expect(result.sorted, [11, 12, 22, 25, 64]);
    expect(result.comparisons, 10);
    expect(result.swaps, 3);
  });

  test('ordena de mayor a menor', () {
    final result = SelectionSortAlgorithm.run(<num>[
      64,
      25,
      12,
      22,
      11,
    ], descending: true);

    expect(result.sorted, [64, 25, 22, 12, 11]);
  });

  test('reinicia el vector a los valores originales', () {
    final controller = SelectionSortController(<num>[4, 1, 3, 2]);

    controller.start();
    controller.reset();

    expect(controller.values, [4, 1, 3, 2]);
    controller.dispose();
  });
}
