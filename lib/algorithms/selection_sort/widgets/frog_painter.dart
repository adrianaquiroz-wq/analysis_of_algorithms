import 'dart:math';

import 'package:flutter/material.dart';

import 'frog_art.dart';
import 'frog_sim.dart';

/// Dibuja la pista: cielo, suelo con los puestos 1..n, zona ya ordenada,
/// el búho con su rayo de luz, y las ranas. Todo el movimiento viene de
/// [FrogSim]; este pintor solo lee su estado en cada cuadro.
class FrogPainter extends CustomPainter {
  final FrogSim sim;
  final bool isDark;

  FrogPainter({required this.sim, required this.isDark}) : super(repaint: sim);

  static const MaskFilter _soft = MaskFilter.blur(BlurStyle.normal, 8);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _mint = Color(0xFF69F0AE);
  static const Color _amber = Color(0xFFFFD740);

  @override
  void paint(Canvas canvas, Size size) {
    if (sim.frogs.isEmpty) return;
    _sky(canvas, size);
    _track(canvas, size);
    _beam(canvas);
    _shadows(canvas);
    _owl(canvas);
    _frogs(canvas);
    _effects(canvas);
  }

  // ---------------------------------------------------- Cielo y pista

  void _sky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B2A3C), Color(0xFF1B5E5A)]
              : const [Color(0xFFD9F2FF), Color(0xFFBFE8D5)],
        ).createShader(rect),
    );
  }

  void _track(Canvas canvas, Size size) {
    final l = sim.layout;
    final top = l.groundY - 2;
    final strip = Rect.fromLTRB(0, top, size.width, top + 32);

    // Pasto de la pista.
    canvas.drawRect(
      strip,
      Paint()..color = isDark ? const Color(0xFF1E5B3A) : const Color(0xFF7CB342),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, top + 4),
      Paint()..color = Colors.white.withValues(alpha: isDark ? 0.10 : 0.30),
    );

    // Zona ya ordenada (se va llenando de izquierda a derecha).
    if (sim.boundX > l.pad + 0.5) {
      canvas.drawRect(
        Rect.fromLTRB(l.pad, top, sim.boundX, top + 32),
        Paint()..color = _gold.withValues(alpha: 0.38),
      );
    }

    // Divisiones y números de puesto.
    final line = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.22);
    for (var s = 0; s <= l.n; s++) {
      final x = l.pad + s * l.slotW;
      canvas.drawLine(Offset(x, top + 4), Offset(x, top + 32), line);
    }
    for (var s = 0; s < l.n; s++) {
      final tp = sim.text('${s + 1}', 11, color: Colors.white.withValues(alpha: 0.9));
      tp.paint(
        canvas,
        Offset(l.xOf(s) - tp.width / 2, top + 18 - tp.height / 2),
      );
    }

    // Banderita en el borde de lo ordenado.
    final sc = sim.sortedCount;
    if (sc > 0 && sc < l.n) {
      final x = sim.boundX;
      final flagTop = l.groundY - l.frogW * 1.25;
      canvas.drawLine(
        Offset(x, flagTop),
        Offset(x, top + 32),
        Paint()
          ..strokeWidth = 1.6
          ..color = _gold.withValues(alpha: 0.9),
      );
      canvas.drawPath(
        Path()
          ..moveTo(x, flagTop)
          ..lineTo(x + 13, flagTop + 5)
          ..lineTo(x, flagTop + 10)
          ..close(),
        Paint()..color = _gold,
      );
    }

    // Edge/etiquetas bajo la pista (solo en modo grafo tienen texto).
    for (final f in sim.frogs) {
      if (f.label.isEmpty) continue;
      final tp = sim.text(
        f.label,
        10,
        color: isDark ? Colors.white70 : const Color(0xFF37474F),
      );
      tp.paint(canvas, Offset(f.pos.dx - tp.width / 2, top + 38));
    }
  }

  // ------------------------------------------------------- Búho y luz

  double get _owlBaseY => sim.layout.owlY + sin(sim.now * 3) * 3.5;

  Offset get _lens {
    final u = sim.layout.owlW;
    return Offset(
      sim.owlX + OwlArt.lens.dx * u,
      _owlBaseY + OwlArt.lens.dy * u,
    );
  }

  /// Rayo de luz de la lupa hasta la rana que se está comparando.
  void _beam(Canvas canvas) {
    final s = sim.scanSlot;
    if (s == null) return;
    final l = sim.layout;
    final lens = _lens;
    final fx = l.xOf(s);
    final fy = l.groundY - l.frogW * 1.05;
    final w = l.frogW * 0.45;

    final path = Path()
      ..moveTo(lens.dx - 3, lens.dy)
      ..lineTo(fx - w, fy)
      ..lineTo(fx + w, fy)
      ..lineTo(lens.dx + 3, lens.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _amber.withValues(alpha: 0.50),
            _amber.withValues(alpha: 0.10),
          ],
        ).createShader(Rect.fromPoints(lens, Offset(fx, fy))),
    );
  }

  void _owl(Canvas canvas) {
    final u = sim.layout.owlW;
    canvas.save();
    canvas.translate(sim.owlX, _owlBaseY);
    OwlArt.paint(canvas, u, flap: sim.owlFlap, look: sim.owlLook);
    canvas.restore();
  }

  // ----------------------------------------------- Sombras y ranas

  void _shadows(Canvas canvas) {
    final l = sim.layout;
    for (final f in sim.frogs) {
      final u = l.frogW * f.scale;
      final h = f.hopY;
      final k = (1 - h / (u * 3)).clamp(0.45, 1.0).toDouble();
      final a = (0.30 * (1 - h / (u * 2.4))).clamp(0.08, 0.30).toDouble();
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(f.pos.dx, l.groundY + 3),
          width: u * 0.95 * k,
          height: u * 0.20 * k,
        ),
        Paint()..color = Colors.black.withValues(alpha: a),
      );
    }
  }

  void _frogs(Canvas canvas) {
    final l = sim.layout;
    final frogs = [...sim.frogs]
      ..sort((a, b) => (a.airborne ? 1 : 0) - (b.airborne ? 1 : 0));

    for (final f in frogs) {
      final u = l.frogW * f.scale;
      final slot = sim.order.indexOf(f.id);
      final sorted = slot < sim.sortedCount;
      final isScan = slot == sim.scanSlot;
      final isMin = slot == sim.minSlot;

      // Respirar, estirarse al saltar y aplastarse al aterrizar.
      var sy = 1 + 0.015 * sin(sim.now * 2.2 + f.phase);
      var sx = 1.0;
      if (f.airborne) {
        final air = sin(pi * f.progress);
        sy += 0.12 * air;
        sx -= 0.07 * air;
      } else {
        final ps = (sim.now - f.settleT0) / 0.6;
        if (ps >= 0 && ps < 1) {
          final sq = 1 - Curves.elasticOut.transform(ps.clamp(0.0, 1.0).toDouble());
          sy -= 0.20 * sq;
          sx += 0.12 * sq;
        }
      }

      final x = f.pos.dx;
      final y = f.pos.dy - f.hopY;

      // Resplandor: verde = mínimo encontrado, ámbar = la que mira el búho.
      if (isMin || isScan) {
        canvas.drawCircle(
          Offset(x, y - u * 0.45),
          u * 0.78,
          Paint()
            ..color = (isMin ? _mint : _amber).withValues(alpha: 0.55)
            ..maskFilter = _soft,
        );
      }
      if (sorted) {
        canvas.drawCircle(
          Offset(x, y - u * 0.45),
          u * 0.70,
          Paint()
            ..color = _gold.withValues(alpha: 0.28)
            ..maskFilter = _soft,
        );
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(sx, sy);
      FrogArt.paint(
        canvas,
        u,
        look: sim.owlLook * 0.6,
        blink: f.blinkLeft > 0,
      );
      final numberSize = (u * 0.30).clamp(9.0, 15.0).toDouble();
      FrogArt.paintNumber(canvas, u, sim.text(_label(f), numberSize));
      canvas.restore();

      // Etiqueta "mín" sobre la candidata, y corona de las ya ordenadas.
      if (isMin && !sorted) {
        _tag(canvas, x, y - u * 1.0 - 14, sim.descending ? 'máx' : 'mín');
      }
      if (sorted) {
        canvas.save();
        canvas.translate(x, y - u * 1.12);
        canvas.drawPath(FrogArt.sparkle(u * 0.17), Paint()..color = _gold);
        canvas.restore();
      }
    }
  }

  /// Número que lleva la rana en la panza.
  String _label(Frog f) => sim.valueLabels[f.id];

  void _tag(Canvas canvas, double x, double y, String text) {
    final tp = sim.text(text, 10, color: const Color(0xFF0B3D2E));
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, y),
        width: tp.width + 12,
        height: tp.height + 4,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(r, Paint()..color = _mint);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  // ------------------------------------------------------ Efectos

  void _effects(Canvas canvas) {
    for (final p in sim.puffs) {
      final age = (sim.now - p.born) / p.life;
      if (age < 0 || age >= 1) continue;
      canvas.drawCircle(
        Offset(p.x + p.vx * age, p.y - 6 * age),
        p.r * (1 + age),
        Paint()..color = Colors.white.withValues(alpha: 0.55 * (1 - age)),
      );
    }

    for (final s in sim.sparkles) {
      final t = (sim.now - s.born) / s.life;
      if (t < 0 || t >= 1) continue;
      final r = s.r * (0.4 + 0.9 * sin(pi * t));
      canvas.save();
      canvas.translate(s.x, s.y - 14 * t);
      canvas.rotate(t * 2);
      canvas.drawPath(
        FrogArt.sparkle(r * 1.8),
        Paint()
          ..color = _gold.withValues(alpha: 0.45 * (1 - t))
          ..maskFilter = _soft,
      );
      canvas.drawPath(
        FrogArt.sparkle(r),
        Paint()
          ..color = const Color(0xFFFFF9C4).withValues(alpha: 1 - t * 0.6),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FrogPainter old) => old.isDark != isDark || old.sim != sim;
}
