import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/logic/merge_sort_controller.dart'
    show ActiveSplit;

import 'duck_art.dart';
import 'pond_layout.dart';

class PondDuck {
  final int id;
  final int value;
  final double scale;
  final double phase;

  Offset pos = Offset.zero;
  Offset from = Offset.zero;
  Offset to = Offset.zero;
  double t0 = -100;
  double dur = 0.6;
  double progress = 1;

  /// Altura del saltito entre filas (px) y su valor actual.
  double arc = 0;
  double hopY = 0;

  /// Despegue del agua al comparar (px), suavizado.
  double lift = 0;
  bool highlighted = false;

  /// Hacia dónde mira: 1 derecha, -1 izquierda.
  double facing = 1;

  /// true si cruza de fila o recorre buen trecho (nada); false si solo se
  /// corre un poco porque cambió el espaciado entre grupos.
  bool swims = false;

  bool splashOnArrive = false;
  bool settleSquash = false;
  double settleT0 = -100;

  double rippleTimer = 0;
  double idleTimer;

  PondDuck({
    required this.id,
    required this.value,
    required this.scale,
    required this.phase,
    required this.idleTimer,
  });

  bool get moving => progress < 1;
}

/// Onda circular sobre el agua. Si [born] está en el futuro aún no se ve.
class Ripple {
  final double x, y, born, life, maxR, alpha;
  final bool strong;
  const Ripple(
    this.x,
    this.y,
    this.born,
    this.life,
    this.maxR,
    this.alpha, {
    this.strong = false,
  });
}

class Droplet {
  double x, y, vx, vy;
  final double born, life, r;
  Droplet(this.x, this.y, this.vx, this.vy, this.born, this.life, this.r);
}

class Glint {
  final double cx, cy, angle, u, born, life, spin;
  const Glint(
    this.cx,
    this.cy,
    this.angle,
    this.u,
    this.born,
    this.life,
    this.spin,
  );
}

/// Simulación del estanque: posiciones de los patitos, ondas, salpicaduras
/// y la corriente de cada división. No dibuja nada (eso lo hace
/// [PondPainter]); solo avanza con [tick] y avisa a quien la escucha.
///
/// Todos los movimientos de un mismo paso arrancan juntos y duran lo mismo,
/// con `easeInOutCubic`, así las corrientes y los patitos van acompasados.
class PondSim extends ChangeNotifier {
  final Random _rng = Random(7);

  late PondLayout layout;
  bool _ready = false;
  List<int> _values = const [];
  double _maxValue = 1;

  final List<PondDuck> ducks = [];
  final List<Ripple> ripples = [];
  final List<Droplet> droplets = [];
  final List<Glint> glints = [];

  List<ActiveSplit> splits = const [];
  ActiveSplit? newSplit;
  double streamT0 = -100;
  double streamDur = 0.6;

  double now = 0;
  bool _started = false;
  int _lastPlaceSerial = -1;
  int _lastSplitSerial = -1;

  // Posición horizontal de cada slot, animada entre dos distribuciones.
  List<double> _sxFrom = const [];
  List<double> _sxTo = const [];
  double _sxT0 = -100;
  double _sxDur = 0.6;

  /// Centro horizontal (animado) del slot [s].
  double slotX(int s) {
    final p = ((now - _sxT0) / _sxDur).clamp(0.0, 1.0).toDouble();
    final e = Curves.easeInOutCubic.transform(p);
    return lerpDouble(_sxFrom[s], _sxTo[s], e)!;
  }

  final Map<String, TextPainter> _numbers = {};

  /// Número del patito ya medido (se reutiliza entre cuadros).
  TextPainter numberPainter(int value, double u) => _numbers.putIfAbsent(
    '$value:${u.round()}',
    () => DuckArt.numberPainter(value, u),
  );

  /// Avance (0..1) de la corriente del último split.
  double get streamProgress => Curves.easeInOutCubic.transform(
    ((now - streamT0) / streamDur).clamp(0.0, 1.0).toDouble(),
  );

  static bool _same(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.01) return false;
    }
    return true;
  }

  /// Sincroniza el estanque con el estado del controlador. Es idempotente:
  /// solo se anima lo que cambió respecto a la llamada anterior.
  void update({
    required PondLayout layout,
    required List<int> values,
    required List<int> rows,
    required List<int> slots,
    required Set<int> comparing,
    required int? placedId,
    required int placeSerial,
    required List<ActiveSplit> splits,
    required ActiveSplit? newSplit,
    required int splitSerial,
    required double moveSeconds,
  }) {
    final dataChanged = !_ready || !listEquals(_values, values);
    final sizeChanged = !_ready || layout.sizeKey != this.layout.sizeKey;
    final snap = dataChanged || sizeChanged;
    this.layout = layout;
    this.splits = splits;
    this.newSplit = newSplit;

    final n = values.length;
    final newSx = [for (var s = 0; s < n; s++) layout.xOf(s)];
    if (snap) {
      _sxFrom = newSx;
      _sxTo = newSx;
      _sxT0 = -100;
    } else if (!_same(newSx, _sxTo)) {
      _sxFrom = [for (var s = 0; s < n; s++) slotX(s)];
      _sxTo = newSx;
      _sxT0 = now;
      _sxDur = moveSeconds;
    }

    if (dataChanged) {
      _values = List.of(values);
      _maxValue = values.reduce(max).toDouble();
      ducks
        ..clear()
        ..addAll([
          for (var id = 0; id < n; id++)
            PondDuck(
              id: id,
              value: values[id],
              scale: 0.8 + 0.25 * values[id] / _maxValue,
              phase: _rng.nextDouble() * pi * 2,
              idleTimer: 1 + _rng.nextDouble() * 3,
            ),
        ]);
      ripples.clear();
      droplets.clear();
      glints.clear();
      _lastPlaceSerial = placeSerial;
      _lastSplitSerial = splitSerial;
    }

    for (final d in ducks) {
      final target = Offset(newSx[slots[d.id]], layout.yOf(rows[d.id]));
      d.highlighted = comparing.contains(d.id);

      if (snap) {
        d.pos = d.from = d.to = target;
        d.progress = 1;
        d.arc = d.hopY = 0;
        continue;
      }
      if ((target - d.to).distance > 0.5) {
        final dx = target.dx - d.pos.dx;
        if (dx.abs() > 2) d.facing = dx > 0 ? 1 : -1;
        final rowChange = (target.dy - d.pos.dy).abs() > 1;
        d.from = d.pos;
        d.to = target;
        d.t0 = now;
        d.dur = moveSeconds * (rowChange ? 0.95 : 1.0);
        d.progress = 0;
        d.swims = rowChange || (d.to - d.from).distance > layout.duckW * 0.6;
        d.arc = !rowChange
            ? 0.0
            : (target.dy < d.from.dy
                  ? layout.duckW * 0.38
                  : layout.duckW * 0.16);
        if (placedId == d.id && placeSerial != _lastPlaceSerial) {
          d.splashOnArrive = true;
        }
      }
    }

    if (splitSerial != _lastSplitSerial) {
      _lastSplitSerial = splitSerial;
      streamT0 = now;
      streamDur = moveSeconds;
    }
    _lastPlaceSerial = placeSerial;
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

    for (final d in ducks) {
      final wasMoving = d.progress < 1;
      d.progress = d.dur <= 0
          ? 1
          : ((now - d.t0) / d.dur).clamp(0.0, 1.0).toDouble();
      final e = Curves.easeInOutCubic.transform(d.progress);
      d.pos = Offset.lerp(d.from, d.to, e)!;
      d.hopY = d.arc * sin(pi * d.progress);

      final liftTarget = d.highlighted ? layout.duckW * 0.30 : 0.0;
      d.lift += (liftTarget - d.lift) * min(1.0, dt * 14);

      final u = layout.duckW * d.scale;
      if (d.moving && d.swims) {
        d.rippleTimer += dt;
        while (d.rippleTimer >= 0.08) {
          d.rippleTimer -= 0.08;
          _ripple(d.pos.dx, d.pos.dy + 2, u * 0.85, 0.5, 0.85);
        }
      } else if (wasMoving && d.swims) {
        d.rippleTimer = 0;
        if (d.splashOnArrive) {
          d.splashOnArrive = false;
          d.settleSquash = true;
          d.settleT0 = now;
          _splash(d, u);
        } else {
          _ripple(d.pos.dx, d.pos.dy + 2, u * 0.6, 0.35, 0.8);
        }
      } else if (!d.moving) {
        // Reposo: de vez en cuando una ondita suave, como si respirara.
        d.idleTimer -= dt;
        if (d.idleTimer <= 0) {
          d.idleTimer = 2.8 + _rng.nextDouble() * 2.6;
          _ripple(d.pos.dx, d.pos.dy + 2, u * 0.6, 0.22, 1.5);
        }
      }
    }

    // Partículas.
    for (final p in droplets) {
      p.vy += 520 * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
    }
    ripples.removeWhere((r) => now - r.born > r.life);
    droplets.removeWhere((p) => now - p.born > p.life);
    glints.removeWhere((g) => now - g.born > g.life);

    notifyListeners();
  }

  void _ripple(double x, double y, double maxR, double alpha, double life) {
    if (ripples.length > 180) ripples.removeAt(0);
    ripples.add(Ripple(x, y, now, life, maxR, alpha));
  }

  /// Destello de agua al entrar un patito a la fila fusionada.
  void _splash(PondDuck d, double u) {
    final x = d.pos.dx;
    final y = d.pos.dy;

    ripples.add(Ripple(x, y + 2, now, 0.95, u * 1.3, 0.8, strong: true));
    ripples.add(
      Ripple(x, y + 2, now + 0.12, 0.95, u * 1.8, 0.55, strong: true),
    );

    final k = u / 40;
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + (_rng.nextDouble() - 0.5) * pi * 0.95;
      final s = (110 + _rng.nextDouble() * 120) * k;
      droplets.add(
        Droplet(
          x + (_rng.nextDouble() - 0.5) * u * 0.5,
          y - u * 0.1,
          cos(a) * s,
          sin(a) * s,
          now,
          0.55 + _rng.nextDouble() * 0.3,
          (1.8 + _rng.nextDouble() * 1.8) * max(0.8, k),
        ),
      );
    }

    final base = _rng.nextDouble() * pi * 2;
    for (var i = 0; i < 5; i++) {
      glints.add(
        Glint(
          x,
          y - u * 0.45,
          base + i * pi * 2 / 5,
          u,
          now,
          0.6,
          (_rng.nextDouble() - 0.5) * 3,
        ),
      );
    }
  }
}
