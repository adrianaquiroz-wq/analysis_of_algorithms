import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'frog_art.dart';
import 'frog_layout.dart';

class Frog {
  final int id;
  final double scale;
  final double phase;
  final String label;

  Offset pos = Offset.zero;
  Offset from = Offset.zero;
  Offset to = Offset.zero;
  double t0 = -100;
  double dur = 0.7;
  double progress = 1;

  /// Altura del salto (px) y su valor actual.
  double arc = 0;
  double hopY = 0;

  double settleT0 = -100;

  double blinkTimer;
  double blinkLeft = 0;

  Frog({
    required this.id,
    required this.scale,
    required this.phase,
    required this.label,
    required this.blinkTimer,
  });

  bool get airborne => progress < 1;
}

/// Nubecita de polvo al aterrizar.
class Puff {
  final double x, y, vx, born, life, r;
  const Puff(this.x, this.y, this.vx, this.born, this.life, this.r);
}

/// Destello de celebración. Si [born] está en el futuro aún no se ve.
class Sparkle {
  final double x, y, born, life, r;
  const Sparkle(this.x, this.y, this.born, this.life, this.r);
}

/// Simulación del escenario: posiciones de las ranas (con saltos), el búho
/// que las vigila, el polvo y los destellos. No dibuja nada (eso lo hace
/// [FrogPainter]); solo avanza con [tick] y avisa a quien la escucha.
class FrogSim extends ChangeNotifier {
  final Random _rng = Random(11);

  late FrogLayout layout;
  bool _ready = false;
  List<num> _values = const [];

  final List<Frog> frogs = [];
  final List<Puff> puffs = [];
  final List<Sparkle> sparkles = [];

  // Lo que dice el controlador.
  List<int> order = const [];
  int sortedCount = 0;
  int? scanSlot;
  int? minSlot;
  int? selectedSlot;
  bool done = false;
  bool descending = false;
  List<String> valueLabels = const [];
  bool _wasDone = false;

  double now = 0;
  bool _started = false;

  // Búho.
  double owlX = 0;
  double owlFlap = 0;
  double owlLook = 0;
  double _owlTargetX = 0;

  /// Borde derecho (animado) de la zona ya ordenada.
  double boundX = 0;
  double _boundTarget = 0;

  final Map<String, TextPainter> _texts = {};

  /// Texto ya medido (se reutiliza entre cuadros).
  TextPainter text(String s, double size, {Color color = FrogArt.ink}) =>
      _texts.putIfAbsent(
        '$s|${size.toStringAsFixed(1)}|${color.toARGB32()}',
        () => FrogArt.text(s, size, color: color),
      );

  /// Posición horizontal del lugar [slot] según el escenario actual.
  double slotX(int slot) => layout.xOf(slot);

  /// Sincroniza el escenario con el estado del controlador. Es idempotente:
  /// solo se anima lo que cambió respecto a la llamada anterior.
  void update({
    required FrogLayout layout,
    required List<num> values,
    required List<String> labels,
    required List<String> valueLabels,
    required bool descending,
    required List<int> order,
    required int sortedCount,
    required int? scanSlot,
    required int? minSlot,
    required int? selectedSlot,
    required int? owlSlot,
    required int? jumperId,
    required bool done,
    required double moveSeconds,
  }) {
    final dataChanged = !_ready || !listEquals(_values, values);
    final sizeChanged = !_ready || layout.sizeKey != this.layout.sizeKey;
    final snap = dataChanged || sizeChanged;
    this.layout = layout;
    this.order = order;
    this.sortedCount = sortedCount;
    this.scanSlot = scanSlot;
    this.minSlot = minSlot;
    this.selectedSlot = selectedSlot;
    this.done = done;
    this.descending = descending;
    this.valueLabels = valueLabels;

    final n = values.length;
    final nums = values.map((v) => v.toDouble()).toList();
    final lo = nums.reduce(min);
    final hi = nums.reduce(max);

    if (dataChanged) {
      _values = List.of(values);
      frogs
        ..clear()
        ..addAll([
          for (var id = 0; id < n; id++)
            Frog(
              id: id,
              scale: 0.78 + 0.30 * (hi == lo ? 0.5 : (nums[id] - lo) / (hi - lo)),
              phase: _rng.nextDouble() * pi * 2,
              label: labels[id],
              blinkTimer: 1 + _rng.nextDouble() * 4,
            ),
        ]);
      puffs.clear();
      sparkles.clear();
      _wasDone = done;
    }

    final slotOf = List<int>.filled(n, 0);
    for (var s = 0; s < n; s++) {
      slotOf[order[s]] = s;
    }

    for (final f in frogs) {
      final target = Offset(layout.xOf(slotOf[f.id]), layout.groundY);
      if (snap) {
        f.pos = f.from = f.to = target;
        f.progress = 1;
        f.arc = f.hopY = 0;
        continue;
      }
      if ((target - f.to).distance > 0.5) {
        final slots = (target.dx - f.pos.dx).abs() / layout.slotW;
        final big = f.id == jumperId;
        f.from = f.pos;
        f.to = target;
        f.t0 = now;
        f.dur = moveSeconds * (big ? 1.0 : 0.85);
        f.progress = 0;
        f.arc = big
            ? min(FrogLayout.maxJump, 46 + 12 * slots)
            : min(44.0, 14 + 5 * slots);
      }
    }

    // El búho sigue a lo que está mirando; en reposo, se queda a la izquierda;
    // al terminar, vuela al centro.
    final slot = owlSlot ?? (done ? null : 0);
    _owlTargetX = slot == null ? layout.width / 2 : layout.xOf(slot);
    _boundTarget = layout.pad + sortedCount * layout.slotW;
    if (snap) {
      owlX = _owlTargetX;
      boundX = _boundTarget;
    }

    if (done && !_wasDone) {
      for (var s = 0; s < n; s++) {
        sparkles.add(
          Sparkle(layout.xOf(s), layout.groundY - layout.frogW * 1.25,
              now + s * 0.05, 0.9, layout.frogW * 0.22),
        );
      }
    }
    _wasDone = done;
    _ready = true;
  }

  /// Avanza la simulación al instante [t] (segundos) y avisa para repintar.
  void tick(double t) {
    if (!_ready) {
      now = t;
      return;
    }
    final dt = _started ? min(0.05, max(0.0, t - now)) : 0.0;
    _started = true;
    now = t;

    for (final f in frogs) {
      final wasAir = f.progress < 1;
      f.progress = f.dur <= 0
          ? 1
          : ((now - f.t0) / f.dur).clamp(0.0, 1.0).toDouble();
      final e = Curves.easeInOutCubic.transform(f.progress);
      f.pos = Offset.lerp(f.from, f.to, e)!;
      f.hopY = f.arc * sin(pi * f.progress);

      if (wasAir && !f.airborne) {
        f.settleT0 = now;
        _dust(f);
      }

      // Parpadeo.
      if (f.blinkLeft > 0) {
        f.blinkLeft -= dt;
      } else {
        f.blinkTimer -= dt;
        if (f.blinkTimer <= 0) {
          f.blinkTimer = 2.5 + _rng.nextDouble() * 4;
          f.blinkLeft = 0.12;
        }
      }
    }

    // Búho: se desliza hacia lo que mira y bate las alas más rápido al moverse.
    final dx = _owlTargetX - owlX;
    owlX += dx * (1 - exp(-dt * 10));
    owlFlap += dt * (5 + min(20.0, dx.abs() * 0.18));
    owlLook = (dx / 40).clamp(-1.0, 1.0).toDouble();
    boundX += (_boundTarget - boundX) * (1 - exp(-dt * 8));

    puffs.removeWhere((p) => now - p.born > p.life);
    sparkles.removeWhere((s) => now - s.born > s.life);

    notifyListeners();
  }

  /// Polvo a ambos lados de la rana al aterrizar de un salto de verdad.
  void _dust(Frog f) {
    if (f.arc < 8) return;
    final u = layout.frogW * f.scale;
    for (final s in [-1.0, 1.0]) {
      for (var i = 0; i < 2; i++) {
        puffs.add(
          Puff(
            f.pos.dx + s * u * 0.30,
            f.pos.dy - 2,
            s * (14 + _rng.nextDouble() * 22),
            now,
            0.5 + _rng.nextDouble() * 0.2,
            u * (0.07 + _rng.nextDouble() * 0.05),
          ),
        );
      }
    }
  }
}
