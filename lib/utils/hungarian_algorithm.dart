import '../models/matrix_step.dart';

class HungarianResult {
  final List<List<double>> finalMatrix;
  final List<Map<String, int>> assignments; // {'r':, 'c':}
  final List<MatrixStep> steps;

  HungarianResult({
    required this.finalMatrix,
    required this.assignments,
    required this.steps,
  });
}

class HungarianAlgorithm {
  static HungarianResult solve({
    required List<List<double>> matrix,
    required List<String> rowNames,
    required List<String> colNames,
    required bool isMaximization,
  }) {
    final int n = matrix.length;
    List<List<double>> mat = matrix
        .map((row) => List<double>.from(row))
        .toList();
    List<MatrixStep> steps = [];

    steps.add(
      _snapshot(
        title: "Paso 0: Matriz Original",
        description:
            "Matriz de pesos construida a partir de las aristas del grafo.",
        mat: mat,
        rowNames: rowNames,
        colNames: colNames,
      ),
    );

    if (isMaximization) {
      double maxVal = double.negativeInfinity;
      for (var row in mat) {
        for (var v in row) {
          if (v > maxVal) maxVal = v;
        }
      }
      for (int r = 0; r < n; r++) {
        for (int c = 0; c < n; c++) {
          mat[r][c] = maxVal - mat[r][c];
        }
      }
      steps.add(
        _snapshot(
          title: "Paso 1: Conversión Maximización ➔ Minimización",
          description:
              "Se resta cada valor al máximo de la matriz ($maxVal) para poder aplicar el algoritmo húngaro, que resuelve minimización.",
          mat: mat,
          rowNames: rowNames,
          colNames: colNames,
        ),
      );
    }

    for (int c = 0; c < n; c++) {
      double minVal = double.infinity;
      for (int r = 0; r < n; r++) {
        if (mat[r][c] < minVal) minVal = mat[r][c];
      }
      for (int r = 0; r < n; r++) {
        mat[r][c] -= minVal;
      }
    }
    steps.add(
      _snapshot(
        title: "Paso 2: Reducción por Columnas",
        description: "A cada columna se le resta su valor mínimo, generando al menos un cero por columna.",
        mat: mat,
        rowNames: rowNames,
        colNames: colNames,
      ),
    );

    for (int r = 0; r < n; r++) {
      double minVal = double.infinity;
      for (int c = 0; c < n; c++) {
        if (mat[r][c] < minVal) minVal = mat[r][c];
      }
      for (int c = 0; c < n; c++) {
        mat[r][c] -= minVal;
      }
    }
    steps.add(
      _snapshot(
        title: "Paso 3: Reducción por Filas",
        description: "A cada fila se le resta su valor mínimo, generando al menos un cero por fila.",
        mat: mat,
        rowNames: rowNames,
        colNames: colNames,
      ),
    );

    int iteration = 0;
    List<int> matchCol = List.filled(n, -1);

    while (iteration < 100) {
      matchCol = List.filled(n, -1);

      bool tryAssign(int r, List<bool> visitedCol) {
        for (int c = 0; c < n; c++) {
          if (mat[r][c].abs() < 1e-5 && !visitedCol[c]) {
            visitedCol[c] = true;
            if (matchCol[c] == -1 || tryAssign(matchCol[c], visitedCol)) {
              matchCol[c] = r;
              return true;
            }
          }
        }
        return false;
      }

      int matchedCount = 0;
      for (int r = 0; r < n; r++) {
        List<bool> visitedCol = List.filled(n, false);
        if (tryAssign(r, visitedCol)) matchedCount++;
      }

      steps.add(
        _snapshot(
          title: "Iteración ${iteration + 1}: Emparejamiento sobre ceros",
          description:
              "Se buscó un emparejamiento máximo usando solo los ceros disponibles. Filas emparejadas: $matchedCount de $n.",
          mat: mat,
          rowNames: rowNames,
          colNames: colNames,
        ),
      );

      if (matchedCount >= n) {
        steps.add(
          _snapshot(
            title: "Emparejamiento perfecto encontrado",
            description:
                "Se logró asignar las $n filas a $n columnas usando solo ceros. El algoritmo finaliza aquí.",
            mat: mat,
            rowNames: rowNames,
            colNames: colNames,
          ),
        );
        break;
      }

      List<int> matchRow = List.filled(n, -1);
      for (int c = 0; c < n; c++) {
        if (matchCol[c] != -1) matchRow[matchCol[c]] = c;
      }

      List<bool> visitedRows = List.filled(n, false);
      List<bool> visitedCols = List.filled(n, false);
      List<int> queue = [];
      for (int r = 0; r < n; r++) {
        if (matchRow[r] == -1) {
          visitedRows[r] = true;
          queue.add(r);
        }
      }

      int qi = 0;
      while (qi < queue.length) {
        int r = queue[qi++];
        for (int c = 0; c < n; c++) {
          if (mat[r][c].abs() < 1e-5 && !visitedCols[c]) {
            visitedCols[c] = true;
            int nr = matchCol[c];
            if (nr != -1 && !visitedRows[nr]) {
              visitedRows[nr] = true;
              queue.add(nr);
            }
          }
        }
      }

      List<int> rowLines = [];
      List<int> colLines = [];
      for (int r = 0; r < n; r++) {
        if (!visitedRows[r]) rowLines.add(r);
      }
      for (int c = 0; c < n; c++) {
        if (visitedCols[c]) colLines.add(c);
      }

      double minUncovered = double.infinity;
      for (int r = 0; r < n; r++) {
        bool rCov = rowLines.contains(r);
        for (int c = 0; c < n; c++) {
          bool cCov = colLines.contains(c);
          if (!rCov && !cCov) {
            if (mat[r][c] < minUncovered) minUncovered = mat[r][c];
          }
        }
      }

      if (minUncovered == double.infinity || minUncovered <= 0) {
        steps.add(
          _snapshot(
            title: "Sin valor no cubierto válido",
            description: "No se encontró un valor no cubierto mayor a cero. El algoritmo finaliza con el mejor resultado disponible.",
            mat: mat,
            rowNames: rowNames,
            colNames: colNames,
          ),
        );
        break;
      }

      for (int r = 0; r < n; r++) {
        bool rCov = rowLines.contains(r);
        for (int c = 0; c < n; c++) {
          bool cCov = colLines.contains(c);
          if (!rCov && !cCov) {
            mat[r][c] -= minUncovered;
          } else if (rCov && cCov) {
            mat[r][c] += minUncovered;
          }
        }
      }

      steps.add(
        _snapshot(
          title: "Iteración ${iteration + 1}: Ajuste de la matriz",
          description:
              "Líneas de cobertura: ${rowLines.length + colLines.length} de $n necesarias. Se restó $minUncovered a los valores no cubiertos y se sumó a los doblemente cubiertos.",
          mat: mat,
          rowNames: rowNames,
          colNames: colNames,
        ),
      );

      iteration++;
    }

    // Emparejamiento final definitivo sobre la matriz ya reducida
    matchCol = List.filled(n, -1);
    bool tryAssignFinal(int r, List<bool> visitedCol) {
      for (int c = 0; c < n; c++) {
        if (mat[r][c].abs() < 1e-5 && !visitedCol[c]) {
          visitedCol[c] = true;
          if (matchCol[c] == -1 || tryAssignFinal(matchCol[c], visitedCol)) {
            matchCol[c] = r;
            return true;
          }
        }
      }
      return false;
    }

    for (int r = 0; r < n; r++) {
      List<bool> visitedCol = List.filled(n, false);
      tryAssignFinal(r, visitedCol);
    }

    List<Map<String, int>> assignments = [];
    for (int c = 0; c < n; c++) {
      if (matchCol[c] != -1) {
        assignments.add({'r': matchCol[c], 'c': c});
      }
    }

    return HungarianResult(
      finalMatrix: mat,
      assignments: assignments,
      steps: steps,
    );
  }

  static MatrixStep _snapshot({
    required String title,
    required String description,
    required List<List<double>> mat,
    required List<String> rowNames,
    required List<String> colNames,
  }) {
    return MatrixStep(
      title: title,
      description: description,
      matrixSnapshot: mat.map((row) => List<double>.from(row)).toList(),
      rowNames: rowNames,
      colNames: colNames,
    );
  }
}
