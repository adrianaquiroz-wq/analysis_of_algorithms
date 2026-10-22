import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/bamboo_background_painter.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/panda_painter.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Escenario de animación para Insertion Sort:
/// - Fondo ilustrado de bosque de bambú estilo dibujo caricatura.
/// - Ositos panda gorditos y tiernos sobre plataforma de bambú.
/// - El panda clave flota hacia arriba con su brote de bambú grande en la cabeza.
/// - Contacto visual interactivo: los pandas se miran mutuamente en la dirección exacta (arriba/abajo/diagonal).
/// - Enlace / conector visual de comparación entre el panda clave y el vecino.
/// - Tambaleo tierno (waddling) al desplazarse a la derecha.
/// - Rebote fluido y elástico con Squash & Stretch y mini-salto de amortiguación al aterrizar.
/// - Pandas durmiendo con "z Z" esperando su turno.
/// - Festejo festivo de victoria prolongado: ola continua de saltos múltiples con balanceo y confeti de bambú.
class InsertionStage extends StatefulWidget {
  final AppPalette palette;
  final List<int> values;
  final List<int> order;
  final List<int> slotOf;
  final int? liftedId;
  final int? comparingId;
  final int? shiftingId;
  final int? squashingId;
  final bool? lastComparisonShift;
  final int sortedUpTo;
  final int activePass;
  final bool isDone;
  final Duration duration;

  const InsertionStage({
    super.key,
    required this.palette,
    required this.values,
    required this.order,
    required this.slotOf,
    required this.liftedId,
    required this.comparingId,
    this.shiftingId,
    this.squashingId,
    this.lastComparisonShift,
    required this.sortedUpTo,
    required this.activePass,
    required this.isDone,
    required this.duration,
  });

  static const double _height = 410;
  static const double _topBand = 36;
  static const double _bottomBand = 34;
  static const double _ground = 12;
  static const double _highLift = 62;
  static const double _minSlot = 48;
  static const double _maxSlot = 82;

  // =========================================================================
  // PARÁMETROS DEL ATERRIZAJE Y REBOTE (Configurables manualmente):
  // =========================================================================
  /// 1. APLASTAMIENTO VERTICAL AL CAER (Squash de amortiguación)
  ///    0.82 = se comprime un 18% al tocar el suelo (amortigua con pancita/rodillas).
  ///    - Si quieres que se aplaste MÁS: bájalo a 0.76 o 0.78.
  ///    - Si quieres que sea MÁS RÍGIDO: súbelo a 0.88 o 0.92.
  ///    - Si no quieres deformación: ponlo en 1.0.
  static const double landingSquashY = 0.82;

  /// 2. ENSANCHAMIENTO HORIZONTAL AL CAER
  ///    1.14 = la barriguita se ensancha un +14% al amortiguar el peso.
  ///    - Para pancita más gordita al caer: súbelo a 1.18 o 1.20.
  ///    - Para menos ensanchamiento: bájalo a 1.08 o 1.05.
  ///    - Si no quieres deformación: ponlo en 1.0.
  static const double landingSquashX = 1.14;

  /// 3. MINI-SALTO DE REBOTE EN EL AIRE (en píxeles)
  ///    0.0 = patitas firmes en el suelo (100% natural, sin efecto pelota de goma).
  ///    - Si quieres un saltito muy sutil: prueba 2.0 o 3.0.
  ///    - Si quieres más rebote aéreo: 5.0 o 7.0.
  static const double landingHopY = 0.0;

  @override
  State<InsertionStage> createState() => _InsertionStageState();
}

class _InsertionStageState extends State<InsertionStage> with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _celebrationController;
  int? _activeBouncedId;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 1.15).clamp(340, 680).round(),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _activeBouncedId = null;
          });
        }
      });

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.isDone) {
      _celebrationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant InsertionStage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      _bounceController.duration = Duration(
        milliseconds: (widget.duration.inMilliseconds * 1.15).clamp(340, 680).round(),
      );
    }

    // Si un panda aterriza para ser insertado, iniciamos el rebote fluido
    if (widget.squashingId != null && widget.squashingId != oldWidget.squashingId) {
      _activeBouncedId = widget.squashingId;
      _bounceController.forward(from: 0.0);
    }

    // Si el panda que rebotaba vuelve a ser levantado, detenemos el rebote
    if (widget.liftedId != null && widget.liftedId == _activeBouncedId) {
      _activeBouncedId = null;
      _bounceController.stop();
    }

    // Festejo continuo y prolongado de victoria al completar
    if (widget.isDone && !oldWidget.isDone) {
      _celebrationController.repeat();
    } else if (!widget.isDone && oldWidget.isDone) {
      _celebrationController.stop();
      _celebrationController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// Retorna la física de aterrizaje natural y animada:
  /// - Descenso fluido acelerado por gravedad desde la altura flotante
  /// - Contacto con el suelo y amortiguación elástica de pancita/rodillas (Squash)
  /// - Recuperación elástica hacia la altura normal (Spring recovery)
  /// - Asentamiento suave y firme sobre las patas sin oscilaciones tipo gelatina
  ({double scaleX, double scaleY, double altitude}) _getLandingTransform(double t) {
    if (t <= 0.0 || t >= 1.0) {
      return (scaleX: 1.0, scaleY: 1.0, altitude: 0.0);
    }

    const dropRatio = 0.35; // 35% del tiempo en caída libre

    // 1. Fase de caída: aceleración gravitacional (easeIn) y leve estiramiento por inercia
    if (t < dropRatio) {
      final p = Curves.easeInQuad.transform(t / dropRatio);
      final altitude = InsertionStage._highLift * (1.0 - p);
      final sx = 1.0 - 0.04 * p;
      final sy = 1.0 + 0.05 * p;
      return (scaleX: sx, scaleY: sy, altitude: altitude);
    }

    // 2. Fase de impacto y amortiguación: patitas en el suelo, la pancita absorbe el peso
    const cushionRatio = 0.23;
    final cushionEnd = dropRatio + cushionRatio; // 0.58
    if (t < cushionEnd) {
      final p = Curves.easeOutQuad.transform((t - dropRatio) / cushionRatio);
      final sy = 1.05 - (1.05 - InsertionStage.landingSquashY) * sin(p * pi / 2);
      final sx = 0.96 + (InsertionStage.landingSquashX - 0.96) * sin(p * pi / 2);
      return (scaleX: sx, scaleY: sy, altitude: 0.0);
    }

    // 3. Fase de recuperación elástica: el cuerpo se endereza con energía natural
    const recoverRatio = 0.24;
    final recoverEnd = cushionEnd + recoverRatio; // 0.82
    if (t < recoverEnd) {
      final p = Curves.easeInOutQuad.transform((t - cushionEnd) / recoverRatio);
      final sy = InsertionStage.landingSquashY + (1.03 - InsertionStage.landingSquashY) * p;
      final sx = InsertionStage.landingSquashX + (0.98 - InsertionStage.landingSquashX) * p;
      final hop = InsertionStage.landingHopY * sin(p * pi);
      return (scaleX: sx, scaleY: sy, altitude: hop);
    }

    // 4. Asentamiento suave a la postura neutral
    final p = Curves.easeOutQuad.transform((t - recoverEnd) / (1.0 - recoverEnd));
    final sy = 1.03 + (1.0 - 1.03) * p;
    final sx = 0.98 + (1.0 - 0.98) * p;
    return (scaleX: sx, scaleY: sy, altitude: 0.0);
  }

  /// Transforma a los pandas durante el festejo de victoria:
  /// Saltos rítmicos múltiples, altos (28px), con balanceo juguetón y ola continua.
  ({double hopY, double turns, double scaleX, double scaleY}) _celebrationTransformFor(int id) {
    if (!widget.isDone) {
      return (hopY: 0.0, turns: 0.0, scaleX: 1.0, scaleY: 1.0);
    }

    final slot = widget.slotOf[id];
    // En cada ciclo completo de 2200ms cada panda da 3 saltos sucesivos, desfasados en ola
    final cycleTime = (_celebrationController.value * 2 * pi * 3.0) - (slot * 0.65);
    final s = sin(cycleTime);

    if (s > 0.0) {
      // Salto festivo en el aire
      final p = pow(s, 0.72).toDouble();
      final hopY = p * 28.0;
      final turns = (slot % 2 == 0 ? 0.042 : -0.042) * p;
      final scaleY = 1.0 + 0.16 * p;
      final scaleX = 1.0 - 0.10 * p;
      return (hopY: hopY, turns: turns, scaleX: scaleX, scaleY: scaleY);
    } else {
      // Amortiguación de caída en el suelo antes del próximo impulso
      final squash = (-s).clamp(0.0, 1.0);
      final p = pow(squash, 0.85).toDouble();
      final scaleX = 1.0 + 0.18 * p;
      final scaleY = 1.0 - 0.14 * p;
      return (hopY: 0.0, turns: 0.0, scaleX: scaleX, scaleY: scaleY);
    }
  }

  PandaMood _moodOf(int id) {
    if (widget.isDone) return PandaMood.celebrating;
    if (id == widget.liftedId) return PandaMood.curious;
    if (id == widget.comparingId) return PandaMood.lookingUp;
    // Si la pasada aún no llega a este panda (está a la derecha) y hay ordenamiento en curso:
    if (widget.slotOf[id] > widget.activePass &&
        (widget.liftedId != null || widget.comparingId != null || widget.shiftingId != null)) {
      return PandaMood.sleeping;
    }
    return PandaMood.normal;
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.values.length;
    final maxValue = widget.values.reduce(max);

    // Los pandas activos se dibujan encima de los demás;
    // el que está flotando (liftedId) o rebotando va al frente de todos.
    int layerWeight(int id) {
      if (id == widget.liftedId || id == _activeBouncedId) return 4;
      if (id == widget.comparingId) return 3;
      if (id == widget.shiftingId) return 2;
      return 1;
    }

    final renderOrder = List<int>.generate(n, (i) => i)
      ..sort((a, b) => layerWeight(a).compareTo(layerWeight(b)));

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.palette.isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotW = (constraints.maxWidth / n).clamp(InsertionStage._minSlot, InsertionStage._maxSlot).toDouble();
          final contentW = slotW * n;
          final width = max(constraints.maxWidth, contentW);
          final offset = (width - contentW) / 2;

          final w = slotW * 0.88;
          final minH = w * 1.35;
          final maxH = InsertionStage._height -
              InsertionStage._topBand -
              InsertionStage._bottomBand -
              InsertionStage._ground -
              InsertionStage._highLift -
              14;
          const baseline = InsertionStage._bottomBand + InsertionStage._ground;

          double centerOf(int slot) => offset + slot * slotW + slotW / 2;

          // Calcula la posición real (X, Y) de los ojos de un panda en el canvas
          Offset eyePositionOf(int id) {
            final s = widget.slotOf[id];
            final cx = centerOf(s);
            final h = minH + (maxH - minH) * (widget.values[id] / maxValue);
            final b = baseline +
                (id == widget.liftedId
                    ? InsertionStage._highLift
                    : (id == widget.comparingId ? 10.0 : 0.0));
            final pandaTopY = InsertionStage._height - (b + h);
            final eyeY = pandaTopY + w * 0.40;
            return Offset(cx, eyeY);
          }

          // Calcula el vector hacia dónde debe mirar cada panda para mirarse mutuamente a los ojos
          Offset? gazeFor(int id) {
            if (widget.comparingId != null && widget.liftedId != null) {
              if (id == widget.comparingId) {
                final pA = eyePositionOf(widget.comparingId!);
                final pB = eyePositionOf(widget.liftedId!);
                final dx = pB.dx - pA.dx;
                final dy = pB.dy - pA.dy;
                final dist = sqrt(dx * dx + dy * dy);
                return dist > 0 ? Offset(dx / dist, dy / dist) : const Offset(1, 0);
              }
              if (id == widget.liftedId) {
                final pA = eyePositionOf(widget.comparingId!);
                final pB = eyePositionOf(widget.liftedId!);
                final dx = pA.dx - pB.dx;
                final dy = pA.dy - pB.dy;
                final dist = sqrt(dx * dx + dy * dy);
                return dist > 0 ? Offset(dx / dist, dy / dist) : const Offset(-1, 0);
              }
            }
            return null;
          }

          return AnimatedBuilder(
            animation: Listenable.merge([_bounceController, _celebrationController]),
            builder: (context, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  height: InsertionStage._height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // =========================================================
                      // 1. FONDO ILUSTRADO DE BOSQUE DE BAMBÚ (DIBUJO)
                      // =========================================================
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BambooBackgroundPainter(isDark: widget.palette.isDark),
                        ),
                      ),

                      // =========================================================
                      // 2. ZONA RESALTADA: PANDAS ORDENADOS (Franja verde tenue)
                      // =========================================================
                      if (widget.sortedUpTo >= 0 && widget.sortedUpTo < n) ...[
                        Positioned(
                          left: offset - 4,
                          width: (widget.sortedUpTo + 1) * slotW + 8,
                          bottom: InsertionStage._bottomBand - 2,
                          top: InsertionStage._topBand - 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: offset + 6,
                          top: InsertionStage._topBand - 26,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Ordenados',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // =========================================================
                      // 3. SUELO DE MADERA / BAMBÚ
                      // =========================================================
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: InsertionStage._bottomBand,
                        height: InsertionStage._ground,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.palette.isDark
                                  ? const [Color(0xFF0F382E), Color(0xFF165B4A)]
                                  : const [Color(0xFF6EE7B7), Color(0xFF34D399)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // =========================================================
                      // 4. BROTES DE BAMBÚ A LOS PIES DE LOS PANDAS ORDENADOS
                      // =========================================================
                      for (var s = 0; s <= widget.sortedUpTo && s < n; s++)
                        Positioned(
                          left: offset + s * slotW + (slotW - 14) / 2,
                          bottom: InsertionStage._bottomBand + InsertionStage._ground - 2,
                          width: 14,
                          height: 14,
                          child: const CustomPaint(
                            painter: _GroundSproutPainter(),
                          ),
                        ),

                      // =========================================================
                      // 5. ETIQUETAS DE POSICIÓN / RANURA [0], [1]...
                      // =========================================================
                      for (var s = 0; s < n; s++)
                        Positioned(
                          left: offset + s * slotW,
                          bottom: 6,
                          width: slotW,
                          child: Center(
                            child: Text(
                              '[$s]',
                              style: TextStyle(
                                color: s <= widget.sortedUpTo
                                    ? const Color(0xFF22C55E)
                                    : widget.palette.mutedText,
                                fontSize: 11.5,
                                fontWeight: s <= widget.sortedUpTo ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // =========================================================
                      // 6. HUECO VACÍO EN LA PLATAFORMA (Espacio libre para aterrizar)
                      // =========================================================
                      if (widget.liftedId != null)
                        Positioned(
                          left: offset + widget.slotOf[widget.liftedId!] * slotW + (slotW - w) / 2,
                          bottom: baseline,
                          width: w,
                          height: 30,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amberAccent.withValues(alpha: 0.65),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    'Hueco',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // =========================================================
                      // 7. LOS OSITOS PANDA GORDITOS ANIMADOS (Física fluida)
                      // =========================================================
                      for (final id in renderOrder)
                        _buildPandaItem(
                          id: id,
                          offset: offset,
                          slotW: slotW,
                          w: w,
                          minH: minH,
                          maxH: maxH,
                          maxValue: maxValue,
                          baseline: baseline,
                          gaze: gazeFor(id),
                        ),

                      // =========================================================
                      // 8. ENLACE / CONECTOR VISUAL DE COMPARACIÓN
                      // =========================================================
                      if (widget.liftedId != null && widget.comparingId != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _CompareConnectorPainter(
                                xGround: centerOf(widget.slotOf[widget.comparingId!]),
                                xLifted: centerOf(widget.slotOf[widget.liftedId!]),
                                yGround: eyePositionOf(widget.comparingId!).dy,
                                yLifted: eyePositionOf(widget.liftedId!).dy,
                                shouldShift: widget.lastComparisonShift ?? false,
                              ),
                            ),
                          ),
                        ),

                      // =========================================================
                      // 9. CONFETI FESTIVO FLOTANTE AL TERMINAR EL ORDENAMIENTO
                      // =========================================================
                      if (widget.isDone)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _CelebrationConfettiPainter(
                                animationValue: _celebrationController.value,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPandaItem({
    required int id,
    required double offset,
    required double slotW,
    required double w,
    required double minH,
    required double maxH,
    required int maxValue,
    required double baseline,
    required Offset? gaze,
  }) {
    final isLanding = id == _activeBouncedId;
    final landing = isLanding
        ? _getLandingTransform(_bounceController.value)
        : (scaleX: 1.0, scaleY: 1.0, altitude: 0.0);

    final celebration = widget.isDone
        ? _celebrationTransformFor(id)
        : (hopY: 0.0, turns: 0.0, scaleX: 1.0, scaleY: 1.0);

    final effectiveScaleX = widget.isDone ? celebration.scaleX : landing.scaleX;
    final effectiveScaleY = widget.isDone ? celebration.scaleY : landing.scaleY;

    final effectiveTurns = widget.isDone
        ? celebration.turns
        : (id == widget.shiftingId
            ? 0.032
            : (id == widget.liftedId ? -0.016 : 0.0));

    // Elevación vertical física sobre el suelo
    final double elevation;
    if (widget.isDone) {
      elevation = celebration.hopY;
    } else if (isLanding) {
      elevation = landing.altitude;
    } else if (id == widget.liftedId) {
      elevation = InsertionStage._highLift;
    } else if (id == widget.comparingId) {
      elevation = 10.0;
    } else {
      elevation = 0.0;
    }

    return AnimatedPositioned(
      key: ValueKey(id),
      duration: (isLanding || widget.isDone) ? Duration.zero : widget.duration,
      curve: Curves.easeInOutCubic,
      left: offset + widget.slotOf[id] * slotW + (slotW - w) / 2,
      bottom: baseline + elevation,
      width: w,
      height: minH + (maxH - minH) * (widget.values[id] / maxValue),
      child: AnimatedRotation(
        turns: effectiveTurns,
        duration: (isLanding || widget.isDone) ? Duration.zero : widget.duration,
        curve: Curves.easeInOutCubic,
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(
            effectiveScaleX,
            effectiveScaleY,
            1.0,
          ),
          child: CustomPaint(
            painter: PandaPainter(
              value: widget.values[id],
              isLifted: id == widget.liftedId,
              isComparing: id == widget.comparingId,
              isSorted: widget.slotOf[id] <= widget.sortedUpTo && id != widget.liftedId,
              mood: _moodOf(id),
              gazeDirection: gaze,
              accentColor: widget.palette.accent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja un arco conector y una pastilla comparadora entre el panda flotante y el panda de abajo.
class _CompareConnectorPainter extends CustomPainter {
  final double xGround;
  final double xLifted;
  final double yGround;
  final double yLifted;
  final bool shouldShift;

  const _CompareConnectorPainter({
    required this.xGround,
    required this.xLifted,
    required this.yGround,
    required this.yLifted,
    required this.shouldShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(xGround, yGround);
    final end = Offset(xLifted, yLifted);
    final mid = Offset((xGround + xLifted) / 2, min(yGround, yLifted) - 18);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

    final lineColor = shouldShift ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    final badgeCenter = mid;
    final badgePaint = Paint()..color = lineColor;
    canvas.drawCircle(badgeCenter, 13, badgePaint);
    canvas.drawCircle(badgeCenter, 13, Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8);

    final iconText = shouldShift ? '>' : '✓';
    final tp = TextPainter(
      text: TextSpan(
        text: iconText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(badgeCenter.dx - tp.width / 2, badgeCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompareConnectorPainter old) =>
      old.xGround != xGround ||
      old.xLifted != xLifted ||
      old.yGround != yGround ||
      old.yLifted != yLifted ||
      old.shouldShift != shouldShift;
}

/// Dibuja un tierno brotecito de bambú verde que asoma en el suelo para cada panda ordenado.
class _GroundSproutPainter extends CustomPainter {
  const _GroundSproutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stemPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h), Offset(w * 0.5, h * 0.35), stemPaint);

    final leafPaint = Paint()..color = const Color(0xFF22C55E);

    final leftLeaf = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..quadraticBezierTo(w * 0.1, h * 0.25, 0, 0)
      ..quadraticBezierTo(w * 0.25, h * 0.35, w * 0.5, h * 0.45)
      ..close();
    canvas.drawPath(leftLeaf, leafPaint);

    final rightLeaf = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..quadraticBezierTo(w * 0.9, h * 0.25, w, 0)
      ..quadraticBezierTo(w * 0.75, h * 0.35, w * 0.5, h * 0.45)
      ..close();
    canvas.drawPath(rightLeaf, leafPaint);
  }

  @override
  bool shouldRepaint(_GroundSproutPainter old) => false;
}

/// Dibuja partículas festivas flotantes (hojitas de bambú y estrellas doradas)
/// que caen y se mecen suavemente sobre el escenario al terminar el ordenamiento.
class _CelebrationConfettiPainter extends CustomPainter {
  final double animationValue;

  const _CelebrationConfettiPainter({required this.animationValue});

  static final List<({double xSeed, double ySeed, double speed, Color color, int type})> _particles = [
    (xSeed: 0.05, ySeed: 0.1, speed: 0.9, color: const Color(0xFF22C55E), type: 0),
    (xSeed: 0.12, ySeed: 0.6, speed: 1.1, color: const Color(0xFFFBBF24), type: 1),
    (xSeed: 0.18, ySeed: 0.3, speed: 0.8, color: const Color(0xFFF472B6), type: 0),
    (xSeed: 0.24, ySeed: 0.8, speed: 1.2, color: const Color(0xFF38BDF8), type: 2),
    (xSeed: 0.31, ySeed: 0.2, speed: 1.0, color: const Color(0xFF4ADE80), type: 0),
    (xSeed: 0.38, ySeed: 0.7, speed: 0.85, color: const Color(0xFFFBBF24), type: 1),
    (xSeed: 0.44, ySeed: 0.4, speed: 1.15, color: const Color(0xFFF472B6), type: 2),
    (xSeed: 0.52, ySeed: 0.9, speed: 0.95, color: const Color(0xFF22C55E), type: 0),
    (xSeed: 0.59, ySeed: 0.15, speed: 1.05, color: const Color(0xFF38BDF8), type: 1),
    (xSeed: 0.66, ySeed: 0.55, speed: 0.9, color: const Color(0xFFFBBF24), type: 0),
    (xSeed: 0.73, ySeed: 0.25, speed: 1.2, color: const Color(0xFF4ADE80), type: 2),
    (xSeed: 0.81, ySeed: 0.75, speed: 0.8, color: const Color(0xFFF472B6), type: 1),
    (xSeed: 0.88, ySeed: 0.35, speed: 1.1, color: const Color(0xFF22C55E), type: 0),
    (xSeed: 0.94, ySeed: 0.85, speed: 1.0, color: const Color(0xFFFBBF24), type: 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final yProgress = (animationValue * p.speed + p.ySeed) % 1.0;
      final y = yProgress * (size.height - 40);
      final sway = sin(animationValue * 2 * pi * 2 + p.xSeed * 10) * 12.0;
      final x = p.xSeed * size.width + sway;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(sin(animationValue * 2 * pi + p.ySeed * 5) * 0.4);

      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      if (p.type == 0) {
        // Hojita de bambú flotante
        final leaf = Path()
          ..moveTo(0, -6)
          ..quadraticBezierTo(4, -1, 0, 6)
          ..quadraticBezierTo(-4, -1, 0, -6)
          ..close();
        canvas.drawPath(leaf, paint);
      } else if (p.type == 1) {
        // Estrellita brillante de victoria
        final star = Path()
          ..moveTo(0, -5)
          ..lineTo(1.5, -1.5)
          ..lineTo(5, 0)
          ..lineTo(1.5, 1.5)
          ..lineTo(0, 5)
          ..lineTo(-1.5, 1.5)
          ..lineTo(-5, 0)
          ..lineTo(-1.5, -1.5)
          ..close();
        canvas.drawPath(star, paint);
      } else {
        // Confeti pastel
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -2, 6, 4), const Radius.circular(1.5)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CelebrationConfettiPainter old) => old.animationValue != animationValue;
}



