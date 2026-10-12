import 'dart:math' as math;

import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';

import 'hungarian_algorithm.dart';
import 'matrix_result.dart';

export 'matrix_result.dart';

/// Arma la matriz de costos desde el grafo y la resuelve con el método húngaro.
class AssignmentSolver {
  static String _labelOf(NodeModel n) => n.label.isNotEmpty ? n.label : n.id;

  // ------------------------------------------------------------- Bipartita

  /// Conjunto A = filas, Conjunto B = columnas. Si no son iguales se agregan
  /// nodos ficticios con costo 0 para cuadrar la matriz.
  static MatrixResult solveBipartite({
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
      return MatrixResult.empty(
        'Error: Debes marcar nodos en el Conjunto A y en el Conjunto B para '
        'resolver el grafo bipartito.',
      );
    }

    final size = math.max(groupA.length, groupB.length);
    final rowNames = groupA.map(_labelOf).toList();
    final colNames = groupB.map(_labelOf).toList();
    for (int i = rowNames.length; i < size; i++) {
      rowNames.add('Ficticio_${i + 1}');
    }
    for (int j = colNames.length; j < size; j++) {
      colNames.add('Ficticio_${j + 1}');
    }

    final mapA = {for (int i = 0; i < groupA.length; i++) groupA[i].id: i};
    final mapB = {for (int j = 0; j < groupB.length; j++) groupB[j].id: j};
    final matrix = List.generate(size, (_) => List.filled(size, 0.0));

    for (final edge in edges) {
      final r = mapA[edge.sourceId];
      final c = mapB[edge.targetId];
      if (r != null && c != null) {
        matrix[r][c] = edge.weight;
        continue;
      }
      final rRev = mapA[edge.targetId];
      final cRev = mapB[edge.sourceId];
      if (rRev != null && cRev != null) matrix[rRev][cRev] = edge.weight;
    }

    return _solveMatrix(
      header: [
        '=== PROBLEMA DE ASIGNACIÓN BIPARTITA ===',
        'Nodos Conjunto A (Filas): $rowNames',
        'Nodos Conjunto B (Columnas): $colNames',
        '',
      ],
      matrix: matrix,
      rowNames: rowNames,
      colNames: colNames,
      isMaximization: isMaximization,
      skipDummies: true,
    );
  }

  // ---------------------------------------------------------------- Lineal

  /// Usa solo los nodos normales: los mismos nodos son filas y columnas.
  static MatrixResult solveLinear({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required bool isMaximization,
  }) {
    final normalNodes =
        nodes.where((n) => n.bipartiteGroup == BipartiteGroup.none).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    if (normalNodes.isEmpty) {
      return MatrixResult.empty(
        'Error: No hay nodos normales para realizar la Asignación Lineal.',
      );
    }

    final n = normalNodes.length;
    final names = normalNodes.map(_labelOf).toList();
    final nodeIndex = {for (int i = 0; i < n; i++) normalNodes[i].id: i};
    final matrix = List.generate(n, (_) => List.filled(n, 0.0));

    for (final edge in edges) {
      final s = nodeIndex[edge.sourceId];
      final t = nodeIndex[edge.targetId];
      if (s == null || t == null) continue;

      matrix[s][t] = edge.weight;
      // Una arista simple no tiene dirección: también va al revés.
      if (edge.type == EdgeType.simple) matrix[t][s] = edge.weight;
    }

    return _solveMatrix(
      header: [
        '=== PROBLEMA DE ASIGNACIÓN LINEAL ===',
        'Se utilizan únicamente los nodos normales/circulares.',
        'Nodos utilizados: $names',
        '',
      ],
      matrix: matrix,
      rowNames: List<String>.from(names),
      colNames: List<String>.from(names),
      isMaximization: isMaximization,
    );
  }

  // ----------------------------------------------------------------- Común

  static MatrixResult _solveMatrix({
    required List<String> header,
    required List<List<double>> matrix,
    required List<String> rowNames,
    required List<String> colNames,
    required bool isMaximization,
    bool skipDummies = false,
  }) {
    final result = HungarianAlgorithm.solve(
      matrix: matrix,
      rowNames: rowNames,
      colNames: colNames,
      isMaximization: isMaximization,
    );

    double optimalSum = 0;
    final assignmentList = <String>[];
    final pairs = <MapEntry<int, int>>[];

    for (final pair in result.assignments) {
      final r = pair['r']!;
      final c = pair['c']!;
      optimalSum += matrix[r][c];

      final origin = rowNames[r];
      final target = colNames[c];
      final isDummy =
          origin.startsWith('Ficticio') || target.startsWith('Ficticio');
      if (skipDummies && isDummy) continue;

      assignmentList.add(
        'Fila ($origin) ➔ Columna ($target) | Peso: ${matrix[r][c]}',
      );
      pairs.add(MapEntry(r, c));
    }

    final text = StringBuffer();
    for (final line in header) {
      text.writeln(line);
    }
    for (final step in result.steps) {
      text.writeln('--- ${step.title} ---');
      text.writeln(step.description);
    }
    text.writeln();
    text.writeln('➔ Valor Óptimo Total: $optimalSum');

    return MatrixResult(
      rowNames: rowNames,
      colNames: colNames,
      originalMatrix: matrix,
      finalMatrix: result.finalMatrix,
      optimalValue: optimalSum,
      calculationSteps: text.toString(),
      assignments: assignmentList,
      assignmentPairs: pairs,
      stepByStep: result.steps,
    );
  }
}
