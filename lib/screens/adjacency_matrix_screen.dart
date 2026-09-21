import 'package:flutter/material.dart';

import '../models/node_model.dart';

import '../models/edge_model.dart';

import '../utils/matrix_optimizer_utils.dart';

class AdjacencyMatrixScreen extends StatefulWidget {
  final List<NodeModel> nodes;

  final List<EdgeModel> edges;

  final bool isDarkMode;

  final ValueChanged<bool>? onToggleTheme;

  const AdjacencyMatrixScreen({
    Key? key,

    required this.nodes,

    required this.edges,

    this.isDarkMode = true,

    this.onToggleTheme,
  }) : super(key: key);

  @override
  State<AdjacencyMatrixScreen> createState() => _AdjacencyMatrixScreenState();
}

class _AdjacencyMatrixScreenState extends State<AdjacencyMatrixScreen> {
  bool _isMaximization = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    // Paleta dinámica (mismo esquema que HelpScreen)

    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final titleColor = isDarkMode ? Colors.white : Colors.black87;

    final accentColor = isDarkMode
        ? const Color.fromARGB(255, 108, 176, 176)
        : Colors.blueAccent;

    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final cardBorderColor = isDarkMode ? Colors.white12 : Colors.black12;

    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final chipBackground = isDarkMode ? const Color(0xFF334155) : Colors.white;

    final chipSelectedColor = isDarkMode
        ? const Color(0xFF0E7490).withOpacity(0.35)
        : const Color.fromARGB(255, 120, 154, 182);

    final chipSelectedTextColor = isDarkMode
        ? const Color.fromARGB(255, 133, 175, 180)
        : Colors.blue[900];

    final tableHeaderColor = isDarkMode
        ? const Color(0xFF334155)
        : Colors.grey[200];

    final tableBorderColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;

    final result = MatrixOptimizerUtils.solveLinearAssignment(
      nodes: widget.nodes,

      edges: widget.edges,

      isMaximization: _isMaximization,
    );

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: appBarColor,

        elevation: isDarkMode ? 0 : 1,

        title: Text(
          "Matriz de Adyacencia y Optimización",

          style: TextStyle(color: titleColor, fontSize: 18),
        ),

        iconTheme: IconThemeData(color: accentColor),

        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,

                color: accentColor,
              ),

              onPressed: () => widget.onToggleTheme!(!isDarkMode),
            ),
        ],
      ),

      body: widget.nodes.isEmpty
          ? Center(
              child: Text(
                "No hay nodos en el grafo.",

                style: TextStyle(color: subTextColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Selector de modo (Maximizar / Minimizar)

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      ChoiceChip(
                        label: const Text("Maximizar"),

                        selected: _isMaximization,

                        selectedColor: chipSelectedColor,

                        backgroundColor: chipBackground,

                        labelStyle: TextStyle(
                          color: _isMaximization
                              ? chipSelectedTextColor
                              : textColor,

                          fontWeight: FontWeight.bold,
                        ),

                        onSelected: (selected) {
                          setState(() {
                            _isMaximization = true;
                          });
                        },
                      ),

                      const SizedBox(width: 12),

                      ChoiceChip(
                        label: const Text("Minimizar"),

                        selected: !_isMaximization,

                        selectedColor: chipSelectedColor,

                        backgroundColor: chipBackground,

                        labelStyle: TextStyle(
                          color: !_isMaximization
                              ? chipSelectedTextColor
                              : textColor,

                          fontWeight: FontWeight.bold,
                        ),

                        onSelected: (selected) {
                          setState(() {
                            _isMaximization = false;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tarjeta de Resultado Óptimo
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: cardColor,

                      borderRadius: BorderRadius.circular(12),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.2 : 0.15,
                          ),

                          blurRadius: 6,

                          offset: const Offset(0, 3),
                        ),
                      ],

                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),

                    child: Column(
                      children: [
                        Text(
                          _isMaximization
                              ? "VALOR ÓPTIMO DE MAXIMIZACIÓN"
                              : "VALOR ÓPTIMO DE MINIMIZACIÓN",

                          style: TextStyle(
                            color: subTextColor,

                            fontSize: 12,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          result.optimalValue.toStringAsFixed(1),

                          style: TextStyle(
                            color: accentColor,

                            fontSize: 36,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Matriz Original de Adyacencia
                  Text(
                    "Matriz de Adyacencia Original",

                    style: TextStyle(
                      color: textColor,

                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildMatrixTable(
                    result.rowNames,

                    result.originalMatrix,

                    textColor: textColor,

                    subTextColor: subTextColor,

                    headerColor: tableHeaderColor,

                    borderColor: tableBorderColor,

                    cellBackground: cardColor,
                  ),

                  const SizedBox(height: 24),

                  // Matriz Reducida / Final Optimizada
                  Text(
                    "Matriz Final Optimizada",

                    style: TextStyle(
                      color: textColor,

                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildMatrixTable(
                    result.rowNames,

                    result.finalMatrix,

                    textColor: textColor,

                    subTextColor: subTextColor,

                    headerColor: tableHeaderColor,

                    borderColor: tableBorderColor,

                    cellBackground: cardColor,
                  ),

                  const SizedBox(height: 24),

                  // Pasos del algoritmo
                  Text(
                    "Detalle del Proceso",

                    style: TextStyle(
                      color: textColor,

                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: cardColor,

                      borderRadius: BorderRadius.circular(8),

                      border: Border.all(color: cardBorderColor),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.15 : 0.1,
                          ),

                          blurRadius: 4,

                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Text(
                      result.calculationSteps,

                      style: TextStyle(
                        color: subTextColor,

                        fontSize: 13,

                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMatrixTable(
    List<String> names,

    List<List<double>> matrix, {

    required Color textColor,

    required Color subTextColor,

    required Color? headerColor,

    required Color borderColor,

    required Color cellBackground,
  }) {
    if (names.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Table(
        defaultColumnWidth: const FixedColumnWidth(60),

        border: TableBorder.all(color: borderColor),

        children: [
          // Fila de Encabezados (Columnas)

          TableRow(
            decoration: BoxDecoration(color: headerColor),

            children: [
              const Padding(padding: EdgeInsets.all(8.0), child: Text("")),

              for (var name in names)
                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: Text(
                    name,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: textColor,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // Filas de la Matriz
          for (int i = 0; i < names.length; i++)
            TableRow(
              decoration: BoxDecoration(color: cellBackground),

              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: Text(
                    names[i],

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: textColor,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                for (int j = 0; j < names.length; j++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),

                    child: Text(
                      matrix[i][j] == matrix[i][j].roundToDouble()
                          ? matrix[i][j].toInt().toString()
                          : matrix[i][j].toStringAsFixed(1),

                      textAlign: TextAlign.center,

                      style: TextStyle(color: subTextColor),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
