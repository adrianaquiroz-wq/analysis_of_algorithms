import 'package:flutter/material.dart';

import '../models/edge_model.dart';
import '../models/node_model.dart';
import '../utils/northwest_corner_algorithm.dart';
import '../utils/transportation_optimizer.dart';

class NorthwestCornerScreen extends StatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final bool isDarkMode;

  const NorthwestCornerScreen({
    super.key,
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
  });

  @override
  State<NorthwestCornerScreen> createState() => _NorthwestCornerScreenState();
}

class _NorthwestCornerScreenState extends State<NorthwestCornerScreen> {
  bool _isMaximization = false;
  late List<TextEditingController> _supplyControllers;
  late List<TextEditingController> _demandControllers;
  NorthwestCornerResult? _nwResult;
  List<OptimizationIteration>? _iterations;
  String? _error;

  List<NodeModel> get _groupA => widget.nodes
      .where((n) => n.bipartiteGroup == BipartiteGroup.groupA)
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));

  List<NodeModel> get _groupB => widget.nodes
      .where((n) => n.bipartiteGroup == BipartiteGroup.groupB)
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));

  @override
  void initState() {
    super.initState();
    final groupA = _groupA;
    final groupB = _groupB;

    _supplyControllers = groupA
        .map((n) => TextEditingController(text: _numericOrDefault(n.attribute1)))
        .toList();
    _demandControllers = groupB
        .map((n) => TextEditingController(text: _numericOrDefault(n.attribute2)))
        .toList();

    if (groupA.isNotEmpty && groupB.isNotEmpty) {
      _calculate();
    } else {
      _error = 'Para resolver el problema, primero debes asignar nodos al Conjunto A (Orígenes) y al Conjunto B (Destinos) en el editor del grafo.';
    }
  }

  String _numericOrDefault(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed != null && parsed >= 0 ? _format(parsed) : '1';
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

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
        final groupA = _groupA;
        final groupB = _groupB;

        if (groupA.isEmpty || groupB.isEmpty) {
          throw ArgumentError('Requiere nodos en Conjunto A y Conjunto B.');
        }

        final costs = _buildCostMatrix(groupA, groupB);
        final supplies = _parseControllers(_supplyControllers);
        final demands = _parseControllers(_demandControllers);

        // Fase 1: Esquina Noroeste
        _nwResult = NorthwestCornerAlgorithm.solve(
          costs: costs,
          supplies: supplies,
          demands: demands,
          rowNames: groupA.map((n) => n.label.isNotEmpty ? n.label : n.id).toList(),
          colNames: groupB.map((n) => n.label.isNotEmpty ? n.label : n.id).toList(),
        );

        // Fase 2: Optimización MODI / Salto de la Rana
        _iterations = TransportationOptimizer.optimize(
          initialAllocations: _nwResult!.allocations,
          costs: _nwResult!.costs,
          isMaximization: _isMaximization,
          nwSteps: _nwResult!.steps, // <--- ¡ESTA ES LA LÍNEA QUE FALTABA!
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
      final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
      if (value == null || value < 0) {
        throw ArgumentError('Valores deben ser >= 0.');
      }
      values.add(value);
    }
    return values;
  }

  List<List<double>> _buildCostMatrix(
      List<NodeModel> groupA, List<NodeModel> groupB) {
    final rowIndex = {for (int i = 0; i < groupA.length; i++) groupA[i].id: i};
    final colIndex = {for (int j = 0; j < groupB.length; j++) groupB[j].id: j};

    final matrix = List.generate(
        groupA.length, (_) => List<double>.filled(groupB.length, 0));

    for (final edge in widget.edges) {
      final row = rowIndex[edge.sourceId];
      final column = colIndex[edge.targetId];

      if (row != null && column != null) {
        matrix[row][column] = edge.weight;
        continue;
      }

      final reverseRow = rowIndex[edge.targetId];
      final reverseColumn = colIndex[edge.sourceId];

      if (edge.type == EdgeType.simple &&
          reverseRow != null &&
          reverseColumn != null) {
        matrix[reverseRow][reverseColumn] = edge.weight;
      }
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;
    final bg = dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = dark ? const Color(0xFF1E293B) : Colors.white;
    final text = dark ? Colors.white : Colors.black87;
    final sub = dark ? Colors.white70 : Colors.black54;
    final accent = dark ? const Color(0xFF67E8F9) : Colors.blueAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: Text('Transporte (NW + MODI)', style: TextStyle(color: text)),
        iconTheme: IconThemeData(color: text),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              isSelected: [!_isMaximization, _isMaximization],
              onPressed: (index) {
                setState(() => _isMaximization = index == 1);
              },
              color: text,
              selectedColor: Colors.cyanAccent,
              fillColor: Colors.blue.withValues(alpha: .3),
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Minimizar')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Maximizar')),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupplyDemandCard(card, text, sub, accent),
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
                  color: Colors.red.withOpacity(0.2),
                  child: Text(_error!, style: TextStyle(color: text))),
            ],
            if (_nwResult != null && _iterations != null) ...[
              const SizedBox(height: 20),
              Text('Fase 1: Esquina Noroeste (Solución Básica Inicial)',
                  style: TextStyle(
                      color: text, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildMatrixCard(card, text, sub, _nwResult!.allocations,
                  _nwResult!.total, 'C_1', false),
              const SizedBox(height: 20),
              Text('Fase 2: Optimización MODI (Iteraciones)',
                  style: TextStyle(
                      color: text, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...List.generate(_iterations!.length, (index) {
                final iter = _iterations![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMatrixCard(
                    card,
                    text,
                    sub,
                    iter.allocations,
                    iter.totalValue,
                    'C_${index + 2}',
                    iter.isOptimal,
                    enteringRow: iter.enteringRow,
                    enteringCol: iter.enteringCol,
                    theta: iter.theta,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyDemandCard(
      Color card, Color text, Color sub, Color accent) {
    final groupA = _groupA;
    final groupB = _groupB;

    if (groupA.isEmpty || groupB.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Oferta y demanda',
            style: TextStyle(
                color: text, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Conjunto A — Orígenes / Oferta',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(groupA.length, (i) {
          final name =
              groupA[i].label.isNotEmpty ? groupA[i].label : groupA[i].id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                child: Text(name,
                    style: TextStyle(
                        color: text, fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _supplyControllers[i],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: text),
                  decoration: const InputDecoration(
                    labelText: 'Oferta',
                    isDense: true,
                  ),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Text('Conjunto B — Destinos / Demanda',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(groupB.length, (i) {
          final name =
              groupB[i].label.isNotEmpty ? groupB[i].label : groupB[i].id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                child: Text(name,
                    style: TextStyle(
                        color: text, fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _demandControllers[i],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: text),
                  decoration: const InputDecoration(
                    labelText: 'Demanda',
                    isDense: true,
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildMatrixCard(
      Color cardColor,
      Color text,
      Color sub,
      List<List<double>> matrix,
      double total,
      String label,
      bool isFinal,
      {int? enteringRow,
      int? enteringCol,
      double? theta}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isFinal ? Border.all(color: Colors.greenAccent, width: 3) : null,
        boxShadow: isFinal
            ? [
                BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2)
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isFinal ? '¡Resultado Final Óptimo!' : 'Iteración',
                  style: TextStyle(
                      color: isFinal ? Colors.greenAccent : text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('$label = ${_format(total)}',
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (enteringRow != null) ...[
            Text(
                'Entra a la base: ${_nwResult!.rowNames[enteringRow]} → ${_nwResult!.colNames[enteringCol!]} (θ = ${_format(theta ?? 0)})',
                style: TextStyle(color: sub)),
            const SizedBox(height: 12),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              columns: [
                DataColumn(
                    label: Text('O / D',
                        style: TextStyle(
                            color: sub, fontWeight: FontWeight.bold))),
                ..._nwResult!.colNames.map((c) => DataColumn(
                    label: Text(c,
                        style: TextStyle(
                            color: sub, fontWeight: FontWeight.bold)))),
              ],
              rows: List.generate(matrix.length, (r) {
                return DataRow(cells: [
                  DataCell(Text(_nwResult!.rowNames[r],
                      style:
                          TextStyle(color: sub, fontWeight: FontWeight.bold))),
                  ...List.generate(matrix[r].length, (c) {
                    final val = matrix[r][c];
                    return DataCell(Text(
                      val == 0 ? '-' : _format(val),
                      style: TextStyle(
                          color: text,
                          fontWeight:
                              val > 0 ? FontWeight.bold : FontWeight.normal),
                    ));
                  }),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}