import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../utils/matrix_optimizer_utils.dart';

class BipartiteMatrixScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final bool isDarkMode;
  final bool isBipartiteMode;

  const BipartiteMatrixScreen({
    super.key,
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
    required this.isBipartiteMode,
  });

  @override
  State<BipartiteMatrixScreen> createState() => _BipartiteMatrixScreenState();
}

class _BipartiteMatrixScreenState extends State<BipartiteMatrixScreen> {
  bool _isMaximization = false;
  late MatrixResult _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    if (widget.isBipartiteMode) {
      _result = MatrixOptimizerUtils.solveBipartiteAssignment(
        nodes: widget.nodes,
        edges: widget.edges,
        isMaximization: _isMaximization,
      );
    } else {
      _result = MatrixOptimizerUtils.solveLinearAssignment(
        nodes: widget.nodes,
        edges: widget.edges,
        isMaximization: _isMaximization,
      );
    }
  }

  // ============================================================
  // CUENTA CUÁNTAS RELACIONES/NODOS EXISTEN EN UNA FILA
  // Un valor 0 significa que NO existe relación.
  // ============================================================
  int _countNonZeroInRow(List<double> row) {
    return row.where((value) => value != 0).length;
  }

  // ============================================================
  // CUENTA CUÁNTAS RELACIONES EXISTEN EN UNA COLUMNA
  // Un valor 0 significa que NO existe relación.
  // ============================================================
  int _countNonZeroInColumn(List<List<double>> matrix, int columnIndex) {
    int count = 0;

    for (final row in matrix) {
      if (columnIndex < row.length && row[columnIndex] != 0) {
        count++;
      }
    }

    return count;
  }

  // ============================================================
  // SUMA DE UNA COLUMNA
  // ============================================================
  double _sumColumn(List<List<double>> matrix, int columnIndex) {
    double sum = 0;

    for (final row in matrix) {
      if (columnIndex < row.length) {
        sum += row[columnIndex];
      }
    }

    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final bgCol = widget.isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.grey[100]!;

    final cardCol = widget.isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    final textCol = widget.isDarkMode ? Colors.white : Colors.black87;

    final subTextCol = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgCol,

      appBar: AppBar(
        backgroundColor: cardCol,

        title: Text(
          widget.isBipartiteMode
              ? 'Asignación Bipartita (Húngaro)'
              : 'Asignación Lineal',
          style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
        ),

        iconTheme: IconThemeData(color: textCol),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),

            child: ToggleButtons(
              borderRadius: BorderRadius.circular(8),

              isSelected: [!_isMaximization, _isMaximization],

              onPressed: (index) {
                setState(() {
                  _isMaximization = index == 1;
                  _calculate();
                });
              },

              color: textCol,
              selectedColor: Colors.cyanAccent,
              fillColor: Colors.blue.withValues(alpha: 0.3),

              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Minimizar'),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Maximizar'),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ========================================================
            // RESUMEN DE ASIGNACIONES ÓPTIMAS
            // ========================================================

            Card(
              color: cardCol,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Asignaciones Óptimas (Fila ➔ Columna)',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),

                    const Divider(),

                    if (_result.assignments.isEmpty)
                      Text(
                        'No se encontraron asignaciones válidas.',
                        style: TextStyle(color: subTextCol),
                      )
                    else
                      ..._result.assignments.map(
                        (assig) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  assig,

                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textCol,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      'Valor Óptimo Total: '
                      '${_result.optimalValue.toStringAsFixed(2)}',

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========================================================
            // MATRIZ FINAL
            // ========================================================
            Card(
              color: cardCol,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Matriz de Costos / Reducida Final '
                      '(con Sumas y Nodos)',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_result.rowNames.isEmpty)
                      Text('Matriz vacía.', style: TextStyle(color: subTextCol))
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: Text(
                                'Filas / Cols',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                            ),

                            ..._result.colNames.map(
                              (c) => DataColumn(
                                label: Text(
                                  c,

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textCol,
                                  ),
                                ),
                              ),
                            ),

                            // -------------------------------
                            // COLUMNA SUMA
                            // -------------------------------
                            const DataColumn(
                              label: Text(
                                'Suma',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),

                            // -------------------------------
                            // COLUMNA NODOS
                            // -------------------------------
                            const DataColumn(
                              label: Text(
                                'Nodos',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ),
                          ],

                          rows: [
                            // ==================================================
                            // FILAS DE LA MATRIZ
                            // ==================================================

                            ...List.generate(_result.rowNames.length, (rIndex) {
                              final row = rIndex < _result.finalMatrix.length
                                  ? _result.finalMatrix[rIndex]
                                  : <double>[];

                              // Suma de la fila
                              final double rowSum = row.fold(
                                0.0,
                                (sum, value) => sum + value,
                              );

                              // Cantidad de relaciones de la fila
                              final int rowNodes = _countNonZeroInRow(row);

                              return DataRow(
                                cells: [
                                  // Nombre de fila
                                  DataCell(
                                    Text(
                                      _result.rowNames[rIndex],

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textCol,
                                      ),
                                    ),
                                  ),

                                  // Valores de la matriz
                                  ...List.generate(_result.colNames.length, (
                                    cIndex,
                                  ) {
                                    final double val = cIndex < row.length
                                        ? row[cIndex]
                                        : 0.0;

                                    return DataCell(
                                      Text(
                                        val.toStringAsFixed(0),

                                        style: TextStyle(
                                          color: val == 0
                                              ? Colors.greenAccent
                                              : subTextCol,

                                          fontWeight: val == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),

                                  // Suma de la fila
                                  DataCell(
                                    Text(
                                      rowSum.toStringAsFixed(0),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ),

                                  // Nodos de la fila
                                  DataCell(
                                    Text(
                                      '$rowNodes',

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // ==================================================
                            // FILA: SUMA
                            // ==================================================
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    'Suma',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),

                                ...List.generate(_result.colNames.length, (
                                  cIndex,
                                ) {
                                  final double colSum = _sumColumn(
                                    _result.finalMatrix,
                                    cIndex,
                                  );

                                  return DataCell(
                                    Text(
                                      colSum.toStringAsFixed(0),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  );
                                }),

                                // Celda debajo de "Suma"
                                const DataCell(Text('-')),

                                // Celda debajo de "Nodos"
                                const DataCell(Text('-')),
                              ],
                            ),

                            // ==================================================
                            // FILA: NODOS
                            // ==================================================
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    'Nodos',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),

                                ...List.generate(_result.colNames.length, (
                                  cIndex,
                                ) {
                                  final int columnNodes = _countNonZeroInColumn(
                                    _result.finalMatrix,
                                    cIndex,
                                  );

                                  return DataCell(
                                    Text(
                                      '$columnNodes',

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  );
                                }),

                                // Celda debajo de "Suma"
                                const DataCell(Text('-')),

                                // Celda debajo de "Nodos"
                                const DataCell(Text('-')),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========================================================
            // DESGLOSE PASO A PASO
            // ========================================================
            Text(
              'Desglose del Algoritmo Paso a Paso',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),

            const SizedBox(height: 10),

            ..._result.stepByStep.asMap().entries.map((entry) {
              final int index = entry.key;
              final step = entry.value;

              return Card(
                color: cardCol,
                elevation: 3,

                margin: const EdgeInsets.symmetric(vertical: 8.0),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Paso $index: ${step.title}',

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        step.description,

                        style: TextStyle(fontSize: 14, color: subTextCol),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Estado de la matriz en este paso:',

                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textCol,
                        ),
                      ),

                      const SizedBox(height: 8),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          headingRowHeight: 32,
                          dataRowMinHeight: 28,
                          dataRowMaxHeight: 36,

                          columns: [
                            DataColumn(
                              label: Text(
                                '',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                            ),

                            ...step.colNames.map(
                              (c) => DataColumn(
                                label: Text(
                                  c,

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textCol,
                                  ),
                                ),
                              ),
                            ),

                            const DataColumn(
                              label: Text(
                                'Suma',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),

                            const DataColumn(
                              label: Text(
                                'Nodos',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ),
                          ],

                          rows: [
                            // ==================================================
                            // FILAS DEL PASO
                            // ==================================================

                            ...List.generate(step.rowNames.length, (rIndex) {
                              final List<double> row =
                                  rIndex < step.matrixSnapshot.length
                                  ? step.matrixSnapshot[rIndex]
                                  : <double>[];

                              // Suma de fila
                              final double rowSum = row.fold(
                                0.0,
                                (sum, value) => sum + value,
                              );

                              // Nodos/relaciones de la fila
                              final int rowNodes = _countNonZeroInRow(row);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      step.rowNames[rIndex],

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textCol,
                                      ),
                                    ),
                                  ),

                                  ...List.generate(step.colNames.length, (
                                    cIndex,
                                  ) {
                                    final double cellVal = cIndex < row.length
                                        ? row[cIndex]
                                        : 0.0;

                                    return DataCell(
                                      Text(
                                        cellVal.toStringAsFixed(0),

                                        style: TextStyle(
                                          color: cellVal == 0
                                              ? Colors.greenAccent
                                              : subTextCol,

                                          fontWeight: cellVal == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),

                                  // Suma de la fila
                                  DataCell(
                                    Text(
                                      rowSum.toStringAsFixed(0),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ),

                                  // Nodos de la fila
                                  DataCell(
                                    Text(
                                      '$rowNodes',

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // ==================================================
                            // SUMA DE COLUMNAS
                            // ==================================================
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    'Suma',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),

                                ...List.generate(step.colNames.length, (
                                  cIndex,
                                ) {
                                  final double colSum = _sumColumn(
                                    step.matrixSnapshot,
                                    cIndex,
                                  );

                                  return DataCell(
                                    Text(
                                      colSum.toStringAsFixed(0),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  );
                                }),

                                const DataCell(Text('-')),

                                const DataCell(Text('-')),
                              ],
                            ),

                            // ==================================================
                            // NODOS POR COLUMNA
                            // ==================================================
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    'Nodos',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),

                                ...List.generate(step.colNames.length, (
                                  cIndex,
                                ) {
                                  final int columnNodes = _countNonZeroInColumn(
                                    step.matrixSnapshot,
                                    cIndex,
                                  );

                                  return DataCell(
                                    Text(
                                      '$columnNodes',

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  );
                                }),

                                const DataCell(Text('-')),

                                const DataCell(Text('-')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
