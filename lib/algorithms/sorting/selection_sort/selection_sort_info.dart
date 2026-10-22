import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/selection_sort/screens/selection_sort_screen.dart';
import 'package:graph_app/algorithms/sorting/selection_sort/widgets/selection_sort_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo selectionSortInfo = SortingInfo(
  id: 'selection_sort',
  title: 'Selection Sort',
  subtitle: 'Selección del mínimo · O(n²)',
  icon: Icons.filter_alt_rounded,
  theory: 'Selection Sort recorre la parte no ordenada, encuentra el menor '
      'elemento y lo intercambia con el primero de esa parte. Repite el '
      'proceso hasta que toda la lista queda ordenada.',
  steps: [
    'Se considera ordenada la parte izquierda de la lista.',
    'Se busca el menor elemento en la parte que todavía no está ordenada.',
    'El menor elemento se intercambia con el primero de la parte no ordenada.',
    'Complejidad: O(n²) en todos los casos y espacio auxiliar O(1). No es estable.',
  ],
  previewBuilder: (_) => const SelectionSortPreview(),
  screenBuilder: (_) => const SelectionSortScreen(),
);
