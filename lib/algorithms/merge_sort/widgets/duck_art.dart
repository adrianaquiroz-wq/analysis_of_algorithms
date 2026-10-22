import 'dart:math';

import 'package:flutter/material.dart';

/// Dibujo del patito. El origen es el centro de la base (la línea de agua),
/// el patito mira a la derecha y `u` es su ancho en píxeles.
class DuckArt {
  static const Color body = Color(0xFFFFD54F);
  static const Color wing = Color(0xFFFFB300);
  static const Color beak = Color(0xFFFF7043);
  static const Color ink = Color(0xFF1B2A41);

  /// Cuerpo, cola, cabeza, pico, ojo y ala (sin el número).
  static void paint(Canvas canvas, double u) {
    final fill = Paint()..color = body;

    // Cola (detrás del cuerpo).
    final tail = Path()
      ..moveTo(-0.36 * u, -0.34 * u)
      ..quadraticBezierTo(-0.64 * u, -0.34 * u, -0.66 * u, -0.58 * u)
      ..quadraticBezierTo(-0.50 * u, -0.48 * u, -0.28 * u, -0.50 * u)
      ..close();
    canvas.drawPath(tail, fill);

    // Cuerpo y cabeza.
    canvas.drawOval(Rect.fromLTRB(-0.50 * u, -0.58 * u, 0.44 * u, -0.02 * u), fill);
    canvas.drawCircle(Offset(0.24 * u, -0.68 * u), 0.23 * u, fill);

    // Brillo suave en la cabeza.
    canvas.drawCircle(
      Offset(0.18 * u, -0.77 * u),
      0.07 * u,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // Ala (atrás, para dejar libre el centro del cuerpo).
    canvas.save();
    canvas.translate(-0.22 * u, -0.26 * u);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.36 * u, height: 0.20 * u),
      Paint()..color = wing,
    );
    canvas.restore();

    // Pico.
    final b = Path()
      ..moveTo(0.40 * u, -0.74 * u)
      ..quadraticBezierTo(0.66 * u, -0.70 * u, 0.64 * u, -0.64 * u)
      ..quadraticBezierTo(0.56 * u, -0.58 * u, 0.40 * u, -0.60 * u)
      ..close();
    canvas.drawPath(b, Paint()..color = beak);

    // Ojo.
    canvas.drawCircle(
      Offset(0.30 * u, -0.72 * u),
      0.04 * u,
      Paint()..color = ink,
    );
    canvas.drawCircle(
      Offset(0.315 * u, -0.735 * u),
      0.013 * u,
      Paint()..color = Colors.white,
    );
  }

  /// Número del patito, centrado sobre el cuerpo (nunca se voltea).
  static void paintNumber(Canvas canvas, double u, TextPainter tp) {
    tp.paint(canvas, Offset(-tp.width / 2 + 0.02 * u, -0.30 * u - tp.height / 2));
  }

  static TextPainter numberPainter(int value, double u) {
    return TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: ink,
          fontSize: (u * 0.34).clamp(9.0, 16.0).toDouble(),
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Destello de cuatro puntas (para el efecto mágico de la fusión).
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

/// Un patito suelto para la tarjeta del carrusel.
class DuckPreviewPainter extends CustomPainter {
  final int value;
  final bool isDark;
  const DuckPreviewPainter({required this.value, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final u = min(size.width, size.height / 0.9);
    final x = size.width / 2;
    final y = size.height - 6;

    // Ondas del agua bajo el patito.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = (isDark ? Colors.cyanAccent : Colors.blueAccent).withValues(
        alpha: 0.45,
      );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: u * 1.1, height: u * 0.26),
      ring,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: u * 1.5, height: u * 0.36),
      ring..color = ring.color.withValues(alpha: 0.2),
    );

    canvas.save();
    canvas.translate(x, y);
    DuckArt.paint(canvas, u);
    DuckArt.paintNumber(canvas, u, DuckArt.numberPainter(value, u));
    canvas.restore();
  }

  @override
  bool shouldRepaint(DuckPreviewPainter old) =>
      old.value != value || old.isDark != isDark;
}
