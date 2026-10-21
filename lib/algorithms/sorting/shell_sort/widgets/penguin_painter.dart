import 'package:flutter/material.dart';

/// Dibuja un pingüino que se estira a lo alto según el tamaño recibido.
/// Los rasgos (ojos, pico, patas) se escalan con el ANCHO, así el pingüino
/// grande se ve más alto y no más deformado.
class PenguinPainter extends CustomPainter {
  final Color bodyColor;
  final int value;
  final bool highlighted;

  const PenguinPainter({
    required this.bodyColor,
    required this.value,
    required this.highlighted,
  });

  static const Color _belly = Color(0xFFF8FAFC);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _ink = Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final feet = w * 0.22;
    final dark = Color.lerp(bodyColor, Colors.black, 0.25)!;

    // Aletas (detrás del cuerpo).
    final flipperLen = (h * 0.35).clamp(w * 0.5, w * 1.0).toDouble();
    final flipperY = w * 0.85 + flipperLen / 2;
    _flipper(
      canvas,
      Offset(w * 0.02, flipperY),
      w * 0.2,
      flipperLen,
      -0.22,
      dark,
    );
    _flipper(
      canvas,
      Offset(w * 0.98, flipperY),
      w * 0.2,
      flipperLen,
      0.22,
      dark,
    );

    // Cuerpo.
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h - feet * 0.5),
      topLeft: Radius.circular(w / 2),
      topRight: Radius.circular(w / 2),
      bottomLeft: Radius.circular(w * 0.3),
      bottomRight: Radius.circular(w * 0.3),
    );
    canvas.drawRRect(body, Paint()..color = bodyColor);

    // Panza.
    canvas.drawOval(
      Rect.fromLTRB(w * 0.16, w * 0.62, w * 0.84, h - feet * 0.9),
      Paint()..color = _belly,
    );

    // Ojos.
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = _ink;
    for (final x in [0.34, 0.66]) {
      canvas.drawCircle(Offset(w * x, w * 0.36), w * 0.11, white);
      canvas.drawCircle(Offset(w * x, w * 0.37), w * 0.05, pupil);
    }

    // Pico.
    final beak = Path()
      ..moveTo(w * 0.38, w * 0.46)
      ..lineTo(w * 0.62, w * 0.46)
      ..lineTo(w * 0.5, w * 0.58)
      ..close();
    canvas.drawPath(beak, Paint()..color = _orange);

    // Patas.
    final footPaint = Paint()..color = _orange;
    for (final x in [0.3, 0.7]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h - feet * 0.45),
          width: w * 0.34,
          height: feet,
        ),
        footPaint,
      );
    }

    // Número sobre la panza.
    final tp = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: _ink,
          fontSize: (w * 0.36).clamp(9.0, 16.0).toDouble(),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, w * 0.72));

    // Contorno cuando se está intercambiando.
    if (highlighted) {
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.amberAccent,
      );
    }
  }

  void _flipper(
    Canvas canvas,
    Offset center,
    double width,
    double length,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: width, height: length),
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PenguinPainter old) =>
      old.bodyColor != bodyColor ||
      old.value != value ||
      old.highlighted != highlighted;
}
