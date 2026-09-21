import '../models/node_model.dart';

import '../models/edge_model.dart';

import '../models/matrix_step.dart';

import 'hungarian_algorithm.dart';

class MatrixResult {
  final List<String> rowNames;

  final List<String> colNames;

  final List<List<double>> originalMatrix;

  final List<List<double>> finalMatrix;

  final double optimalValue;

  final String calculationSteps;

  final List<String> assignments;

  final List<MatrixStep> stepByStep;

  MatrixResult({
    required this.rowNames,

    required this.originalMatrix,

    required this.colNames,

    required this.finalMatrix,

    required this.optimalValue,

    required this.calculationSteps,

    required this.assignments,

    required this.stepByStep,
  });
}

class MatrixOptimizerUtils {
  // ASIGNACIÓN BIPARTITA (Conjunto A y Conjunto B con balanceo automático por ceros)

  static MatrixResult solveBipartiteAssignment({
    required List<NodeModel> nodes,

    required List<EdgeModel> edges,

    required bool isMaximization,
  }) {
    final groupA =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.groupA).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    final groupB =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.groupB).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    if (groupA.isEmpty || groupB.isEmpty) {
      return MatrixResult(
        rowNames: [],

        colNames: [],

        originalMatrix: [],

        finalMatrix: [],

        optimalValue: 0.0,

        calculationSteps: "Error: Debes marcar nodos en el Conjunto A y en el Conjunto B para resolver el grafo bipartito.",

        assignments: [],

        stepByStep: [],
      );
    }

    int rows = groupA.length;

    int cols = groupB.length;

    int maxSize = rows > cols ? rows : cols;

    List<String> rowNames = groupA
        .map((n) => n.label.isNotEmpty ? n.label : n.id)
        .toList();

    List<String> colNames = groupB
        .map((n) => n.label.isNotEmpty ? n.label : n.id)
        .toList();

    if (rows < maxSize) {
      for (int i = rows; i < maxSize; i++) {
        rowNames.add("Ficticio_${i + 1}");
      }
    } else if (cols < maxSize) {
      for (int j = cols; j < maxSize; j++) {
        colNames.add("Ficticio_${j + 1}");
      }
    }

    final mapA = {for (int i = 0; i < groupA.length; i++) groupA[i].id: i};

    final mapB = {for (int j = 0; j < groupB.length; j++) groupB[j].id: j};

    List<List<double>> matrix = List.generate(
      maxSize,

      (_) => List.filled(maxSize, 0.0),
    );

    for (var edge in edges) {
      final r = mapA[edge.sourceId];

      final c = mapB[edge.targetId];

      if (r != null && c != null) {
        matrix[r][c] = edge.weight;
      } else {
        final rRev = mapA[edge.targetId];

        final cRev = mapB[edge.sourceId];

        if (rRev != null && cRev != null) {
          matrix[rRev][cRev] = edge.weight;
        }
      }
    }

    final result = HungarianAlgorithm.solve(
      matrix: matrix,

      rowNames: rowNames,

      colNames: colNames,

      isMaximization: isMaximization,
    );

    double optimalSum = 0;

    List<String> assignmentList = [];

    for (var pair in result.assignments) {
      int r = pair['r']!;

      int c = pair['c']!;

      optimalSum += matrix[r][c];

      String origin = rowNames[r];

      String target = colNames[c];

      if (!origin.startsWith("Ficticio") && !target.startsWith("Ficticio")) {
        assignmentList.add(
          "Fila ($origin) ➔ Columna ($target) | Peso: ${matrix[r][c]}",
        );
      }
    }

    StringBuffer stepsText = StringBuffer();

    //stepsText.writeln.call(); // o writeln

    stepsText.writeln("=== PROBLEMA DE ASIGNACIÓN BIPARTITA ===");

    stepsText.writeln("Nodos Conjunto A (Filas): $rowNames");

    stepsText.writeln("Nodos Conjunto B (Columnas): $colNames\n");

    for (var step in result.steps) {
      stepsText.writeln("--- ${step.title} ---");

      stepsText.writeln(step.description);
    }

    stepsText.writeln("\n➔ Valor Óptimo Total: $optimalSum");

    return MatrixResult(
      rowNames: rowNames,

      colNames: colNames,

      originalMatrix: matrix,

      finalMatrix: result.finalMatrix,

      optimalValue: optimalSum,

      calculationSteps: stepsText.toString(),

      assignments: assignmentList,

      stepByStep: result.steps,
    );
  }

  // MÉTODO NUEVO AGREGADO PARA RESOLVER EL ERROR DE ASIGNACIÓN LINEAL

  static MatrixResult solveLinearAssignment({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required bool isMaximization,
  }) {
    // ============================================================
    // ASIGNACIÓN LINEAL
    // Utiliza únicamente los nodos normales:
    // bipartiteGroup == BipartiteGroup.none
    // ============================================================

    final normalNodes =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.none).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    // Verificar que existan nodos normales
    if (normalNodes.isEmpty) {
      return MatrixResult(
        rowNames: [],
        colNames: [],
        originalMatrix: [],
        finalMatrix: [],
        optimalValue: 0.0,
        calculationSteps:
            'Error: No hay nodos normales para realizar la Asignación Lineal.',
        assignments: [],
        stepByStep: [],
      );
    }

    final int n = normalNodes.length;

    // Los mismos nodos serán filas y columnas.
    final List<String> names = normalNodes
        .map((node) => node.label.isNotEmpty ? node.label : node.id)
        .toList();

    final List<String> rowNames = List<String>.from(names);
    final List<String> colNames = List<String>.from(names);

    // Mapa ID -> índice dentro de la matriz
    final nodeIndex = {
      for (int i = 0; i < normalNodes.length; i++) normalNodes[i].id: i,
    };

    // Crear matriz cuadrada
    final List<List<double>> matrix = List.generate(
      n,
      (_) => List.filled(n, 0.0),
    );

    // ============================================================
    // CONSTRUIR MATRIZ A PARTIR DE LAS ARISTAS
    // ============================================================

    for (final edge in edges) {
      final sourceIndex = nodeIndex[edge.sourceId];
      final targetIndex = nodeIndex[edge.targetId];

      // La arista solamente se utiliza si ambos nodos
      // son nodos normales.
      if (sourceIndex != null && targetIndex != null) {
        matrix[sourceIndex][targetIndex] = edge.weight;

        // Una arista simple no tiene dirección.
        // Por lo tanto, también se coloca en sentido contrario.
        if (edge.type == EdgeType.simple) {
          matrix[targetIndex][sourceIndex] = edge.weight;
        }
      }
    }

    // ============================================================
    // EJECUTAR ALGORITMO HÚNGARO
    // ============================================================

    final result = HungarianAlgorithm.solve(
      matrix: matrix,
      rowNames: rowNames,
      colNames: colNames,
      isMaximization: isMaximization,
    );

    // ============================================================
    // CALCULAR VALOR ÓPTIMO Y ASIGNACIONES
    // ============================================================

    double optimalSum = 0.0;

    final List<String> assignmentList = [];

    for (final pair in result.assignments) {
      final int r = pair['r']!;
      final int c = pair['c']!;

      optimalSum += matrix[r][c];

      final String origin = rowNames[r];
      final String target = colNames[c];

      assignmentList.add(
        'Fila ($origin) ➔ Columna ($target) | Peso: ${matrix[r][c]}',
      );
    }

    // ============================================================
    // TEXTO DE LOS PASOS
    // ============================================================

    final StringBuffer stepsText = StringBuffer();

    stepsText.writeln('=== PROBLEMA DE ASIGNACIÓN LINEAL ===');
    stepsText.writeln('Se utilizan únicamente los nodos normales/circulares.');
    stepsText.writeln('Nodos utilizados: $rowNames');
    stepsText.writeln();

    for (final step in result.steps) {
      stepsText.writeln('--- ${step.title} ---');
      stepsText.writeln(step.description);
    }

    stepsText.writeln();
    stepsText.writeln('➔ Valor Óptimo Total: $optimalSum');

    return MatrixResult(
      rowNames: rowNames,
      colNames: colNames,
      originalMatrix: matrix,
      finalMatrix: result.finalMatrix,
      optimalValue: optimalSum,
      calculationSteps: stepsText.toString(),
      assignments: assignmentList,
      stepByStep: result.steps,
    );
  }
}
