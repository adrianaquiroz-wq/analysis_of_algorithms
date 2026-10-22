import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/screens/insertion_sort_screen.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/insertion_sort_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo insertionSortInfo = SortingInfo(
  id: 'insertion_sort',
  title: 'Insertion Sort',
  subtitle: 'Inserción directa paso a paso · O(n²)',
  icon: Icons.format_line_spacing_rounded,
  theory:
      'Insertion Sort (Ordenamiento por Inserción) es un algoritmo intuitivo '
      'que construye la lista ordenada de manera incremental, un elemento a la '
      'vez. Divide conceptualmente la lista en dos partes: un prefijo izquierdo '
      'que ya está ordenado y el resto por ordenar. En cada pasada, extrae el '
      'siguiente elemento (clave), lo compara hacia atrás con los elementos ya '
      'ordenados desplazándolos hacia la derecha, y lo inserta en su posición '
      'definitiva. Es especialmente eficiente para listas pequeñas o que ya '
      'se encuentran casi ordenadas, alcanzando en esos casos un costo lineal O(n).',
  steps: [
    'El primer elemento (posición 0) se considera trivialmente ordenado por sí solo.',
    'Para cada posición i desde 1 hasta n - 1, se toma el elemento como la "clave" actual.',
    'Se compara la clave hacia la izquierda con los elementos ordenados: aquellos mayores (en orden ascendente) se desplazan un lugar a la derecha.',
    'Cuando se encuentra un elemento menor o igual (o el inicio de la lista), la clave se inserta en el espacio liberado.',
    'Complejidad: O(n) en el mejor caso (ya ordenada), O(n²) en caso promedio y peor caso; espacio auxiliar O(1). Es un algoritmo estable.',
  ],
  previewBuilder: (_) => const InsertionSortPreview(),
  screenBuilder: (_) => const InsertionSortScreen(),
);

