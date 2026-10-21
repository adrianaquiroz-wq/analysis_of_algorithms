import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/screens/shell_sort_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/shell_sort_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo shellSortInfo = SortingInfo(
  id: 'shell_sort',
  title: 'Shell Sort',
  subtitle: 'Inserción con saltos decrecientes · O(n^(3/2))',
  icon: Icons.sort_rounded,
  theory:
      'Shell Sort es una mejora del ordenamiento por inserción. En lugar de '
      'comparar solo elementos vecinos, compara elementos separados por un '
      '"salto" (gap) y lo va reduciendo hasta llegar a 1. Así, los elementos '
      'muy desordenados viajan grandes distancias desde el principio y, '
      'cuando el salto es 1, la lista ya está casi ordenada y el último pase '
      'es muy rápido. Con la secuencia de Knuth (1, 4, 13, 40, ...) su peor '
      'caso es O(n^(3/2)).',
  steps: [
    'Se elige una secuencia de saltos. Aquí se usa la de Knuth: 1, 4, 13, 40...',
    'Para cada salto h, de mayor a menor, se ordenan por inserción los elementos que están separados h posiciones.',
    'Se repite reduciendo h hasta llegar a h = 1, que es una inserción sobre una lista casi ordenada.',
    'Complejidad: peor caso O(n^(3/2)), mejor caso O(n log n), espacio O(1). No es un ordenamiento estable.',
  ],
  previewBuilder: (_) => const ShellSortPreview(),
  screenBuilder: (_) => const ShellSortScreen(),
);
