import 'package:graph_app/algorithms/assignment/models/matrix_step.dart';

class MatrixResult {
  final List<String> rowNames;
  final List<String> colNames;
  final List<List<double>> originalMatrix;
  final List<List<double>> finalMatrix;
  final double optimalValue;
  final String calculationSteps;
  final List<String> assignments;

  /// Pares (fila, columna) óptimos, para marcarlos en la matriz original.
  final List<MapEntry<int, int>> assignmentPairs;
  final List<MatrixStep> stepByStep;

  const MatrixResult({
    required this.rowNames,
    required this.colNames,
    required this.originalMatrix,
    required this.finalMatrix,
    required this.optimalValue,
    required this.calculationSteps,
    required this.assignments,
    required this.stepByStep,
    this.assignmentPairs = const [],
  });

  /// Resultado vacío con un mensaje de error en [calculationSteps].
  factory MatrixResult.empty(String message) => MatrixResult(
    rowNames: const [],
    colNames: const [],
    originalMatrix: const [],
    finalMatrix: const [],
    optimalValue: 0.0,
    calculationSteps: message,
    assignments: const [],
    stepByStep: const [],
  );
}
