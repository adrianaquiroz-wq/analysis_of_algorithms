import 'dart:math';

/// Dónde cae cada posición (slot) y cada fila (nivel) en el estanque.
///
/// Los cortes entre segmentos separan a los patitos con un hueco, así al
/// dividir se ve cómo la lista se abre en grupos y al fusionar se cierra.
class PondLayout {
  final int n;
  final int levels;
  final double slotW;
  final double duckW;
  final double duckH;
  final double gap;
  final double rowH;
  final double top;
  final double width;
  final double height;
  final double offset;
  final List<int> cuts;

  const PondLayout._({
    required this.n,
    required this.levels,
    required this.slotW,
    required this.duckW,
    required this.duckH,
    required this.gap,
    required this.rowH,
    required this.top,
    required this.width,
    required this.height,
    required this.offset,
    required this.cuts,
  });

  factory PondLayout({
    required int n,
    required int levels,
    required double maxWidth,
    required Iterable<int> boundaries,
  }) {
    final slotW = (maxWidth / n).clamp(34.0, 56.0).toDouble();
    final duckW = slotW * 0.84;
    final duckH = duckW * 0.92;
    final gap = min(16.0, slotW * 0.4);
    final rowH = duckH + 44;
    const top = 20.0;
    final cuts = boundaries.toList()..sort();

    final fullW = n * slotW + max(0, n - 1) * gap + 24;
    final width = max(maxWidth, fullW);
    final contentW = n * slotW + cuts.length * gap;

    return PondLayout._(
      n: n,
      levels: levels,
      slotW: slotW,
      duckW: duckW,
      duckH: duckH,
      gap: gap,
      rowH: rowH,
      top: top,
      width: width,
      height: top + duckH * 1.15 + (levels - 1) * rowH + 30,
      offset: (width - contentW) / 2,
      cuts: cuts,
    );
  }

  /// Centro horizontal de la posición [slot].
  double xOf(int slot) {
    var shifted = 0;
    for (final c in cuts) {
      if (c <= slot) shifted++;
    }
    return offset + slot * slotW + slotW / 2 + shifted * gap;
  }

  /// Línea de agua (base de los patitos) de la fila [row].
  double yOf(int row) => top + duckH * 1.15 + row * rowH;

  /// Si cambia, el escenario cambió de tamaño: no se anima, se recoloca.
  String get sizeKey =>
      '$n|$levels|${slotW.toStringAsFixed(2)}|${width.toStringAsFixed(1)}';
}
