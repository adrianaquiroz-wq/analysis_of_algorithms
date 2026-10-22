import 'package:graph_app/algorithms/merge_sort/merge_sort_info.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/insertion_sort_info.dart';
import 'package:graph_app/algorithms/selection_sort/selection_sort_info.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/shell_sort_info.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

export 'package:graph_app/algorithms/sorting/sorting_info.dart';

/// Orden en que aparecen las tarjetas del carrusel de ORDENAMIENTO.
/// Para agregar un método nuevo: crear su *_info.dart y sumarlo aquí.
final List<SortingInfo> sortingAlgorithms = [
  insertionSortInfo,
  selectionSortInfo,
  shellSortInfo,
  mergeSortInfo,
];
