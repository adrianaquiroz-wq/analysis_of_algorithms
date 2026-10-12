class MatrixStep {
  final String title;
  final String description;
  final List<List<double>> matrixSnapshot;
  final List<String> rowNames;
  final List<String> colNames;

  MatrixStep({
    required this.title,
    required this.description,
    required this.matrixSnapshot,
    required this.rowNames,
    required this.colNames,
  });
}
