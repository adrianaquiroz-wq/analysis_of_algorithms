import 'package:graph_app/algorithms/sorting/sorting_info.dart';

/// Tarjetas del apartado DIJKSTRA Y KRUSKAL de la pantalla principal.
///
/// Para agregar un algoritmo:
///  1. Crear su archivo, p. ej. `dijkstra_kruskal/dijkstra_info.dart`, con
///     un `final SortingInfo dijkstraInfo = SortingInfo(...)` (mismo formato
///     que `shell_sort_info.dart`: título, teoría, pasos y la pantalla en
///     `screenBuilder`).
///  2. Importarlo aquí y sumarlo a la lista:
///       import 'package:graph_app/algorithms/dijkstra_kruskal/dijkstra_info.dart';
///       final List<SortingInfo> dijkstraKruskalAlgorithms = [dijkstraInfo, kruskalInfo];
final List<SortingInfo> dijkstraKruskalAlgorithms = [];
