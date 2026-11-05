import 'algorithm_info.dart';
import 'assignment/assignment_info.dart';
import 'cpm/cpm_info.dart';
import 'northwest/northwest_info.dart';
import 'simple_graph/simple_graph_info.dart';

export 'algorithm_info.dart';

/// Orden en que aparecen las tarjetas del carrusel de GRAFOS.
final List<AlgorithmInfo> graphAlgorithms = [
  simpleGraphInfo,
  assignmentInfo,
  cpmInfo,
  northwestInfo,
];

/// Devuelve el método cuyo botón flotante debe verse en el lienzo.
AlgorithmInfo? solverFor(
  String algorithmType, {
  required bool isLinearFlow,
  required bool isBipartiteFlow,
}) {
  if (algorithmType == 'cpm') return cpmInfo;
  if (algorithmType == 'northwest') return northwestInfo;
  if (algorithmType == 'assignment' || isLinearFlow || isBipartiteFlow) {
    return assignmentInfo;
  }
  return null;
}
