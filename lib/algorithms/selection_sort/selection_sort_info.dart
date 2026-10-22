import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/selection_sort/screens/selection_sort_screen.dart';
import 'package:graph_app/algorithms/selection_sort/widgets/selection_sort_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo selectionSortInfo = SortingInfo(
  id: 'selection_sort',
  title: 'Selection Sort',
  subtitle: 'Selección del mínimo, una pasada a la vez · O(n²)',
  icon: Icons.filter_alt_rounded,
  theory:
      'Selection Sort divide la lista en dos partes: una izquierda ya '
      'ordenada y una derecha por ordenar. En cada pasada recorre toda la '
      'parte por ordenar para encontrar el elemento más pequeño y lo '
      'intercambia con el primero de esa parte; así, ese lugar queda '
      'definitivo y la frontera avanza una posición. Hace siempre n(n−1)/2 '
      'comparaciones, pero a lo sumo n−1 intercambios, lo que lo hace útil '
      'cuando mover elementos es caro.',
  steps: [
    'La parte izquierda de la lista se considera ordenada (al inicio está vacía).',
    'Se recorre la parte sin ordenar comparando cada elemento con el mínimo encontrado hasta ahora.',
    'Al terminar el recorrido, el mínimo se intercambia con el primer elemento de la parte sin ordenar.',
    'La frontera avanza una posición y se repite hasta que solo queda un elemento.',
    'Complejidad: O(n²) en el mejor, promedio y peor caso; espacio extra O(1). No es estable.',
  ],
  previewBuilder: (_) => const SelectionSortPreview(),
  screenBuilder: (_) => const SelectionSortScreen(),
);
