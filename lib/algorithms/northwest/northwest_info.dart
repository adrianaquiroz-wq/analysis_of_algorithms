import 'package:flutter/material.dart';
import 'package:graph_app/utils/graph_flow_handlers.dart';

import '../algorithm_info.dart';

final AlgorithmInfo northwestInfo = AlgorithmInfo(
  id: 'northwest',
  title: 'Northwest Corner',
  subtitle: 'Heurística de transporte con dos tipos de nodos',
  icon: Icons.smart_toy_rounded,
  isBipartite: true,
  imageUrl: 'assets/images/northwest.png',
  youtubeUrl: 'https://www.youtube.com/watch?v=IyogQ4noci0',
  theory:
      'El método de la Esquina Noroeste es una regla heurística fundamental en la investigación de operaciones para resolver problemas de transporte, '
      'generando una solución factible inicial de manera rápida y sistemática. Funciona estructurando una matriz de distribución basada en dos tipos de nodos '
      'que representan la oferta (orígenes) y la demanda (destinos), asignando los flujos de recursos desde la esquina superior izquierda (noroccidental) '
      'hacia las celdas adyacentes hasta agotar las disponibilidades de la red.',
  requirements: [
    'Orígenes (Oferta): Las fábricas o almacenes que tienen una cantidad limitada de productos disponibles.',
    'Destinos (Demanda): Los clientes o puntos que necesitan una cantidad exacta de productos.',
    'La Esquina Noroeste: Es la celda ubicada más arriba y más a la izquierda de nuestra tabla de transporte.',
    'Cuando la oferta total y la demanda total no son iguales.',
    'Una vez añadida la fila o columna "ficticia", la suma total de la oferta y de la demanda se nivelan, la matriz vuelve a estar cuadrada o rectangular balanceada, y ya puedes aplicar el método de la Esquina Noroeste (o cualquier otro método de transporte) con total normalidad.',
  ],
  solver: SolverAction(
    icon: Icons.alt_route_rounded,
    tooltip: 'Esquina Noroeste',
    open:
        (
          context,
          controller, {
          required isDarkMode,
          required isLinearFlow,
          required isBipartiteFlow,
        }) => GraphFlowHandlers.openNorthwestCorner(
          context,
          controller,
          isDarkMode,
        ),
  ),
);
