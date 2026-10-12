class NorthwestCornerStep {
  final int row;
  final int column;
  final double allocation;
  final double supplyBefore;
  final double demandBefore;
  final double supplyAfter;
  final double demandAfter;
  final String reason;

  const NorthwestCornerStep({
    required this.row,
    required this.column,
    required this.allocation,
    required this.supplyBefore,
    required this.demandBefore,
    required this.supplyAfter,
    required this.demandAfter,
    required this.reason,
  });
}

class NorthwestCornerResult {
  final List<List<double>> allocations;
  final List<List<double>> costs;
  final List<String> rowNames;
  final List<String> colNames;
  final List<double> supplies;
  final List<double> demands;
  final List<NorthwestCornerStep> steps;
  final double total;

  const NorthwestCornerResult({
    required this.allocations,
    required this.costs,
    required this.rowNames,
    required this.colNames,
    required this.supplies,
    required this.demands,
    required this.steps,
    required this.total,
  });
}
