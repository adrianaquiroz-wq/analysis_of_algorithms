import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/northwest/logic/northwest_corner_algorithm.dart';
import 'package:graph_app/algorithms/northwest/logic/transport_cost_matrix.dart';
import 'package:graph_app/algorithms/northwest/logic/transportation_optimizer.dart';
import 'package:graph_app/algorithms/northwest/widgets/northwest_results.dart';
import 'package:graph_app/algorithms/northwest/widgets/supply_demand_card.dart';
import 'package:graph_app/algorithms/shared/bipartite_groups.dart';
import 'package:graph_app/algorithms/shared/number_format.dart';
import 'package:graph_app/algorithms/shared/widgets/objective_toggle.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/models/node_model.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

class NorthwestScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;

  const NorthwestScreen({super.key, required this.nodes, required this.edges});

  @override
  State<NorthwestScreen> createState() => _NorthwestScreenState();
}

class _NorthwestScreenState extends State<NorthwestScreen> {
  bool _isMaximization = false;
  late List<TextEditingController> _supplyControllers;
  late List<TextEditingController> _demandControllers;
  NorthwestCornerResult? _nwResult;
  List<OptimizationIteration>? _iterations;
  String? _error;

  late final BipartiteGroups _groups = BipartiteGroups.of(widget.nodes);
  late final List<List<double>> _costs = TransportCostMatrix.build(
    groupA: _groups.groupA,
    groupB: _groups.groupB,
    edges: widget.edges,
  );

  @override
  void initState() {
    super.initState();

    _supplyControllers = _groups.groupA
        .map(
          (n) => TextEditingController(text: _numericOrDefault(n.attribute1)),
        )
        .toList();
    _demandControllers = _groups.groupB
        .map(
          (n) => TextEditingController(text: _numericOrDefault(n.attribute2)),
        )
        .toList();

    if (_groups.isComplete) {
      _calculate();
    } else {
      _error = 'Para resolver el problema, primero debes asignar nodos al Conjunto A (Orígenes) y al Conjunto B (Destinos) en el editor del grafo.';
    }
  }

  String _numericOrDefault(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed != null && parsed >= 0 ? fmtNumber(parsed) : '1';
  }

  @override
  void dispose() {
    for (final controller in _supplyControllers) {
      controller.dispose();
    }
    for (final controller in _demandControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _error = null;
      try {
        if (!_groups.isComplete) {
          throw ArgumentError('Requiere nodos en Conjunto A y Conjunto B.');
        }

        final supplies = _parseControllers(_supplyControllers);
        final demands = _parseControllers(_demandControllers);

        // Fase 1: Esquina Noroeste
        _nwResult = NorthwestCornerAlgorithm.solve(
          costs: _costs,
          supplies: supplies,
          demands: demands,
          rowNames: _groups.groupA.map(nodeDisplayName).toList(),
          colNames: _groups.groupB.map(nodeDisplayName).toList(),
        );

        // Fase 2: Optimización MODI / Salto de la Rana
        _iterations = TransportationOptimizer.optimize(
          initialAllocations: _nwResult!.allocations,
          costs: _nwResult!.costs,
          isMaximization: _isMaximization,
          nwSteps: _nwResult!.steps,
        );
      } catch (e) {
        _nwResult = null;
        _iterations = null;
        _error = e.toString().replaceFirst('Invalid argument(s): ', '');
      }
    });
  }

  List<double> _parseControllers(List<TextEditingController> controllers) {
    final values = <double>[];
    for (final controller in controllers) {
      final value = double.tryParse(
        controller.text.trim().replaceAll(',', '.'),
      );
      if (value == null || value < 0) {
        throw ArgumentError('Valores deben ser >= 0.');
      }
      values.add(value);
    }
    return values;
  }

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
        backgroundColor: p.card,
        title: Text('Transporte (NW + MODI)', style: TextStyle(color: p.text)),
        iconTheme: IconThemeData(color: p.text),
        actions: [
          ObjectiveToggle(
            palette: p,
            isMaximization: _isMaximization,
            onChanged: (value) => setState(() => _isMaximization = value),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_groups.isComplete)
              SupplyDemandCard(
                palette: p,
                groupA: _groups.groupA,
                groupB: _groups.groupB,
                costs: _costs,
                supplyControllers: _supplyControllers,
                demandControllers: _demandControllers,
                result: _nwResult,
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resolver Problema Completo'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                color: Colors.red.withValues(alpha: 0.2),
                child: Text(_error!, style: TextStyle(color: p.text)),
              ),
            ],
            if (_nwResult != null && _iterations != null)
              NorthwestResults(
                palette: p,
                result: _nwResult!,
                iterations: _iterations!,
              ),
          ],
        ),
      ),
    );
  }
}
