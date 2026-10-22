import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_controller.dart';
import 'package:graph_app/algorithms/shared/number_format.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'frog_layout.dart';
import 'frog_painter.dart';
import 'frog_sim.dart';

/// Escenario de la animación: una pista con una rana por valor (más grande
/// mientras mayor el número) y un búho juez que recorre la fila buscando a
/// la más pequeña. Al terminar la pasada, esa rana salta al primer lugar
/// sin ordenar y se intercambia con la que estaba ahí.
class SelectionStage extends StatefulWidget {
  final AppPalette palette;
  final SelectionSortController controller;

  /// Texto bajo cada rana (por ejemplo la arista "A → B" en modo grafo).
  /// Si es null no se muestra nada.
  final List<String>? labels;

  const SelectionStage({
    super.key,
    required this.palette,
    required this.controller,
    this.labels,
  });

  @override
  State<SelectionStage> createState() => _SelectionStageState();
}

class _SelectionStageState extends State<SelectionStage>
    with SingleTickerProviderStateMixin {
  final FrogSim _sim = FrogSim();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => _sim.tick(elapsed.inMicroseconds / 1e6))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final p = widget.palette;
    final n = c.values.length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final layout = FrogLayout(n: n, maxWidth: box.maxWidth);
          _sim.update(
            layout: layout,
            values: c.values,
            labels: widget.labels ?? List.filled(n, ''),
            valueLabels: [for (final v in c.values) fmtNumber(v.toDouble())],
            descending: c.descending,
            order: c.order,
            sortedCount: c.sortedCount,
            scanSlot: c.scanSlot,
            minSlot: c.minSlot,
            selectedSlot: c.selectedSlot,
            owlSlot: c.owlSlot,
            jumperId: c.jumperId,
            done: c.isDone,
            moveSeconds: c.jumpDuration.inMilliseconds / 1000.0,
          );

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: layout.width,
                height: layout.height,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: FrogPainter(sim: _sim, isDark: p.isDark),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
