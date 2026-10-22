import 'package:flutter/material.dart';

/// Estados de ánimo / expresiones faciales del osito panda.
enum PandaMood {
  /// Durmiendo plácidamente con ojitos cerrados y "z Z" flotando (esperando su turno).
  sleeping,

  /// Clave activa: ojitos curiosos, brote grande en la cabeza y bracitos arriba.
  curious,

  /// Comparándose: ojos bien blancos mirando directamente en dirección a su contraparte.
  lookingUp,

  /// ¡Victoria al terminar!: ojitos en arquito (^ ^), boca abierta festejando y rubor brillante.
  celebrating,

  /// Normal / ordenado: ojitos brillantes kawaii mirando al frente con sonrisa tierna.
  normal,
}

/// Dibuja un osito panda gordito y súper tierno ("chubby kawaii panda").
/// Proporciones regordetas, mejillas redondas con rubor, barriga prominente,
/// ojos expresivos de alto contraste con esclerótica blanca que miran directamente al otro panda.
class PandaPainter extends CustomPainter {
  final int value;
  final bool isLifted;
  final bool isComparing;
  final bool isSorted;
  final PandaMood mood;

  /// Vector de mirada normalizado (dx: -1 a 1, dy: -1 a 1 donde negativo es arriba y positivo es abajo).
  /// Permite que los dos pandas hagan contacto visual directo según sus alturas relativas.
  final Offset? gazeDirection;
  final Color accentColor;

  const PandaPainter({
    required this.value,
    this.isLifted = false,
    this.isComparing = false,
    this.isSorted = false,
    this.mood = PandaMood.normal,
    this.gazeDirection,
    this.accentColor = const Color(0xFF10B981),
  });

  static const Color _blackFur = Color(0xFF1A2232);
  static const Color _whiteFur = Color(0xFFFFFFFF);
  static const Color _creamBelly = Color(0xFFF8FAFC);
  static const Color _pinkBlush = Color(0xFFFF94B4);
  static const Color _innerEar = Color(0xFFFFB6CE);
  static const Color _bambooGreen = Color(0xFF22C55E);
  static const Color _bambooDark = Color(0xFF15803D);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Resplandor cálido cuando está levantado (clave) o comparándose
    if (isLifted || isComparing) {
      final glowColor = isLifted
          ? const Color(0xFFFBBF24).withValues(alpha: 0.50)
          : const Color(0xFF38BDF8).withValues(alpha: 0.50);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-6, -6, w + 12, h + 12),
          Radius.circular(w * 0.45),
        ),
        Paint()
          ..color = glowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // =========================================================
    // 1. OREJITAS REDONDAS Y ESPONJOSAS (Detrás de la cabeza)
    // =========================================================
    final earR = w * 0.21;
    final leftEarCenter = Offset(w * 0.18, w * 0.16);
    final rightEarCenter = Offset(w * 0.82, w * 0.16);

    final blackPaint = Paint()..color = _blackFur;
    canvas.drawCircle(leftEarCenter, earR, blackPaint);
    canvas.drawCircle(rightEarCenter, earR, blackPaint);

    final innerEarPaint = Paint()..color = _innerEar;
    canvas.drawCircle(leftEarCenter, earR * 0.55, innerEarPaint);
    canvas.drawCircle(rightEarCenter, earR * 0.55, innerEarPaint);

    // =========================================================
    // 2. BROTE DE BAMBÚ GRANDE EN LA CABEZA (Si está levantado o curioso)
    // =========================================================
    if (isLifted || mood == PandaMood.curious) {
      _drawBigBambooSprout(canvas, Offset(w * 0.50, w * 0.08), w * 0.48);
    }

    // =========================================================
    // 3. BURBUJA "z Z" SI ESTÁ DURMIENDO (Esperando su turno)
    // =========================================================
    if (mood == PandaMood.sleeping) {
      final tpZ = TextPainter(
        text: const TextSpan(
          text: 'z Z',
          style: TextStyle(
            color: Color(0xFF60A5FA),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpZ.paint(canvas, Offset(w * 0.74, -w * 0.05));
    }

    // =========================================================
    // 4. PATITAS TRASERAS / PIES GORDITOS (Base)
    // =========================================================
    final footW = w * 0.32;
    final footH = w * 0.22;
    final leftFootRect = Rect.fromCenter(
      center: Offset(w * 0.26, h - footH * 0.45),
      width: footW,
      height: footH,
    );
    final rightFootRect = Rect.fromCenter(
      center: Offset(w * 0.74, h - footH * 0.45),
      width: footW,
      height: footH,
    );

    canvas.drawOval(leftFootRect, blackPaint);
    canvas.drawOval(rightFootRect, blackPaint);

    final padPaint = Paint()..color = _innerEar;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.26, h - footH * 0.42), width: footW * 0.50, height: footH * 0.45),
      padPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.74, h - footH * 0.42), width: footW * 0.50, height: footH * 0.45),
      padPaint,
    );

    // =========================================================
    // 5. CUERPO GORDITO Y RECHONCHO (Silueta de pera)
    // =========================================================
    final bodyPath = Path()
      ..moveTo(w * 0.15, w * 0.35)
      ..cubicTo(-w * 0.06, w * 0.75, -w * 0.02, h - footH * 0.8, w * 0.18, h - footH * 0.3)
      ..lineTo(w * 0.82, h - footH * 0.3)
      ..cubicTo(w * 1.02, h - footH * 0.8, w * 1.06, w * 0.75, w * 0.85, w * 0.35)
      ..cubicTo(w * 0.82, w * 0.04, w * 0.18, w * 0.04, w * 0.15, w * 0.35)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = _whiteFur);

    // =========================================================
    // 6. CHALECO NEGRO Y BRACITOS GORDITOS
    // =========================================================
    final vestH = (h * 0.36).clamp(w * 0.45, w * 1.1).toDouble();
    final vestPath = Path()
      ..moveTo(-w * 0.05, w * 0.52)
      ..lineTo(w * 1.05, w * 0.52)
      ..lineTo(w * 1.05, w * 0.52 + vestH * 0.6)
      ..quadraticBezierTo(w * 0.50, w * 0.52 + vestH * 0.3, -w * 0.05, w * 0.52 + vestH * 0.6)
      ..close();

    canvas.save();
    canvas.clipPath(bodyPath);
    canvas.drawPath(vestPath, blackPaint);
    canvas.restore();

    final armY = (isLifted || mood == PandaMood.celebrating) ? w * 0.52 : w * 0.66;
    final armAngle = (isLifted || mood == PandaMood.celebrating)
        ? 0.50
        : (mood == PandaMood.lookingUp ? 0.20 : 0.35);

    _drawChubbyArm(
      canvas,
      center: Offset(w * 0.10, armY),
      width: w * 0.24,
      length: w * 0.34,
      angle: -armAngle,
      paint: blackPaint,
    );
    _drawChubbyArm(
      canvas,
      center: Offset(w * 0.90, armY),
      width: w * 0.24,
      length: w * 0.34,
      angle: armAngle,
      paint: blackPaint,
    );

    // =========================================================
    // 7. PARCHES NEGROS Y OJOS EXPRESIVOS DE ALTO CONTRASTE
    // =========================================================
    final leftPatch = Offset(w * 0.32, w * 0.40);
    final rightPatch = Offset(w * 0.68, w * 0.40);

    _drawEyePatch(canvas, leftPatch, w * 0.16, w * 0.20, -0.22);
    _drawEyePatch(canvas, rightPatch, w * 0.16, w * 0.20, 0.22);

    _drawExpressiveEye(canvas, leftPatch, w * 0.12, w * 0.15, mood, gazeDirection);
    _drawExpressiveEye(canvas, rightPatch, w * 0.12, w * 0.15, mood, gazeDirection);

    // =========================================================
    // 8. NARIZ, BOCA EXPRESIVA Y MEJILLAS SONROSADAS
    // =========================================================
    final nosePath = Path()
      ..moveTo(w * 0.44, w * 0.49)
      ..lineTo(w * 0.56, w * 0.49)
      ..quadraticBezierTo(w * 0.50, w * 0.55, w * 0.44, w * 0.49)
      ..close();
    canvas.drawPath(nosePath, blackPaint);

    _drawExpressiveMouth(canvas, w, mood);

    final blushPaint = Paint()..color = _pinkBlush.withValues(alpha: 0.88);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.18, w * 0.52), width: w * 0.18, height: w * 0.12),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.82, w * 0.52), width: w * 0.18, height: w * 0.12),
      blushPaint,
    );

    // =========================================================
    // 9. BARRIGUITA GRANDE Y REDONDA CON EL NÚMERO
    // =========================================================
    final bellyW = w * 0.72;
    final bellyH = (h - w * 0.82).clamp(w * 0.48, h * 0.52).toDouble();
    final bellyY = w * 0.74 + bellyH / 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, bellyY), width: bellyW, height: bellyH),
      Paint()..color = _creamBelly,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: _blackFur,
          fontSize: (w * 0.36).clamp(11.0, 20.0).toDouble(),
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, bellyY - tp.height / 2));

    // =========================================================
    // 10. CONTORNOS DE ESTADO
    // =========================================================
    if (isLifted) {
      canvas.drawPath(
        bodyPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8
          ..color = const Color(0xFFFBBF24),
      );
    } else if (isComparing) {
      canvas.drawPath(
        bodyPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..color = const Color(0xFF38BDF8),
      );
    } else if (isSorted) {
      canvas.drawPath(
        bodyPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = const Color(0xFF22C55E).withValues(alpha: 0.75),
      );
    }
  }

  /// Dibuja los ojos según el estado de ánimo y el vector de mirada `gazeDirection`:
  /// La esclerótica es blanca pura para un contraste máximo. Si hay `gazeDirection`,
  /// la pupila se desplaza en esa dirección exacta para hacer contacto visual directo.
  void _drawExpressiveEye(Canvas canvas, Offset center, double ew, double eh, PandaMood m, Offset? gaze) {
    switch (m) {
      case PandaMood.sleeping:
        final p = Path()
          ..moveTo(center.dx - ew * 0.45, center.dy + eh * 0.05)
          ..quadraticBezierTo(center.dx, center.dy + eh * 0.35, center.dx + ew * 0.45, center.dy + eh * 0.05);
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.8,
        );
        break;

      case PandaMood.celebrating:
        final p = Path()
          ..moveTo(center.dx - ew * 0.50, center.dy + eh * 0.20)
          ..quadraticBezierTo(center.dx, center.dy - eh * 0.28, center.dx + ew * 0.50, center.dy + eh * 0.20);
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 3.2,
        );
        break;

      case PandaMood.lookingUp:
      case PandaMood.curious:
      case PandaMood.normal:
        // 1. Esclerótica blanca grande ovalada
        final eyeRect = Rect.fromCenter(center: center, width: ew * 1.15, height: eh * 1.15);
        canvas.drawOval(eyeRect, Paint()..color = Colors.white);

        // 2. Posición de la pupila calculada según la dirección del panda contraparte
        Offset pupilCenter = center;
        if (gaze != null) {
          // Desplazamiento proporcional en X e Y
          final maxDx = ew * 0.32 * gaze.dx;
          final maxDy = eh * 0.32 * gaze.dy;
          pupilCenter = Offset(center.dx + maxDx, center.dy + maxDy);
        } else if (m == PandaMood.lookingUp) {
          // Si no hay vector explícito pero está en lookingUp, mira arriba por defecto
          pupilCenter = Offset(center.dx, center.dy - eh * 0.30);
        } else if (m == PandaMood.curious) {
          pupilCenter = Offset(center.dx - ew * 0.12, center.dy - eh * 0.12);
        }

        final pupilR = ew * 0.38;
        canvas.drawCircle(pupilCenter, pupilR, Paint()..color = const Color(0xFF0F172A));

        // 3. Destellos blancos tiernos (reflejos de luz)
        canvas.drawCircle(
          Offset(pupilCenter.dx - pupilR * 0.35, pupilCenter.dy - pupilR * 0.35),
          pupilR * 0.48,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(pupilCenter.dx + pupilR * 0.35, pupilCenter.dy + pupilR * 0.35),
          pupilR * 0.24,
          Paint()..color = Colors.white.withValues(alpha: 0.95),
        );
        break;
    }
  }

  void _drawExpressiveMouth(Canvas canvas, double w, PandaMood m) {
    if (m == PandaMood.celebrating) {
      final mouth = Path()
        ..moveTo(w * 0.43, w * 0.55)
        ..quadraticBezierTo(w * 0.50, w * 0.65, w * 0.57, w * 0.55)
        ..close();
      canvas.drawPath(mouth, Paint()..color = const Color(0xFFE11D48));
      return;
    }

    if (m == PandaMood.lookingUp || isComparing) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.50, w * 0.58), width: w * 0.08, height: w * 0.07),
        Paint()..color = _blackFur,
      );
      return;
    }

    final mouthPaint = Paint()
      ..color = _blackFur
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (w * 0.035).clamp(2.0, 3.5);
    final mouth = Path()
      ..moveTo(w * 0.43, w * 0.56)
      ..quadraticBezierTo(w * 0.465, w * 0.60, w * 0.50, w * 0.57)
      ..quadraticBezierTo(w * 0.535, w * 0.60, w * 0.57, w * 0.56);
    canvas.drawPath(mouth, mouthPaint);
  }

  void _drawBigBambooSprout(Canvas canvas, Offset base, double size) {
    final stemPaint = Paint()
      ..color = _bambooDark
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(base, Offset(base.dx, base.dy - size * 0.35), stemPaint);

    final sproutCenter = Offset(base.dx, base.dy - size * 0.30);

    _drawLargeLeaf(
      canvas,
      origin: sproutCenter,
      length: size * 0.85,
      width: size * 0.40,
      angle: -0.65,
      color: _bambooGreen,
    );

    _drawLargeLeaf(
      canvas,
      origin: sproutCenter,
      length: size * 0.75,
      width: size * 0.35,
      angle: 0.55,
      color: Color.lerp(_bambooGreen, const Color(0xFF4ADE80), 0.3)!,
    );

    final starPaint = Paint()..color = Colors.amberAccent;
    canvas.drawCircle(Offset(base.dx, base.dy - size * 0.65), 3.5, starPaint);
  }

  void _drawLargeLeaf(
    Canvas canvas, {
    required Offset origin,
    required double length,
    required double width,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(width * 0.8, -length * 0.45, 0, -length)
      ..quadraticBezierTo(-width * 0.8, -length * 0.45, 0, 0)
      ..close();

    canvas.drawPath(leafPath, Paint()..color = color);
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = _bambooDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.drawLine(
      Offset.zero,
      Offset(0, -length * 0.8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.2,
    );

    canvas.restore();
  }

  void _drawEyePatch(Canvas canvas, Offset center, double rw, double rh, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rw * 2, height: rh * 2),
      Paint()..color = _blackFur,
    );
    canvas.restore();
  }

  void _drawChubbyArm(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double length,
    required double angle,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: width, height: length),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PandaPainter old) =>
      old.value != value ||
      old.isLifted != isLifted ||
      old.isComparing != isComparing ||
      old.isSorted != isSorted ||
      old.mood != mood ||
      old.gazeDirection != gazeDirection ||
      old.accentColor != accentColor;
}
