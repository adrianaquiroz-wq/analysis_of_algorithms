import 'dart:math';

import 'package:flutter/material.dart';

import 'duck_art.dart';
import 'pond_sim.dart';

/// Dibuja el estanque: agua, corrientes luminosas, ondas, sombras, patitos
/// y salpicaduras. Todo el movimiento viene de [PondSim]; este pintor solo
/// lee su estado en cada cuadro.
class PondPainter extends CustomPainter {
  final PondSim sim;
  final bool isDark;

  PondPainter({required this.sim, required this.isDark}) : super(repaint: sim);

  static const MaskFilter _glowBlur = MaskFilter.blur(BlurStyle.normal, 6);
  static const MaskFilter _softBlur = MaskFilter.blur(BlurStyle.normal, 9);

  Color get _glow =>
      isDark ? const Color(0xFF7FFFD4) : const Color(0xFF00ACC1);

  @override
  void paint(Canvas canvas, Size size) {
    if (sim.ducks.isEmpty) return;
    _water(canvas, size);
    _waves(canvas, size);
    _streams(canvas);
    _ripples(canvas);
    _shadows(canvas);
    _ducks(canvas);
    _splashes(canvas);
  }

  // ------------------------------------------------------------- Agua

  void _water(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0A2F48), Color(0xFF0F5C78)]
              : const [Color(0xFFCDEFF9), Color(0xFF8ED1E6)],
        ).createShader(rect),
    );
  }

  /// Una línea de agua suave bajo cada nivel.
  void _waves(Canvas canvas, Size size) {
    final l = sim.layout;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: isDark ? 0.10 : 0.45);
    for (var row = 0; row < l.levels; row++) {
      final y = l.yOf(row) + 9;
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 8) {
        path.lineTo(x, y + sin(x * 0.045 + sim.now * 1.2 + row) * 1.6);
      }
      canvas.drawPath(path, paint);
    }
  }

  // ------------------------------------------------ Corrientes (glow)

  Path _curve(Offset a, Offset b) {
    final dy = (b.dy - a.dy) * 0.55;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx, a.dy + dy, b.dx, b.dy - dy, b.dx, b.dy);
  }

  Path _partial(Path p, double t) {
    final out = Path();
    for (final m in p.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return out;
  }

  /// Pinta la ruta dos veces: trazo grueso borroso + hilo fino brillante.
  void _glowPath(Canvas canvas, Path path, double k, double strength) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8 * k
        ..color = _glow.withValues(alpha: 0.42 * strength)
        ..maskFilter = _glowBlur,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2 * k
        ..color = Colors.white.withValues(alpha: 0.92 * strength),
    );
  }

  void _streams(Canvas canvas) {
    final l = sim.layout;
    final k = (l.duckW / 40).clamp(0.8, 1.3).toDouble();

    for (final s in sim.splits) {
      final top = Offset(
        (sim.slotX(s.lo) + sim.slotX(s.hi - 1)) / 2,
        l.yOf(s.depth) + 3,
      );
      final childY = l.yOf(s.depth + 1) - l.duckH * 0.95 - 4;
      final left = Offset(
        (sim.slotX(s.lo) + sim.slotX(s.mid - 1)) / 2,
        childY,
      );
      final right = Offset(
        (sim.slotX(s.mid) + sim.slotX(s.hi - 1)) / 2,
        childY,
      );

      final isNew = sim.newSplit == s;
      final t = isNew ? sim.streamProgress : 1.0;
      final strength = isNew ? 1.0 : 0.7;

      for (final to in [left, right]) {
        final path = _curve(top, to);
        _glowPath(canvas, t < 1 ? _partial(path, t) : path, k, strength);
      }

      // Nacimiento de la corriente: un punto luminoso en la bifurcación.
      canvas.drawCircle(
        top,
        8 * k,
        Paint()
          ..color = _glow.withValues(alpha: 0.5 * strength)
          ..maskFilter = _glowBlur,
      );
      canvas.drawCircle(
        top,
        3 * k,
        Paint()..color = Colors.white.withValues(alpha: 0.95 * strength),
      );
    }
  }

  // ------------------------------------------------------------ Ondas

  void _ripples(Canvas canvas) {
    for (final r in sim.ripples) {
      final age = (sim.now - r.born) / r.life;
      if (age < 0 || age >= 1) continue;
      final ease = 1 - pow(1 - age, 2);
      final radius = r.maxR * (0.2 + 0.8 * ease);
      final alpha = r.alpha * pow(1 - age, 1.6);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r.strong ? 2.2 : 1.3
        ..color = (r.strong ? _glow : Colors.white).withValues(
          alpha: alpha.clamp(0.0, 1.0).toDouble(),
        );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(r.x, r.y),
          width: radius * 2,
          height: radius * 0.68,
        ),
        paint,
      );
    }
  }

  // ---------------------------------------------- Sombras y patitos

  List<PondDuck> _sorted() {
    double key(PondDuck d) =>
        d.pos.dy + ((d.moving || d.highlighted) ? 1e6 : 0);
    return [...sim.ducks]..sort((a, b) => key(a).compareTo(key(b)));
  }

  /// Sombra elíptica un poco más abajo del patito. Si el patito se despega
  /// del agua (compara o salta de nivel), la sombra se achica y se aclara.
  void _shadows(Canvas canvas) {
    final l = sim.layout;
    for (final d in sim.ducks) {
      final u = l.duckW * d.scale;
      final h = d.lift + d.hopY;
      final scale = (1 - h / (u * 1.6)).clamp(0.5, 1.0).toDouble();
      final alpha = (0.30 * (1 - h / (u * 1.1))).clamp(0.08, 0.30).toDouble();
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(d.pos.dx, d.pos.dy + 6),
          width: u * 0.95 * scale,
          height: u * 0.24 * scale,
        ),
        Paint()..color = Colors.black.withValues(alpha: alpha),
      );
    }
  }

  void _ducks(Canvas canvas) {
    final l = sim.layout;
    for (final d in _sorted()) {
      final u = l.duckW * d.scale;
      final moveF = (d.moving && d.swims) ? sin(pi * d.progress) : 0.0;

      // Flotando: sube y baja un poquito; nadando: se bambolea de lado a lado.
      final bob = sin(sim.now * 2.1 + d.phase) * 1.3 * (1 - moveF * 0.7);
      var rot =
          sin(sim.now * 11 + d.phase) * 0.12 * moveF +
          sin(sim.now * 1.4 + d.phase) * 0.025;
      var sx = 1.0;
      var sy = 1.0;

      // Al llegar a su lugar: aplastón y rebote elástico.
      if (d.settleSquash) {
        final ps = (sim.now - d.settleT0) / 0.75;
        if (ps >= 1) {
          d.settleSquash = false;
        } else {
          final sq = 1 - Curves.elasticOut.transform(ps.clamp(0.0, 1.0).toDouble());
          sy = 1 - 0.20 * sq;
          sx = 1 + 0.14 * sq;
          rot += 0.18 * sin(ps * 16) * (1 - ps);
        }
      }

      final x = d.pos.dx;
      final y = d.pos.dy - d.lift - d.hopY + bob;

      if (d.highlighted) {
        canvas.drawCircle(
          Offset(x, y - u * 0.40),
          u * 0.78,
          Paint()
            ..color = Colors.amberAccent.withValues(alpha: 0.5)
            ..maskFilter = _softBlur,
        );
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.scale(sx, sy);
      canvas.save();
      canvas.scale(d.facing, 1);
      DuckArt.paint(canvas, u);
      canvas.restore();
      DuckArt.paintNumber(canvas, u, sim.numberPainter(d.value, u));
      canvas.restore();
    }
  }

  // ------------------------------------------------ Destello mágico

  void _splashes(Canvas canvas) {
    for (final p in sim.droplets) {
      final age = (sim.now - p.born) / p.life;
      if (age < 0 || age >= 1) continue;
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.r * (1 - 0.4 * age),
        Paint()
          ..color = Color.lerp(
            Colors.white,
            _glow,
            0.35,
          )!.withValues(alpha: (1 - age).clamp(0.0, 1.0).toDouble()),
      );
    }

    for (final g in sim.glints) {
      final t = (sim.now - g.born) / g.life;
      if (t < 0 || t >= 1) continue;
      final ease = 1 - pow(1 - t, 2);
      final dist = g.u * (0.45 + 0.6 * ease);
      final r = g.u * 0.17 * (1 - t * 0.7);
      final alpha = (1 - t).clamp(0.0, 1.0).toDouble();
      canvas.save();
      canvas.translate(
        g.cx + cos(g.angle) * dist,
        g.cy + sin(g.angle) * dist * 0.9,
      );
      canvas.rotate(g.spin * t);
      canvas.drawPath(
        DuckArt.sparkle(r * 1.8),
        Paint()
          ..color = _glow.withValues(alpha: 0.5 * alpha)
          ..maskFilter = _glowBlur,
      );
      canvas.drawPath(
        DuckArt.sparkle(r),
        Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PondPainter old) => old.isDark != isDark || old.sim != sim;
}
