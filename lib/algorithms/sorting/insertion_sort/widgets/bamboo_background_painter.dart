import 'package:flutter/material.dart';

/// Dibuja un fondo ilustrado estilo caricatura ("cartoon") de un bosque de bambú.
/// Consta de cañas estilizadas en varias capas de profundidad, con sus nudos,
/// hojas puntiagudas y una suave base de colinas verdes.
class BambooBackgroundPainter extends CustomPainter {
  final bool isDark;

  const BambooBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Degradado suave del cielo / ambiente del bosque
    final skyRect = Offset.zero & size;
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF061814),
                Color(0xFF0D2821),
                Color(0xFF13362C),
              ]
            : const [
                Color(0xFFF0FDF4),
                Color(0xFFDCFCE7),
                Color(0xFFD1FAE5),
              ],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Cañas lejanas (más tenues / niebla)
    final farColor = isDark
        ? const Color(0xFF114235).withValues(alpha: 0.45)
        : const Color(0xFFA7F3D0).withValues(alpha: 0.65);
    _drawBambooStalk(canvas, x: w * 0.12, width: 14, height: h, color: farColor, segmentH: 60);
    _drawBambooStalk(canvas, x: w * 0.38, width: 12, height: h, color: farColor, segmentH: 55);
    _drawBambooStalk(canvas, x: w * 0.62, width: 16, height: h, color: farColor, segmentH: 65);
    _drawBambooStalk(canvas, x: w * 0.88, width: 13, height: h, color: farColor, segmentH: 58);

    // 3. Cañas medias (color principal)
    final midColor = isDark
        ? const Color(0xFF1B5E4B).withValues(alpha: 0.75)
        : const Color(0xFF6EE7B7).withValues(alpha: 0.85);
    _drawBambooStalk(canvas, x: w * 0.04, width: 20, height: h, color: midColor, segmentH: 70);
    _drawBambooStalk(canvas, x: w * 0.25, width: 22, height: h, color: midColor, segmentH: 75);
    _drawBambooStalk(canvas, x: w * 0.50, width: 18, height: h, color: midColor, segmentH: 68);
    _drawBambooStalk(canvas, x: w * 0.74, width: 24, height: h, color: midColor, segmentH: 80);
    _drawBambooStalk(canvas, x: w * 0.95, width: 20, height: h, color: midColor, segmentH: 72);

    // 4. Hojitas flotantes sueltas (detalles decorativos estilo anime)
    final leafColor = isDark
        ? const Color(0xFF34D399).withValues(alpha: 0.30)
        : const Color(0xFF10B981).withValues(alpha: 0.35);
    _drawFloatingLeaf(canvas, Offset(w * 0.18, h * 0.25), 18, 0.4, leafColor);
    _drawFloatingLeaf(canvas, Offset(w * 0.44, h * 0.18), 15, -0.6, leafColor);
    _drawFloatingLeaf(canvas, Offset(w * 0.80, h * 0.22), 20, 0.8, leafColor);
    _drawFloatingLeaf(canvas, Offset(w * 0.65, h * 0.35), 14, -0.3, leafColor);
  }

  /// Dibuja una caña de bambú vertical con nudos y ramas con hojas
  void _drawBambooStalk(
    Canvas canvas, {
    required double x,
    required double width,
    required double height,
    required Color color,
    required double segmentH,
  }) {
    final stalkPaint = Paint()..color = color;
    final nodeColor = isDark
        ? Color.lerp(color, Colors.white, 0.18)!
        : Color.lerp(color, const Color(0xFF047857), 0.25)!;
    final nodePaint = Paint()
      ..color = nodeColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var currentY = 0.0;
    var nodeIndex = 0;

    while (currentY < height) {
      final segH = segmentH + (nodeIndex % 3 == 0 ? 8 : -4);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - width / 2, currentY, width, segH - 3),
        const Radius.circular(3),
      );
      canvas.drawRRect(rrect, stalkPaint);

      // Anillo de nudo
      final nodeY = currentY + segH;
      canvas.drawLine(
        Offset(x - width / 2 - 2, nodeY - 3),
        Offset(x + width / 2 + 2, nodeY - 3),
        nodePaint,
      );

      // Cada 2 nudos dibujamos un grupito de hojitas estilizadas
      if (nodeIndex % 2 == 1 && nodeY < height * 0.85) {
        final toRight = (nodeIndex % 4 == 1);
        _drawLeafCluster(
          canvas,
          origin: Offset(toRight ? x + width / 2 : x - width / 2, nodeY - 3),
          toRight: toRight,
          color: color,
        );
      }

      currentY += segH;
      nodeIndex++;
    }
  }

  /// Dibuja un racimo de 2 o 3 hojas alargadas de bambú
  void _drawLeafCluster(
    Canvas canvas, {
    required Offset origin,
    required bool toRight,
    required Color color,
  }) {
    final paint = Paint()
      ..color = Color.lerp(color, isDark ? Colors.white : const Color(0xFF059669), 0.20)!
      ..style = PaintingStyle.fill;

    final dir = toRight ? 1.0 : -1.0;

    // Hoja principal
    final p1 = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx + 20 * dir,
        origin.dy - 12,
        origin.dx + 38 * dir,
        origin.dy - 6,
      )
      ..quadraticBezierTo(
        origin.dx + 22 * dir,
        origin.dy + 4,
        origin.dx,
        origin.dy,
      )
      ..close();
    canvas.drawPath(p1, paint);

    // Hoja secundaria más pequeña
    final p2 = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx + 16 * dir,
        origin.dy + 8,
        origin.dx + 30 * dir,
        origin.dy + 18,
      )
      ..quadraticBezierTo(
        origin.dx + 14 * dir,
        origin.dy + 16,
        origin.dx,
        origin.dy,
      )
      ..close();
    canvas.drawPath(p2, paint);
  }

  /// Dibuja una hojita individual flotando con ángulo
  void _drawFloatingLeaf(Canvas canvas, Offset center, double length, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(-length / 2, 0)
      ..quadraticBezierTo(0, -length * 0.35, length / 2, 0)
      ..quadraticBezierTo(0, length * 0.35, -length / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BambooBackgroundPainter old) => old.isDark != isDark;
}

