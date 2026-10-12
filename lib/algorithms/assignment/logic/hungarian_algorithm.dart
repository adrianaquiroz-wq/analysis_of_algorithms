import 'package:graph_app/algorithms/assignment/models/matrix_step.dart';

import 'hungarian_matching.dart';
import 'hungarian_result.dart';

export 'hungarian_result.dart';

/// Método húngaro. Cada etapa queda registrada como [MatrixStep].
class HungarianAlgorithm {
  static const int _maxIterations = 100;

  static HungarianResult solve({
    required List<List<double>> matrix,
    required List<String> rowNames,
    required List<String> colNames,
    required bool isMaximization,
  }) {
    final n = matrix.length;
    final mat = [for (final row in matrix) List<double>.from(row)];
    final steps = <MatrixStep>[];

    void snap(String title, String description) {
      steps.add(
        MatrixStep(
          title: title,
          description: description,
          matrixSnapshot: [for (final row in mat) List<double>.from(row)],
          rowNames: rowNames,
          colNames: colNames,
        ),
      );
    }

    snap(
      'Paso 0: Matriz Original',
      'Matriz de pesos construida a partir de las aristas del grafo.',
    );

    if (isMaximization) {
      final maxVal = _convertToMinimization(mat);
      snap(
        'Paso 1: Conversión Maximización ➔ Minimización',
        'Se resta cada valor al máximo de la matriz ($maxVal) para poder '
            'aplicar el algoritmo húngaro, que resuelve minimización.',
      );
    }

    _reduceColumns(mat);
    snap(
      'Paso 2: Reducción por Columnas',
      'A cada columna se le resta su valor mínimo, generando al menos un '
          'cero por columna.',
    );

    _reduceRows(mat);
    snap(
      'Paso 3: Reducción por Filas',
      'A cada fila se le resta su valor mínimo, generando al menos un cero '
          'por fila.',
    );

    for (int iteration = 0; iteration < _maxIterations; iteration++) {
      final matching = HungarianMatching.maxMatching(mat);
      snap(
        'Iteración ${iteration + 1}: Emparejamiento sobre ceros',
        'Se buscó un emparejamiento máximo usando solo los ceros '
            'disponibles. Filas emparejadas: ${matching.size} de $n.',
      );

      if (matching.size >= n) {
        snap(
          'Emparejamiento perfecto encontrado',
          'Se logró asignar las $n filas a $n columnas usando solo ceros. '
              'El algoritmo finaliza aquí.',
        );
        break;
      }

      final cover = HungarianMatching.minCover(mat, matching.matchCol);
      final minUncovered = _minUncovered(mat, cover);

      if (minUncovered == double.infinity || minUncovered <= 0) {
        snap(
          'Sin valor no cubierto válido',
          'No se encontró un valor no cubierto mayor a cero. El algoritmo '
              'finaliza con el mejor resultado disponible.',
        );
        break;
      }

      _adjust(mat, cover, minUncovered);
      snap(
        'Iteración ${iteration + 1}: Ajuste de la matriz',
        'Líneas de cobertura: ${cover.lineCount} de $n necesarias. Se restó '
            '$minUncovered a los valores no cubiertos y se sumó a los '
            'doblemente cubiertos.',
      );
    }

    // Emparejamiento final definitivo sobre la matriz ya reducida
    final finalMatching = HungarianMatching.maxMatching(mat);
    final assignments = <Map<String, int>>[
      for (int c = 0; c < n; c++)
        if (finalMatching.matchCol[c] != -1)
          {'r': finalMatching.matchCol[c], 'c': c},
    ];

    return HungarianResult(
      finalMatrix: mat,
      assignments: assignments,
      steps: steps,
    );
  }

  /// Resta cada valor al máximo. Devuelve el máximo usado.
  static double _convertToMinimization(List<List<double>> mat) {
    double maxVal = double.negativeInfinity;
    for (final row in mat) {
      for (final v in row) {
        if (v > maxVal) maxVal = v;
      }
    }
    for (final row in mat) {
      for (int c = 0; c < row.length; c++) {
        row[c] = maxVal - row[c];
      }
    }
    return maxVal;
  }

  static void _reduceColumns(List<List<double>> mat) {
    final n = mat.length;
    for (int c = 0; c < n; c++) {
      double minVal = double.infinity;
      for (int r = 0; r < n; r++) {
        if (mat[r][c] < minVal) minVal = mat[r][c];
      }
      for (int r = 0; r < n; r++) {
        mat[r][c] -= minVal;
      }
    }
  }

  static void _reduceRows(List<List<double>> mat) {
    for (final row in mat) {
      double minVal = double.infinity;
      for (final v in row) {
        if (v < minVal) minVal = v;
      }
      for (int c = 0; c < row.length; c++) {
        row[c] -= minVal;
      }
    }
  }

  static double _minUncovered(List<List<double>> mat, ZeroCover cover) {
    double minVal = double.infinity;
    for (int r = 0; r < mat.length; r++) {
      if (cover.rowLines.contains(r)) continue;
      for (int c = 0; c < mat.length; c++) {
        if (!cover.colLines.contains(c) && mat[r][c] < minVal) {
          minVal = mat[r][c];
        }
      }
    }
    return minVal;
  }

  static void _adjust(List<List<double>> mat, ZeroCover cover, double delta) {
    for (int r = 0; r < mat.length; r++) {
      final rowCovered = cover.rowLines.contains(r);
      for (int c = 0; c < mat.length; c++) {
        final colCovered = cover.colLines.contains(c);
        if (!rowCovered && !colCovered) {
          mat[r][c] -= delta;
        } else if (rowCovered && colCovered) {
          mat[r][c] += delta;
        }
      }
    }
  }
}
