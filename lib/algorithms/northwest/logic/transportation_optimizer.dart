import 'dart:math';

import 'closed_loop_finder.dart';
import 'northwest_corner_models.dart';
import 'optimization_iteration.dart';

export 'optimization_iteration.dart';

class TransportationOptimizer {
  static List<OptimizationIteration> optimize({
    required List<List<double>> initialAllocations,
    required List<List<double>> costs,
    required bool isMaximization,
    required List<NorthwestCornerStep> nwSteps,
  }) {
    int rows = costs.length;
    int cols = costs[0].length;
    List<OptimizationIteration> history = [];

    // Copiar las asignaciones de la Esquina Noroeste
    List<List<double>> currentAllocations = initialAllocations
        .map((row) => List<double>.from(row))
        .toList();

    // 1. Marcar las celdas básicas (variables de holgura y ruta)
    List<List<bool>> isBasic = List.generate(
      rows,
      (_) => List.filled(cols, false),
    );
    for (var step in nwSteps) {
      isBasic[step.row][step.column] = true;
    }

    int iterationCount = 1;

    while (iterationCount < 20) {
      // Límite de seguridad
      // 2. Método MODI: Calcular Multiplicadores U y V
      List<double?> u = List.filled(rows, null);
      List<double?> v = List.filled(cols, null);
      u[0] = 0.0; // Siempre iniciamos U1 en 0

      bool changed = true;
      while (changed) {
        changed = false;
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            if (isBasic[r][c]) {
              if (u[r] != null && v[c] == null) {
                v[c] = costs[r][c] - u[r]!;
                changed = true;
              } else if (v[c] != null && u[r] == null) {
                u[r] = costs[r][c] - v[c]!;
                changed = true;
              }
            }
          }
        }
        // Manejo de degeneración: si se estanca, inyectar un 0 a la fila aislada
        if (!changed) {
          for (int r = 0; r < rows; r++) {
            if (u[r] == null) {
              u[r] = 0.0;
              changed = true;
              break;
            }
          }
        }
      }
      // Rellenar las columnas huérfanas
      for (int i = 0; i < cols; i++) {
        v[i] ??= 0.0;
      }

      // 3. Evaluar Celdas Vacías (Costo Marginal = Cij - (Ui + Vj))
      List<List<double>> marginalCosts = List.generate(
        rows,
        (_) => List.filled(cols, 0.0),
      );
      double bestMarginalValue = isMaximization
          ? double.negativeInfinity
          : double.infinity;
      int enteringRow = -1;
      int enteringCol = -1;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (!isBasic[r][c]) {
            double marginal = costs[r][c] - (u[r]! + v[c]!);
            marginalCosts[r][c] = marginal;

            if (isMaximization) {
              // Maximizar: Buscar el valor positivo más grande
              if (marginal > 0 && marginal > bestMarginalValue) {
                bestMarginalValue = marginal;
                enteringRow = r;
                enteringCol = c;
              }
            } else {
              // Minimizar: Buscar el valor negativo más grande (menor a cero)
              if (marginal < 0 && marginal < bestMarginalValue) {
                bestMarginalValue = marginal;
                enteringRow = r;
                enteringCol = c;
              }
            }
          }
        }
      }

      // 4. Validación de Optimalidad
      if (enteringRow == -1 || enteringCol == -1) {
        if (history.isNotEmpty) {
          history.last.isOptimal = true; // El salto anterior nos dio el óptimo
        } else {
          // La Esquina Noroeste ya era óptima desde el principio
          history.add(
            OptimizationIteration(
              iterationNumber: iterationCount,
              allocations: currentAllocations
                  .map((r) => List<double>.from(r))
                  .toList(),
              marginalCosts: marginalCosts,
              totalValue: _calculateTotal(currentAllocations, costs),
              isOptimal: true,
            ),
          );
        }
        break; // Detener bucle
      }

      // 5. Salto de la Rana (Stepping Stone): Trazar el polígono
      List<Point<int>> loop = ClosedLoopFinder.find(
        isBasic,
        enteringRow,
        enteringCol,
        rows,
        cols,
      );
      if (loop.isEmpty) break;

      // 6. Determinar el flujo Theta (mínimo de los vértices que restan)
      double theta = double.infinity;
      Point<int>? leavingCell;
      for (int i = 1; i < loop.length; i += 2) {
        double val = currentAllocations[loop[i].x][loop[i].y];
        if (val < theta) {
          theta = val;
          leavingCell = loop[i];
        }
      }

      // 7. Aplicar el Theta a la matriz y reconfigurar celdas básicas
      for (int i = 0; i < loop.length; i++) {
        if (i % 2 == 0) {
          currentAllocations[loop[i].x][loop[i].y] += theta; // vértices pares
        } else {
          currentAllocations[loop[i].x][loop[i].y] -= theta; // vértices impares
        }
      }

      isBasic[enteringRow][enteringCol] = true; // Entra a la base
      if (leavingCell != null) {
        isBasic[leavingCell.x][leavingCell.y] =
            false; // Sale el que llegó a cero primero
      }

      // 8. Guardar el estado histórico para la Interfaz Gráfica
      history.add(
        OptimizationIteration(
          iterationNumber: iterationCount,
          allocations: currentAllocations
              .map((r) => List<double>.from(r))
              .toList(),
          marginalCosts: marginalCosts,
          totalValue: _calculateTotal(currentAllocations, costs),
          enteringRow: enteringRow,
          enteringCol: enteringCol,
          theta: theta,
          isOptimal: false, // Se validará en la siguiente vuelta
        ),
      );

      iterationCount++;
    }

    return history;
  }

  static double _calculateTotal(
    List<List<double>> allocations,
    List<List<double>> costs,
  ) {
    double t = 0;
    for (int r = 0; r < allocations.length; r++) {
      for (int c = 0; c < allocations[r].length; c++) {
        t += allocations[r][c] * costs[r][c];
      }
    }
    return t;
  }
}
