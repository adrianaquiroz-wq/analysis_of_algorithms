import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graph_app/algorithms/merge_sort/logic/merge_sort_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'pond_layout.dart';
import 'pond_painter.dart';
import 'pond_sim.dart';

/// Escenario de la animación: un estanque con un patito por valor.
///  - Dividir: los patitos nadan hacia abajo, a la fila del siguiente nivel,
///    por corrientes de agua luminosas.
///  - Fusionar: de cada comparación, el ganador sube a su lugar con un
///    destello de agua.
/// Mientras más grande el número, más grande el patito.
class MergeStage extends StatefulWidget {
  final AppPalette palette;
  final MergeSortController controller;

  const MergeStage({
    super.key,
    required this.palette,
    required this.controller,
  });

  @override
  State<MergeStage> createState() => _MergeStageState();
}

class _MergeStageState extends State<MergeStage>
    with SingleTickerProviderStateMixin {
  final PondSim _sim = PondSim();
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final layout = PondLayout(
            n: c.values.length,
            levels: c.levels,
            maxWidth: box.maxWidth,
            boundaries: c.boundaries,
          );
          _sim.update(
            layout: layout,
            values: c.values,
            rows: c.rows,
            slots: c.slots,
            comparing: c.comparing,
            placedId: c.placedId,
            placeSerial: c.placeSerial,
            splits: List.of(c.splits),
            newSplit: c.newSplit,
            splitSerial: c.splitSerial,
            moveSeconds: c.moveDuration.inMilliseconds / 1000.0,
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
                    painter: PondPainter(sim: _sim, isDark: p.isDark),
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
