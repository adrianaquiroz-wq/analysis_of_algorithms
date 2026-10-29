import 'package:flutter/material.dart';
import '../algorithm_info.dart';

final AlgorithmInfo dijkstraInfo = AlgorithmInfo(
  id: 'dijkstra',
  title: 'Dijkstra',
  subtitle: 'Ruta óptima en grafos dirigidos ponderados',
  icon: Icons.route_rounded,
  isBipartite: false,
  imageUrl: 'assets/images/simple_graph.png',
  youtubeUrl: '',
  theory: 'Dijkstra encuentra la ruta de menor o mayor costo, según el '
      'objetivo elegido, desde un nodo origen hasta un nodo destino. '
      'Selecciona repetidamente el nodo no visitado con menor distancia y '
      'relaja sus aristas salientes.',
  requirements: [
    'Grafo dirigido',
    'Pesos positivos en todas las aristas',
    'Seleccionar un nodo origen y un nodo destino',
    'No se permiten bucles',
  ],
);
