import 'package:flutter/material.dart';
import 'package:graph_app/utils/graph_flow_handlers.dart';

import '../algorithm_info.dart';

final AlgorithmInfo cpmInfo = AlgorithmInfo(
  id: 'cpm',
  title: 'CPM (critical path)',
  subtitle: 'Planificación de proyectos con un solo tipo de nodo',
  icon: Icons.memory_rounded,
  isBipartite: false,
  imageUrl: 'assets/images/cpm.png',
  youtubeUrl: 'https://www.youtube.com/watch?v=NGQzWqFE-RY',
  theory:
      'El Método del Camino Crítico (CPM) es una técnica analítica de gestión y control empleada para la planificación de proyectos complejos. '
      'Utiliza un único tipo de nodo estándar para modelar las tareas y sus dependencias secuenciales en el tiempo. '
      'Su función principal es calcular la duración total estimada del proyecto mediante la identificación de la ruta más larga de actividades críticas, '
      'determinando con precisión las holguras y los márgenes de flexibilidad operativos para cada fase.',
  requirements: [
    'Nodo/Actividad: Cada una de las tareas del proyecto con una duración estimada.',
    'Predecesoras: Tareas que obligatoriamente deben terminar antes de que pueda iniciar otra.',
    'Ruta Crítica: La secuencia de tareas dependientes que tiene la mayor duración total. Si se retrasa cualquier tarea de esta ruta, se retrasa todo el proyecto (su holgura es cero).',
    'Holgura (Float/Slack): El margen de tiempo que se puede retrasar una tarea sin afectar la fecha de finalización del proyecto.',
  ],
  solver: SolverAction(
    icon: Icons.account_tree_rounded,
    tooltip: 'Método CPM (Ruta Crítica)',
    open: (
      context,
      controller, {
      required isDarkMode,
      required isLinearFlow,
      required isBipartiteFlow,
    }) => GraphFlowHandlers.openCpm(context, controller, isDarkMode),
  ),
);
