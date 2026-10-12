import 'northwest_corner_models.dart';
import 'transport_balancer.dart';

export 'northwest_corner_models.dart';

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
      throw ArgumentError('La oferta y la demanda no pueden ser negativas.');
    }

    final balance = TransportBalancer.balance(
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

    // Se registran también las celdas con asignación 0 para mantener la
    // regla de (m + n - 1) celdas básicas.
    while (row < remainingSupply.length && column < remainingDemand.length) {
      final supplyBefore = remainingSupply[row];
      final demandBefore = remainingDemand[column];

      final quantity = supplyBefore < demandBefore
          ? supplyBefore
          : demandBefore;

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

      // Corrección de degeneración: nunca avanzamos en ambas direcciones a
      // la vez, salvo que estemos en la última celda.
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
}
