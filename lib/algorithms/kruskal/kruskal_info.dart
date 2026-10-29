import 'package:flutter/material.dart';
import '../algorithm_info.dart';

final AlgorithmInfo kruskalInfo = AlgorithmInfo(
  id: 'kruskal',
  title: 'Kruskal',
  subtitle: 'Árbol de expansión mínima',
  icon: Icons.account_tree_rounded,
  isBipartite: false,
  imageUrl: 'assets/images/simple_graph.png',
  youtubeUrl: '',
  theory: 'Kruskal construye un árbol de expansión mínima ordenando las '
      'aristas por peso y agregando únicamente las que no forman ciclos.',
  requirements: [
    'Grafo no dirigido',
    'Aristas sin bucles',
    'Pesos no negativos',
  ],
);
