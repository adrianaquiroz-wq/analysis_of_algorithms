import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/assignment_solver.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

import 'widgets/adjacency_matrix_table.dart';
import 'widgets/objective_chips.dart';
import 'widgets/optimal_value_card.dart';

class AdjacencyMatrixScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;

  const AdjacencyMatrixScreen({
    super.key,
    required this.nodes,
    required this.edges,
  });

  @override
  State<AdjacencyMatrixScreen> createState() => _AdjacencyMatrixScreenState();
}

class _AdjacencyMatrixScreenState extends State<AdjacencyMatrixScreen> {
  bool _isMaximization = true;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _buildScreen(AppPalette(isDark)),
    );
  }

  Widget _buildScreen(AppPalette p) {
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.appBar,
        elevation: p.isDark ? 0 : 1,
        iconTheme: IconThemeData(color: p.accent),
        title: Text(
          'Matriz de Adyacencia y Optimización',
          style: TextStyle(color: p.text, fontSize: 18),
        ),
      ),
      body: widget.nodes.isEmpty
          ? Center(
              child: Text(
                'No hay nodos en el grafo.',
                style: TextStyle(color: p.subtleText),
              ),
            )
          : _buildBody(p),
    );
  }

  Widget _buildBody(AppPalette p) {
    final result = AssignmentSolver.solveLinear(
      nodes: widget.nodes,
      edges: widget.edges,
      isMaximization: _isMaximization,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectiveChips(
            palette: p,
            isMaximization: _isMaximization,
            onChanged: (value) => setState(() => _isMaximization = value),
          ),
          const SizedBox(height: 24),
          OptimalValueCard(
            palette: p,
            isMaximization: _isMaximization,
            value: result.optimalValue,
          ),
          const SizedBox(height: 24),
          _title('Matriz de Adyacencia Original', p),
          AdjacencyMatrixTable(
            names: result.rowNames,
            matrix: result.originalMatrix,
            palette: p,
          ),
          const SizedBox(height: 24),
          _title('Matriz Final Optimizada', p),
          AdjacencyMatrixTable(
            names: result.rowNames,
            matrix: result.finalMatrix,
            palette: p,
          ),
          const SizedBox(height: 24),
          _title('Detalle del Proceso', p),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.cardBorder),
            ),
            child: Text(
              result.calculationSteps,
              style: TextStyle(
                color: p.subtleText,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text, AppPalette p) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        color: p.text,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
