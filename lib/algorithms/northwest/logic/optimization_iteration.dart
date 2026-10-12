class OptimizationIteration {
  final int iterationNumber;
  final List<List<double>> allocations;
  final List<List<double>> marginalCosts;
  final double totalValue;
  final int? enteringRow;
  final int? enteringCol;
  final double? theta;
  bool isOptimal;

  OptimizationIteration({
    required this.iterationNumber,
    required this.allocations,
    required this.marginalCosts,
    required this.totalValue,
    this.enteringRow,
    this.enteringCol,
    this.theta,
    required this.isOptimal,
  });
}
