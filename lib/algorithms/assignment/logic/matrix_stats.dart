/// Un valor 0 en la matriz significa que NO existe relación.
class MatrixStats {
  static int nonZeroInRow(List<double> row) => row.where((v) => v != 0).length;

  static int nonZeroInColumn(List<List<double>> matrix, int c) {
    int count = 0;
    for (final row in matrix) {
      if (c < row.length && row[c] != 0) count++;
    }
    return count;
  }

  static double sumRow(List<double> row) => row.fold(0.0, (sum, v) => sum + v);

  static double sumColumn(List<List<double>> matrix, int c) {
    double sum = 0;
    for (final row in matrix) {
      if (c < row.length) sum += row[c];
    }
    return sum;
  }
}

/// Entero si es entero; si no, con 2 decimales.
String fmtMatrixValue(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
