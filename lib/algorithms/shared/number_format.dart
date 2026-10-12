/// Entero si es entero; si no, con 2 decimales.
String fmtNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
