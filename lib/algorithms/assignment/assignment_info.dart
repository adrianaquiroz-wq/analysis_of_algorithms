import 'package:flutter/material.dart';
import 'package:graph_app/utils/graph_flow_handlers.dart';

import '../algorithm_info.dart';

final AlgorithmInfo assignmentInfo = AlgorithmInfo(
  id: 'assignment',
  title: 'Allocation algorithm',
  subtitle: 'Optimización con enfoque húngaro y dos tipos de nodo',
  icon: Icons.psychology_rounded,
  isBipartite: true,
  imageUrl: 'assets/images/assignment.png',
  youtubeUrl: 'https://www.youtube.com/watch?v=AwCyr6srBEg',
  theory:
      'El algoritmo de asignación, fundamentado en el clásico Método Húngaro, resuelve problemas avanzados de optimización '
      'enfocados en encontrar la distribución más eficiente de recursos (como operarios a tareas, o maquinaria a procesos) minimizando los costos totales '
      'o maximizando los rendimientos. Opera estrictamente bajo una arquitectura bipartita dividida en dos conjuntos de nodos disjuntos (Conjunto A y Conjunto B), '
      'garantizando una correspondencia uno a uno matemáticamente precisa a través de matrices de costos.',
  requirements: [
    'Matriz cuadrada: Debe haber exactamente el mismo número de recursos (ej profesores, máquinas) que de tareas o destinos (ej materias, proyectos). Si tienes 4 profesores y 3 materias, el algoritmo no se puede aplicar directamente.',
    'Objetivo de optimización: El algoritmo está diseñado por defecto para minimizar costos, tiempos o distancias. (Si quieres maximizar ganancias, debes transformar la matriz multiplicando los valores por -1 o restándoles el valor máximo).',
    'El problema: ¿Qué pasa si tienes 4 profesores y solo 3 materias?',
    'La solución: Debes agregar una fila o columna "ficticia" (dummy) con costos en ceros para equilibrar la matriz a un tamaño cuadrado.',
  ],
  solver: SolverAction(
    icon: Icons.grid_view_rounded,
    tooltip: 'Ver Matriz / Resultados de Asignación',
    open:
        (
          context,
          controller, {
          required isDarkMode,
          required isLinearFlow,
          required isBipartiteFlow,
        }) => GraphFlowHandlers.handleMatrixButtonPress(
          context: context,
          graphController: controller,
          isDarkMode: isDarkMode,
          isLinearFlow: isLinearFlow,
          isBipartiteFlow: isBipartiteFlow,
        ),
  ),
);
