import 'dart:math';

import 'package:flutter/material.dart';

/// Dibujo de la rana. Origen: centro de la base (el suelo). Mira de frente
/// y `u` es su ancho en píxeles; mide unos 0.98·u de alto.
class FrogArt {
  static const Color body = Color(0xFF66BB6A);
  static const Color dark = Color(0xFF2E7D32);
  static const Color feet = Color(0xFF388E3C);
  static const Color belly = Color(0xFFC8E6C9);
  static const Color ink = Color(0xFF1B3A1F);

  /// [look]: -1..1, hacia dónde miran las pupilas. [blink]: ojos cerrados.
  static void paint(
    Canvas canvas,
    double u, {
    double look = 0,
    bool blink = false,
  }) {
    final fill = Paint()..color = body;

    // Patas traseras.
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.40 * u, -0.15 * u),
          width: 0.34 * u,
          height: 0.24 * u,
        ),
        Paint()..color = dark,
      );
    }

    // Cuerpo y panza.
    canvas.drawOval(
      Rect.fromLTRB(-0.50 * u, -0.74 * u, 0.50 * u, -0.06 * u),
      fill,
    );
    canvas.drawOval(
      Rect.fromLTRB(-0.34 * u, -0.56 * u, 0.34 * u, -0.08 * u),
      Paint()..color = belly,
    );

    // Ojos saltones.
    for (final s in [-1.0, 1.0]) {
      final c = Offset(s * 0.27 * u, -0.78 * u);
      canvas.drawCircle(c, 0.20 * u, fill);
      if (blink) {
        canvas.drawCircle(c, 0.15 * u, fill);
        canvas.drawLine(
          c.translate(-0.12 * u, 0),
          c.translate(0.12 * u, 0),
          Paint()
            ..color = ink
            ..strokeWidth = 0.04 * u
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawCircle(c, 0.15 * u, Paint()..color = Colors.white);
        canvas.drawCircle(
          c.translate(look * 0.05 * u, 0.015 * u),
          0.075 * u,
          Paint()..color = ink,
        );
        canvas.drawCircle(
          c.translate(look * 0.05 * u + 0.025 * u, -0.02 * u),
          0.022 * u,
          Paint()..color = Colors.white,
        );
      }
    }

    // Sonrisa y mejillas.
    canvas.drawPath(
      Path()
        ..moveTo(-0.22 * u, -0.60 * u)
        ..quadraticBezierTo(0, -0.47 * u, 0.22 * u, -0.60 * u),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.035 * u
        ..strokeCap = StrokeCap.round
        ..color = ink,
    );
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.36 * u, -0.57 * u),
          width: 0.13 * u,
          height: 0.07 * u,
        ),
        Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.5),
      );
    }

    // Patas delanteras.
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.30 * u, -0.05 * u),
          width: 0.26 * u,
          height: 0.10 * u,
        ),
        Paint()..color = feet,
      );
    }
  }

  /// Número centrado sobre la panza (nunca se deforma).
  static void paintNumber(Canvas canvas, double u, TextPainter tp) {
    tp.paint(canvas, Offset(-tp.width / 2, -0.31 * u - tp.height / 2));
  }

  static TextPainter text(
    String text,
    double fontSize, {
    Color color = ink,
    FontWeight weight = FontWeight.w800,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  static TextPainter numberPainter(String value, double u) =>
      text(value, (u * 0.30).clamp(9.0, 15.0).toDouble());

  /// Estrella de cuatro puntas (corona de las ranas ya ordenadas).
  static Path sparkle(double r) {
    final k = r * 0.22;
    return Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(k, -k, r, 0)
      ..quadraticBezierTo(k, k, 0, r)
      ..quadraticBezierTo(-k, k, -r, 0)
      ..quadraticBezierTo(-k, -k, 0, -r)
      ..close();
  }
}

/// El búho juez. Origen: centro de la base. `u` es su ancho.
/// Sostiene una lupa; su centro queda en [lens] (en unidades de `u`).
class OwlArt {
  static const Color feather = Color(0xFF8D6E63);
  static const Color wing = Color(0xFF6D4C41);
  static const Color belly = Color(0xFFD7CCC8);
  static const Color face = Color(0xFFEFEBE9);
  static const Color amber = Color(0xFFFFCA28);
  static const Color beak = Color(0xFFFF8F00);

  /// Centro de la lupa respecto al origen, en unidades de `u`.
  static const Offset lens = Offset(0.56, -0.12);

  /// [flap]: fase del aleteo. [look]: -1..1 hacia dónde miran las pupilas.
  static void paint(Canvas canvas, double u, {double flap = 0, double look = 0}) {
    final fill = Paint()..color = feather;

    // Alas (detrás del cuerpo), aleteando.
    for (final s in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(s * 0.36 * u, -0.66 * u);
      canvas.rotate(s * (0.45 + sin(flap) * 0.30));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.08 * u, 0.20 * u),
          width: 0.26 * u,
          height: 0.56 * u,
        ),
        Paint()..color = wing,
      );
      canvas.restore();
    }

    // Orejas (plumas de la cabeza).
    for (final s in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(s * 0.34 * u, -0.96 * u)
          ..lineTo(s * 0.46 * u, -1.16 * u)
          ..lineTo(s * 0.16 * u, -1.00 * u)
          ..close(),
        fill,
      );
    }

    // Cuerpo y panza con plumitas.
    canvas.drawOval(
      Rect.fromLTRB(-0.42 * u, -1.02 * u, 0.42 * u, -0.14 * u),
      fill,
    );
    canvas.drawOval(
      Rect.fromLTRB(-0.27 * u, -0.66 * u, 0.27 * u, -0.17 * u),
      Paint()..color = belly,
    );
    final scallop = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.025 * u
      ..color = feather.withValues(alpha: 0.55);
    for (var row = 0; row < 2; row++) {
      for (var col = -1; col <= 1; col++) {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(col * 0.14 * u + (row.isOdd ? 0.07 * u : 0),
                -0.46 * u + row * 0.12 * u),
            width: 0.12 * u,
            height: 0.09 * u,
          ),
          0,
          pi,
          false,
          scallop,
        );
      }
    }

    // Cara: dos discos y ojos grandes.
    for (final s in [-1.0, 1.0]) {
      final c = Offset(s * 0.17 * u, -0.80 * u);
      canvas.drawCircle(c, 0.20 * u, Paint()..color = face);
      canvas.drawCircle(c, 0.14 * u, Paint()..color = amber);
      canvas.drawCircle(
        c.translate(look * 0.04 * u, 0.02 * u),
        0.075 * u,
        Paint()..color = const Color(0xFF1B1B1B),
      );
      canvas.drawCircle(
        c.translate(look * 0.04 * u + 0.025 * u, -0.01 * u),
        0.022 * u,
        Paint()..color = Colors.white,
      );
    }

    // Pico.
    canvas.drawPath(
      Path()
        ..moveTo(0, -0.74 * u)
        ..lineTo(-0.06 * u, -0.66 * u)
        ..lineTo(0, -0.60 * u)
        ..lineTo(0.06 * u, -0.66 * u)
        ..close(),
      Paint()..color = beak,
    );

    // Patitas.
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.14 * u, -0.10 * u),
          width: 0.20 * u,
          height: 0.08 * u,
        ),
        Paint()..color = beak,
      );
    }

    // Lupa en el ala derecha.
    final lc = Offset(lens.dx * u, lens.dy * u);
    canvas.drawLine(
      Offset(0.46 * u, -0.40 * u),
      lc.translate(-0.07 * u, -0.10 * u),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 0.05 * u
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      lc,
      0.15 * u,
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
    canvas.drawCircle(
      lc,
      0.15 * u,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.045 * u
        ..color = const Color(0xFFFFB300),
    );
  }
}

/// Una rana suelta para la tarjeta del carrusel.
class FrogPreviewPainter extends CustomPainter {
  final String value;
  final bool isDark;
  const FrogPreviewPainter({required this.value, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final u = min(size.width, size.height / 0.98);
    final x = size.width / 2;
    final y = size.height - 5;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 4), width: u * 0.95, height: u * 0.18),
      Paint()..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
    );

    canvas.save();
    canvas.translate(x, y);
    FrogArt.paint(canvas, u);
    FrogArt.paintNumber(canvas, u, FrogArt.numberPainter(value, u));
    canvas.restore();
  }

  @override
  bool shouldRepaint(FrogPreviewPainter old) =>
      old.value != value || old.isDark != isDark;
}
