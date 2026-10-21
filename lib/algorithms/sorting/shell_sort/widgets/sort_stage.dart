import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/gap_bracket_painter.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/penguin_painter.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Escenario de la animación: un pingüino por valor, con altura
/// proporcional al número. Muestra el salto h de dos formas:
///  - un corchete entre los dos pingüinos que se intercambian;
///  - puntos de color debajo de cada posición: los del mismo color forman
///    una sublista, que es la que se ordena por inserción en esa pasada.
class SortStage extends StatelessWidget {
  final AppPalette palette;
  final List<int> values;
  final List<int> order;
  final Set<int> movers;
  final int? hopper;

  /// Si es false, el par solo se marca (ya respeta el orden) y no se levanta.
  final bool lifted;
  final int? activeI;
  final int? activeJ;
  final int? gap;
  final Duration duration;

  const SortStage({
    super.key,
    required this.palette,
    required this.values,
    required this.order,
    required this.movers,
    required this.hopper,
    required this.lifted,
    required this.activeI,
    required this.activeJ,
    required this.gap,
    required this.duration,
  });

  static const double _height = 390;
  static const double _topBand = 34; // corchete
  static const double _bottomBand = 26; // puntos de sublista
  static const double _ground = 8;
  static const double _highLift = 46; // el que salta
  static const double _lowLift = 10; // el que se queda abajo
  static const double _minSlot = 38;
  static const double _maxSlot = 64;

  @override
  Widget build(BuildContext context) {
    final n = values.length;
    final maxValue = values.reduce(max);

    // slotOf[id] = posición actual del pingüino id.
    final slotOf = List<int>.filled(n, 0);
    for (var s = 0; s < n; s++) {
      slotOf[order[s]] = s;
    }

    // Los que se mueven se dibujan encima; el que salta, al frente de todo.
    int weight(int id) => id == hopper ? 2 : (movers.contains(id) ? 1 : 0);
    final ids = List<int>.generate(n, (i) => i)
      ..sort((a, b) => weight(a) - weight(b));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final slotW = (c.maxWidth / n).clamp(_minSlot, _maxSlot).toDouble();
          final contentW = slotW * n;
          final width = max(c.maxWidth, contentW);
          final offset = (width - contentW) / 2;
          double centerOf(int slot) => offset + slot * slotW + slotW / 2;

          final w = slotW * 0.78;
          final minH = w * 1.6;
          final maxH =
              _height - _topBand - _bottomBand - _ground - _highLift - 4;
          const baseline = _bottomBand + _ground;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: _height,
              child: Stack(
                children: [
                  // Suelo.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _bottomBand,
                    height: _ground,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Puntos de sublista (solo mientras hay un salto activo).
                  if (gap != null)
                    for (var s = 0; s < n; s++)
                      Positioned(
                        left: centerOf(s) - 5,
                        bottom: 6,
                        width: 10,
                        height: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _sublistColor(s % gap!, gap!),
                          ),
                        ),
                      ),
                  // Pingüinos.
                  for (final id in ids)
                    AnimatedPositioned(
                      key: ValueKey(id),
                      duration: duration,
                      curve: Curves.easeInOut,
                      left: offset + slotOf[id] * slotW + (slotW - w) / 2,
                      bottom:
                          baseline +
                          (!lifted
                              ? 0
                              : id == hopper
                              ? _highLift
                              : (movers.contains(id) ? _lowLift : 0)),
                      width: w,
                      height: minH + (maxH - minH) * values[id] / maxValue,
                      child: CustomPaint(
                        painter: PenguinPainter(
                          bodyColor: HSLColor.fromAHSL(
                            1,
                            200 + 150 * values[id] / maxValue,
                            0.55,
                            0.42,
                          ).toColor(),
                          value: values[id],
                          highlighted: movers.contains(id),
                        ),
                      ),
                    ),
                  // Corchete del salto.
                  if (activeI != null && activeJ != null && gap != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: GapBracketPainter(
                            x1: centerOf(activeI!),
                            x2: centerOf(activeJ!),
                            label: 'h = $gap',
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Color de la sublista [k] entre [total] sublistas.
  static Color _sublistColor(int k, int total) =>
      HSLColor.fromAHSL(1, 360.0 * k / total, 0.75, 0.55).toColor();
}
