import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/screens/merge_sort_screen.dart';
import 'package:graph_app/algorithms/merge_sort/widgets/merge_sort_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo mergeSortInfo = SortingInfo(
  id: 'merge_sort',
  title: 'Merge Sort',
  subtitle: 'Divide y vencerás, fusiona en orden · O(n log n)',
  icon: Icons.call_split_rounded,
  theory:
      'Merge Sort es un algoritmo de divide y vencerás. Parte la lista por la '
      'mitad una y otra vez hasta que cada grupo tiene un solo elemento, que '
      'por sí solo ya está ordenado. Luego fusiona los grupos de dos en dos: '
      'compara los primeros elementos de cada mitad y pasa primero al que '
      'corresponda, hasta reconstruir la lista completa en orden. Siempre '
      'hace log₂ n niveles y cada nivel cuesta n comparaciones como máximo, '
      'así que su costo es O(n log n) en todos los casos.',
  steps: [
    'Dividir: la lista se parte por la mitad, y cada mitad se vuelve a partir, hasta tener grupos de un solo elemento.',
    'Fusionar: dos grupos ordenados se unen comparando sus primeros elementos; el menor (o el mayor, si es descendente) pasa primero.',
    'Cuando una mitad se acaba, lo que queda de la otra se copia directo.',
    'Se repite subiendo nivel por nivel hasta recuperar la lista completa ordenada.',
    'Complejidad: O(n log n) en el mejor, promedio y peor caso; espacio extra O(n). Es un ordenamiento estable.',
  ],
  previewBuilder: (_) => const MergeSortPreview(),
  screenBuilder: (_) => const MergeSortScreen(),
);
