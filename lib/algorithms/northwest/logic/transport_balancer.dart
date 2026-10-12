class BalancedProblem {
  final List<List<double>> costs;
  final List<double> supplies;
  final List<double> demands;
  final List<String> rowNames;
  final List<String> colNames;

  const BalancedProblem({
    required this.costs,
    required this.supplies,
    required this.demands,
    required this.rowNames,
    required this.colNames,
  });
}

/// Si oferta y demanda no coinciden, agrega un origen o destino ficticio.
class TransportBalancer {
  static BalancedProblem balance({
    required List<List<double>> costs,
    required List<double> supplies,
    required List<double> demands,
    required List<String> rowNames,
    required List<String> colNames,
  }) {
    final balancedCosts = costs.map(List<double>.from).toList();
    final balancedSupplies = List<double>.from(supplies);
    final balancedDemands = List<double>.from(demands);
    final balancedRows = List<String>.from(rowNames);
    final balancedCols = List<String>.from(colNames);

    final totalSupply = balancedSupplies.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final totalDemand = balancedDemands.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    if ((totalSupply - totalDemand).abs() > 1e-9) {
      if (totalSupply < totalDemand) {
        final difference = totalDemand - totalSupply;
        balancedCosts.add(List<double>.filled(balancedDemands.length, 0));
        balancedRows.add('Origen ficticio');
        balancedSupplies.add(difference);
      } else {
        final difference = totalSupply - totalDemand;
        for (final row in balancedCosts) {
          row.add(0);
        }
        balancedCols.add('Destino ficticio');
        balancedDemands.add(difference);
      }
    }

    return BalancedProblem(
      costs: balancedCosts,
      supplies: balancedSupplies,
      demands: balancedDemands,
      rowNames: balancedRows,
      colNames: balancedCols,
    );
  }
}
