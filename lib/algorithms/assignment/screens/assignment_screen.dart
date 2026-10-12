import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/assignment/logic/assignment_solver.dart';
import 'package:graph_app/algorithms/assignment/widgets/assignment_summary_card.dart';
import 'package:graph_app/algorithms/assignment/widgets/final_matrix_card.dart';
import 'package:graph_app/algorithms/shared/widgets/objective_toggle.dart';
import 'package:graph_app/algorithms/assignment/widgets/original_matrix_card.dart';
import 'package:graph_app/algorithms/assignment/widgets/step_by_step_section.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

class AssignmentScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final bool isBipartiteMode;

  const AssignmentScreen({
    super.key,
    required this.nodes,
    required this.edges,
    required this.isBipartiteMode,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _isMaximization = false;
  late MatrixResult _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    _result = widget.isBipartiteMode
        ? AssignmentSolver.solveBipartite(
            nodes: widget.nodes,
            edges: widget.edges,
            isMaximization: _isMaximization,
          )
        : AssignmentSolver.solveLinear(
            nodes: widget.nodes,
            edges: widget.edges,
            isMaximization: _isMaximization,
          );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) {
        final p = AppPalette(isDark);

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.appBar,
            iconTheme: IconThemeData(color: p.text),
            title: Text(
              widget.isBipartiteMode
                  ? 'Asignación Bipartita (Húngaro)'
                  : 'Asignación Lineal',
              style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
            ),
            actions: [
              ObjectiveToggle(
                palette: p,
                isMaximization: _isMaximization,
                onChanged: (value) => setState(() {
                  _isMaximization = value;
                  _calculate();
                }),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssignmentSummaryCard(result: _result, palette: p),
                const SizedBox(height: 20),
                OriginalMatrixCard(result: _result, palette: p),
                const SizedBox(height: 20),
                FinalMatrixCard(result: _result, palette: p),
                const SizedBox(height: 20),
                StepByStepSection(result: _result, palette: p),
              ],
            ),
          ),
        );
      },
    );
  }
}
