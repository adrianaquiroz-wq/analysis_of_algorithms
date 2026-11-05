import 'package:graph_app/algorithms/sorting/sorting_info.dart';
import 'package:graph_app/screens/graph/graph_screen.dart';
import 'package:flutter/material.dart';

/// Tarjetas del apartado DIJKSTRA Y KRUSKAL de la pantalla principal.
///
/// Para agregar un algoritmo:
///  1. Crear su archivo, por ejemplo `dijkstra_kruskal/dijkstra_info.dart`, con
///     un `final SortingInfo dijkstraInfo = SortingInfo(...)` (mismo formato
///     que `shell_sort_info.dart`: título, teoría, pasos y la pantalla en
///     `screenBuilder`).
///  2. Importarlo aquí y sumarlo a la lista:
///       import 'package:graph_app/algorithms/dijkstra_kruskal/dijkstra_info.dart';
///       final lista de tarjetas = [dijkstraInfo, kruskalInfo];
final List<SortingInfo> dijkstraKruskalAlgorithms = [
  SortingInfo(
    id: 'dijkstra',
    title: 'Dijkstra',
    subtitle: 'Ruta óptima en grafos dirigidos ponderados',
    icon: Icons.route_rounded,
    theory: 'Encuentra la ruta de menor o mayor costo entre un origen y '
        'un destino usando pesos positivos y aristas dirigidas.',
    steps: [
      'Selecciona el nodo de inicio y el nodo final.',
      'Elige si deseas minimizar o maximizar la distancia.',
      'Ejecuta la animación y observa la ruta resaltada.',
    ],
    screenBuilder: (_) => const GraphScreen(
      algorithmType: 'dijkstra',
      algorithmTitle: 'Dijkstra',
    ),
  ),
  SortingInfo(
    id: 'kruskal',
    title: 'Kruskal',
    subtitle: 'Árbol de expansión mínima o máxima',
    icon: Icons.account_tree_rounded,
    theory: 'Construye un árbol de expansión seleccionando aristas por peso '
        'y evitando ciclos.',
    steps: [
      'Crea un grafo con aristas sin dirección.',
      'Elige minimizar o maximizar el peso total.',
      'Ejecuta la animación para ver las aristas seleccionadas.',
    ],
    screenBuilder: (_) => const GraphScreen(
      algorithmType: 'kruskal',
      algorithmTitle: 'Kruskal',
    ),
  ),
];
