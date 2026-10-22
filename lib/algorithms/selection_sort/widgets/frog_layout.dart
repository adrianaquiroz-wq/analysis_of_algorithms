import 'dart:math';

/// Medidas del escenario: dónde cae cada lugar de la fila, dónde está el
/// suelo y cuánto espacio queda arriba para el búho y los saltos.
class FrogLayout {
  /// Altura máxima de un salto (px).
  static const double maxJump = 110;

  final int n;
  final double slotW;
  final double frogW;
  final double owlW;
  final double width;
  final double height;
  final double groundY;
  final double pad;

  const FrogLayout._({
    required this.n,
    required this.slotW,
    required this.frogW,
    required this.owlW,
    required this.width,
    required this.height,
    required this.groundY,
    required this.pad,
  });

  factory FrogLayout({required int n, required double maxWidth}) {
    final slotW = (maxWidth / n).clamp(40.0, 64.0).toDouble();
    final frogW = slotW * 0.82;
    final owlW = frogW * 1.15;
    final width = max(maxWidth, n * slotW + 16);
    final frogMaxH = frogW * 1.12;

    // Arriba tiene que caber el búho flotando sobre la rana más alta, y el
    // salto más grande.
    final owlBand = frogMaxH + 54 + owlW * 1.2;
    final jumpBand = maxJump + frogMaxH;
    final groundY = max(owlBand, jumpBand) + 14;

    return FrogLayout._(
      n: n,
      slotW: slotW,
      frogW: frogW,
      owlW: owlW,
      width: width,
      height: groundY + 62,
      groundY: groundY,
      pad: (width - n * slotW) / 2,
    );
  }

  /// Centro horizontal del lugar [slot].
  double xOf(int slot) => pad + slot * slotW + slotW / 2;

  /// Altura (sobre el suelo) a la que flota el búho.
  double get owlY => groundY - frogW * 1.12 - 50;

  /// Si cambia, el escenario cambió de tamaño: no se anima, se recoloca.
  String get sizeKey =>
      '$n|${slotW.toStringAsFixed(2)}|${width.toStringAsFixed(1)}';
}
