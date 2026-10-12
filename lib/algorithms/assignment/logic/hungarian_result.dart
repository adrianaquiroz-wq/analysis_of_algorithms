import 'package:graph_app/algorithms/assignment/models/matrix_step.dart';

class HungarianResult {
  final List<List<double>> finalMatrix;
  final List<Map<String, int>> assignments; // {'r': fila, 'c': columna}
  final List<MatrixStep> steps;

  const HungarianResult({
    required this.finalMatrix,
    required this.assignments,
    required this.steps,
  });
}
