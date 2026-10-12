class ZeroMatching {
  /// matchCol[c] = fila asignada a la columna c (o -1).
  final List<int> matchCol;

  /// Cantidad de filas emparejadas.
  final int size;

  const ZeroMatching(this.matchCol, this.size);
}

class ZeroCover {
  final Set<int> rowLines;
  final Set<int> colLines;

  const ZeroCover(this.rowLines, this.colLines);

  int get lineCount => rowLines.length + colLines.length;
}

class HungarianMatching {
  static const double eps = 1e-5;

  /// Emparejamiento máximo usando solo ceros (caminos aumentantes).
  static ZeroMatching maxMatching(List<List<double>> mat) {
    final n = mat.length;
    final matchCol = List<int>.filled(n, -1);

    bool tryAssign(int r, List<bool> visited) {
      for (int c = 0; c < n; c++) {
        if (mat[r][c].abs() < eps && !visited[c]) {
          visited[c] = true;
          if (matchCol[c] == -1 || tryAssign(matchCol[c], visited)) {
            matchCol[c] = r;
            return true;
          }
        }
      }
      return false;
    }

    int size = 0;
    for (int r = 0; r < n; r++) {
      if (tryAssign(r, List<bool>.filled(n, false))) size++;
    }
    return ZeroMatching(matchCol, size);
  }

  /// Cobertura mínima de ceros a partir de un emparejamiento (König).
  static ZeroCover minCover(List<List<double>> mat, List<int> matchCol) {
    final n = mat.length;
    final matchRow = List<int>.filled(n, -1);
    for (int c = 0; c < n; c++) {
      if (matchCol[c] != -1) matchRow[matchCol[c]] = c;
    }

    final visitedRows = List<bool>.filled(n, false);
    final visitedCols = List<bool>.filled(n, false);
    final queue = <int>[];
    for (int r = 0; r < n; r++) {
      if (matchRow[r] == -1) {
        visitedRows[r] = true;
        queue.add(r);
      }
    }

    int qi = 0;
    while (qi < queue.length) {
      final r = queue[qi++];
      for (int c = 0; c < n; c++) {
        if (mat[r][c].abs() < eps && !visitedCols[c]) {
          visitedCols[c] = true;
          final nr = matchCol[c];
          if (nr != -1 && !visitedRows[nr]) {
            visitedRows[nr] = true;
            queue.add(nr);
          }
        }
      }
    }

    return ZeroCover(
      {
        for (int r = 0; r < n; r++)
          if (!visitedRows[r]) r,
      },
      {
        for (int c = 0; c < n; c++)
          if (visitedCols[c]) c,
      },
    );
  }
}
