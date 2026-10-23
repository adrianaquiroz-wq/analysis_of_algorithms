import 'dart:math';

/// Reglas y utilidades para los números que se van a ordenar.
class SortInput {
  static const int minCount = 2;
  static const int maxCount = 100;
  static const int minValue = 1;
  static const int maxValue = 100;
  static const List<int> defaultValues = [45, 12, 78, 33, 90, 5, 60, 21];

  /// Convierte "34, 7 85" en una lista. Lanza [FormatException] con un
  /// mensaje listo para mostrar si algo no es válido.
  static List<int> parse(String text) {
    final parts = text.split(RegExp(r'[\s,;]+')).where((p) => p.isNotEmpty);
    final values = <int>[];
    for (final p in parts) {
      final v = int.tryParse(p);
      if (v == null || v < minValue || v > maxValue) {
        throw const FormatException(
          'Usa solo enteros entre $minValue y $maxValue.',
        );
      }
      values.add(v);
    }
    if (values.length < minCount) {
      throw const FormatException('Ingresa al menos $minCount números.');
    }
    if (values.length > maxCount) {
      throw const FormatException('Máximo $maxCount números.');
    }
    return values;
  }

  /// Valida la cantidad pedida en el modo aleatorio.
  static int parseCount(String text) {
    final c = int.tryParse(text.trim());
    if (c == null || c < minCount || c > maxCount) {
      throw const FormatException(
        'La cantidad debe estar entre $minCount y $maxCount.',
      );
    }
    return c;
  }

  static List<int> random(int count, [Random? rng]) {
    final r = rng ?? Random();
    return List.generate(
      count,
      (_) => minValue + r.nextInt(maxValue - minValue + 1),
    );
  }
}
