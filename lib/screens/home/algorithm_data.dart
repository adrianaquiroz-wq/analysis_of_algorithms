import 'package:flutter/material.dart';

final List<Map<String, dynamic>> graphAlgorithms = [
  {
    'title': 'Simple graph',
    'subtitle': 'Lienzo abierto con un solo tipo de nodo estándar',
    'icon': Icons.hub_rounded,
    'algorithmType': 'free',
    'isBipartite': false,
    'theory':
        'El grafo simple o lienzo libre constituye la estructura fundamental para el modelado de redes y sistemas discretos. '
        'Permite la creación de grafos generales sin restricciones estrictas de conectividad, haciendo uso de un único tipo de nodo estándar. '
        'Es la herramienta ideal para la experimentación abierta, el diseño de topologías de red, el análisis exploratorio de adyacencia '
        'y la representación visual de relaciones generales entre entidades sin la rigurosidad de restricciones matemáticas complejas.',
    'youtubeUrl': 'https://www.youtube.com/watch?v=TU_ENLACE_SIMPLE',
    'imageUrl': 'assets/images/simple_graph.png',
    'requisito': 'Nada',
  },
  {
    'title': 'Allocation algorithm',
    'subtitle': 'Optimización con enfoque húngaro y dos tipos de nodo',
    'icon': Icons.psychology_rounded,
    'algorithmType': 'assignment',
    'isBipartite': true,
    'theory':
        'El algoritmo de asignación, fundamentado en el clásico Método Húngaro, resuelve problemas avanzados de optimización '
        'enfocados en encontrar la distribución más eficiente de recursos (como operarios a tareas, o maquinaria a procesos) minimizando los costos totales '
        'o maximizando los rendimientos. Opera estrictamente bajo una arquitectura bipartita dividida en dos conjuntos de nodos disjuntos (Conjunto A y Conjunto B), '
        'garantizando una correspondencia uno a uno matemáticamente precisa a través de matrices de costos.',
    'youtubeUrl': 'https://www.youtube.com/watch?v=AwCyr6srBEg',
    'imageUrl': 'assets/images/assignment.png',
    'requisito':
        'Matriz cuadrada: Debe haber exactamente el mismo número de recursos (ej profesores, máquinas) que de tareas o destinos (ej materias, proyectos). Si tienes 4 profesores y 3 materias, el algoritmo no se puede aplicar directamente.'
        'Objetivo de optimización: El algoritmo está diseñado por defecto para minimizar costos, tiempos o distancias. (Si quieres maximizar ganancias, debes transformar la matriz multiplicando los valores por -1 o restándoles el valor máximo).'
        'El problema: ¿Qué pasa si tienes 4 profesores y solo 3 materias?'
        'La solución: Debes agregar una fila o columna "ficticia" (dummy) con costos en ceros para equilibrar la matriz a un tamaño cuadrado.',
  },
  {
    'title': 'CPM (critical path)',
    'subtitle': 'Planificación de proyectos con un solo tipo de nodo',
    'icon': Icons.memory_rounded,
    'algorithmType': 'cpm',
    'isBipartite': false,
    'theory':
        'El Método del Camino Crítico (CPM) es una técnica analítica de gestión y control empleada para la planificación de proyectos complejos. '
        'Utiliza un único tipo de nodo estándar para modelar las tareas y sus dependencias secuenciales en el tiempo. '
        'Su función principal es calcular la duración total estimada del proyecto mediante la identificación de la ruta más larga de actividades críticas, '
        'determinando con precisión las holguras y los márgenes de flexibilidad operativos para cada fase.',
    'youtubeUrl': 'https://www.youtube.com/watch?v=NGQzWqFE-RY',
    'imageUrl': 'assets/images/cpm.png',
    'requisito':
        'Nodo/Actividad: Cada una de las tareas del proyecto con una duración estimada.'
        'Predecesoras: Tareas que obligatoriamente deben terminar antes de que pueda iniciar otra.'
        'Ruta Crítica: La secuencia de tareas dependientes que tiene la mayor duración total. Si se retrasa cualquier tarea de esta ruta, se retrasa todo el proyecto (su holgura es cero).'
        'Holgura (Float/Slack): El margen de tiempo que se puede retrasar una tarea sin afectar la fecha de finalización del proyecto.',
  },
  {
    'title': 'Northwest Corner',
    'subtitle': 'Heurística de transporte con dos tipos de nodos',
    'icon': Icons.smart_toy_rounded,
    'algorithmType': 'northwest',
    'isBipartite': true,
    'theory':
        'El método de la Esquina Noroeste es una regla heurística fundamental en la investigación de operaciones para resolver problemas de transporte, '
        'generando una solución factible inicial de manera rápida y sistemática. Funciona estructurando una matriz de distribución basada en dos tipos de nodos '
        'que representan la oferta (orígenes) y la demanda (destinos), asignando los flujos de recursos desde la esquina superior izquierda (noroccidental) '
        'hacia las celdas adyacentes hasta agotar las disponibilidades de la red.',
    'youtubeUrl': 'https://www.youtube.com/watch?v=IyogQ4noci0',
    'imageUrl': 'assets/images/northwest.png',
    'requisito':
        'Orígenes (Oferta): Las fábricas o almacenes que tienen una cantidad limitada de productos disponibles.'
        'Destinos (Demanda): Los clientes o puntos que necesitan una cantidad exacta de productos.'
        'La Esquina Noroeste: Es la celda ubicada más arriba y más a la izquierda de nuestra tabla de transporte.'
        'Cuando la oferta total y la demanda total no son iguales.'
        'Una vez añadida la fila o columna "ficticia", la suma total de la oferta y de la demanda se nivelan, la matriz vuelve a estar cuadrada o rectangular balanceada, y ya puedes aplicar el método de la Esquina Noroeste (o cualquier otro método de transporte) con total normalidad.',
  },
];
