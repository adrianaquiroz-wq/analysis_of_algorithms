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

class NorthwestCornerAlgorithm {
  static NorthwestCornerResult solve({
    required List<List<double>> costs,
    required List<double> supplies,
    required List<double> demands,
    required List<String> rowNames,
    required List<String> colNames,
    // Agregamos isMaximization para que la UI no rompa, aunque NWC lo ignore en esta Fase 1
    bool isMaximization = false, 
  }) {
    if (costs.isEmpty || costs.first.isEmpty) {
      throw ArgumentError('La matriz de transporte está vacía.');
    }

    final columns = costs.first.length;

    if (costs.any((row) => row.length != columns)) {
      throw ArgumentError('La matriz de costos no es rectangular.');
    }

    if (supplies.length != costs.length ||
        demands.length != columns ||
        rowNames.length != costs.length ||
        colNames.length != columns) {
      throw ArgumentError(
        'Las filas, columnas, ofertas y demandas no coinciden con la matriz.',
      );
    }

    if (supplies.any((value) => value < 0) ||
        demands.any((value) => value < 0)) {
      throw ArgumentError(
        'La oferta y la demanda no pueden ser negativas.',
      );
    }

    final balance = _balanceProblem(
      costs: costs,
      supplies: supplies,
      demands: demands,
      rowNames: rowNames,
      colNames: colNames,
    );

    final balancedCosts = balance.costs;
    final remainingSupply = List<double>.from(balance.supplies);
    final remainingDemand = List<double>.from(balance.demands);

    final allocation = List.generate(
      balancedCosts.length,
      (_) => List<double>.filled(balancedCosts.first.length, 0),
    );

    final steps = <NorthwestCornerStep>[];

    int row = 0;
    int column = 0;

    // Eliminamos los "continue" tempranos. El algoritmo debe registrar celdas
    // con asignación "0" explícita para mantener la regla de (m + n - 1) celdas básicas.
    while (row < remainingSupply.length && column < remainingDemand.length) {
      final supplyBefore = remainingSupply[row];
      final demandBefore = remainingDemand[column];

      final quantity = supplyBefore < demandBefore ? supplyBefore : demandBefore;

      allocation[row][column] = quantity;
      remainingSupply[row] -= quantity;
      remainingDemand[column] -= quantity;

      final rowExhausted = remainingSupply[row].abs() <= 1e-9;
      final columnExhausted = remainingDemand[column].abs() <= 1e-9;

      String reason;
      if (rowExhausted && columnExhausted) {
        reason = 'Se agotaron simultáneamente la oferta y la demanda (Degeneración).';
      } else if (rowExhausted) {
        reason = 'Se agotó la oferta del origen.';
      } else {
        reason = 'Se agotó la demanda del destino.';
      }

      steps.add(
        NorthwestCornerStep(
          row: row,
          column: column,
          allocation: quantity,
          supplyBefore: supplyBefore,
          demandBefore: demandBefore,
          supplyAfter: remainingSupply[row],
          demandAfter: remainingDemand[column],
          reason: reason,
        ),
      );

      // Corrección de degeneración: Nunca avanzamos en ambas direcciones a la vez 
      // a menos que estemos en la última celda absoluta.
      if (rowExhausted && columnExhausted) {
        if (row < remainingSupply.length - 1) {
          row++;
        } else {
          column++;
        }
      } else if (rowExhausted) {
        row++;
      } else {
        column++;
      }
    }

    double total = 0;
    for (int r = 0; r < allocation.length; r++) {
      for (int c = 0; c < allocation[r].length; c++) {
        total += allocation[r][c] * balancedCosts[r][c];
      }
    }

    return NorthwestCornerResult(
      allocations: allocation,
      costs: balancedCosts,
      rowNames: balance.rowNames,
      colNames: balance.colNames,
      supplies: balance.supplies,
      demands: balance.demands,
      steps: steps,
      total: total,
    );
  }

  static _BalancedProblem _balanceProblem({
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

    final totalSupply = balancedSupplies.fold<double>(0, (sum, value) => sum + value);
    final totalDemand = balancedDemands.fold<double>(0, (sum, value) => sum + value);

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

    return _BalancedProblem(
      costs: balancedCosts,
      supplies: balancedSupplies,
      demands: balancedDemands,
      rowNames: balancedRows,
      colNames: balancedCols,
    );
  }
}

class _BalancedProblem {
  final List<List<double>> costs;
  final List<double> supplies;
  final List<double> demands;
  final List<String> rowNames;
  final List<String> colNames;

  const _BalancedProblem({
    required this.costs,
    required this.supplies,
    required this.demands,
    required this.rowNames,
    required this.colNames,
  });
}