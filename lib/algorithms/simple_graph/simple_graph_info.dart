import 'package:flutter/material.dart';

import '../algorithm_info.dart';

final AlgorithmInfo simpleGraphInfo = AlgorithmInfo(
  id: 'free',
  title: 'Simple graph',
  subtitle: 'Lienzo abierto con un solo tipo de nodo estándar',
  icon: Icons.hub_rounded,
  isBipartite: false,
  imageUrl: 'assets/images/simple_graph.png',
  youtubeUrl: 'https://www.youtube.com/watch?v=TU_ENLACE_SIMPLE',
  theory:
      'El grafo simple o lienzo libre constituye la estructura fundamental para el modelado de redes y sistemas discretos. '
      'Permite la creación de grafos generales sin restricciones estrictas de conectividad, haciendo uso de un único tipo de nodo estándar. '
      'Es la herramienta ideal para la experimentación abierta, el diseño de topologías de red, el análisis exploratorio de adyacencia '
      'y la representación visual de relaciones generales entre entidades sin la rigurosidad de restricciones matemáticas complejas.',
  requirements: ['Nada'],
);
