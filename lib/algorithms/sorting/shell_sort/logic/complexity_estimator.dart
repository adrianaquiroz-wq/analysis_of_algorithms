import 'dart:math';

import 'shell_sort_algorithm.dart';

/// Resultado de estimar la complejidad de UN conjunto de números.
class ComplexityEstimate {
  /// Fracción de pares de números que están en el orden contrario al pedido
  /// (0 = ya ordenado, 1 = completamente al revés).
  final double disorder;

  /// k en O(n^k).
  final double exponent;

  const ComplexityEstimate({required this.disorder, required this.exponent});

  /// Cota teórica del peor caso con la secuencia de Knuth.
  bool get withinBound => exponent <= 1.5;

  String get label => 'O(n^${exponent.toStringAsFixed(2)})';
}

/// Big O describe cómo CRECE el costo al aumentar n, así que una sola lista
/// no tiene una respuesta directa. La estimación se hace en tres pasos:
///  1. Se mide qué tan desordenado está el conjunto.
///  2. Se generan listas más grandes (128 a 2048) con ese mismo nivel de
///     desorden.
///  3. Se ejecuta Shell Sort en cada tamaño y se ajusta una recta en escala
///     log-log: su pendiente es el exponente k.
class ComplexityEstimator {
  static const List<int> sizes = [128, 256, 512, 1024, 2048];
  static const int _samples = 3;

  static ComplexityEstimate estimate(
    List<int> input, {
    required bool descending,
  }) {
    final n = input.length;
    final disorder = _disorder(input, descending);

    // Si está más cerca del reverso que del orden, se parte de la lista
    // al revés.
    final reversed = disorder > 0.5;
    final target = reversed ? 1 - disorder : disorder;
    final q = _calibrate(n, target, reversed, descending);

    final xs = <double>[];
    final ys = <double>[];
    for (final m in sizes) {
      final rng = Random(m);
      var total = 0;
      for (var s = 0; s < _samples; s++) {
        total += ShellSortAlgorithm.comparisonsOf(
          _replica(m, q, reversed, descending, rng),
          descending: descending,
        );
      }
      xs.add(log(m));
      ys.add(log(total / _samples));
    }
    return ComplexityEstimate(disorder: disorder, exponent: _slope(xs, ys));
  }

  /// Fracción de pares fuera de orden respecto a la dirección pedida.
  static double _disorder(List<int> a, bool descending) {
    var inversions = 0;
    for (var i = 0; i < a.length; i++) {
      for (var j = i + 1; j < a.length; j++) {
        if (descending ? a[i] < a[j] : a[i] > a[j]) inversions++;
      }
    }
    return inversions / (a.length * (a.length - 1) / 2);
  }

  /// Lista de tamaño [m] que parte del orden pedido (o de su reverso) y
  /// mezcla entre sí una fracción [q] de sus posiciones.
  static List<int> _replica(
    int m,
    double q,
    bool reversed,
    bool descending,
    Random rng,
  ) {
    var base = List<int>.generate(m, (i) => descending ? m - i : i + 1);
    if (reversed) base = base.reversed.toList();

    final chosen = (List<int>.generate(
      m,
      (i) => i,
    )..shuffle(rng)).take((q * m).round()).toList();
    final values = chosen.map((i) => base[i]).toList()..shuffle(rng);
    for (var k = 0; k < chosen.length; k++) {
      base[chosen[k]] = values[k];
    }
    return base;
  }

  /// Busca (bisección) la fracción [q] cuyo desorden promedio, en listas de
  /// tamaño [n], se parece al del conjunto del usuario.
  static double _calibrate(int n, double target, bool reversed, bool desc) {
    var lo = 0.0;
    var hi = 1.0;
    for (var it = 0; it < 12; it++) {
      final mid = (lo + hi) / 2;
      final rng = Random(11);
      var sum = 0.0;
      for (var s = 0; s < 12; s++) {
        sum += _disorder(_replica(n, mid, reversed, desc, rng), desc);
      }
      var avg = sum / 12;
      if (reversed) avg = 1 - avg;
      if (avg < target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// Pendiente de la recta de mínimos cuadrados.
  static double _slope(List<double> xs, List<double> ys) {
    final mx = xs.reduce((a, b) => a + b) / xs.length;
    final my = ys.reduce((a, b) => a + b) / ys.length;
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < xs.length; i++) {
      numerator += (xs[i] - mx) * (ys[i] - my);
      denominator += (xs[i] - mx) * (xs[i] - mx);
    }
    return numerator / denominator;
  }
}
