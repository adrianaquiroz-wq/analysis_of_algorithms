import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_traversal_controller.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Lienzo del árbol: arrastra un nodo para moverlo, arrastra el fondo para
/// desplazar, pellizca / rueda para hacer zoom. El mono se para sobre el nodo actual.
class TreeStage extends StatefulWidget {
  final AppPalette palette;
  final TreeTraversalController controller;
  final VoidCallback onClear;

  /// true mientras el dedo está sobre el lienzo (para bloquear el scroll de la página).
  final ValueChanged<bool>? onInteract;

  const TreeStage({
    super.key,
    required this.palette,
    required this.controller,
    required this.onClear,
    this.onInteract,
  });

  static const double nodeR = 22;
  static const double monkeySize = 44;

  @override
  State<TreeStage> createState() => _TreeStageState();
}

class _TreeStageState extends State<TreeStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: 1,
  );

  double _scale = 1;
  Offset _pan = Offset.zero;
  Size _viewport = Size.zero;
  bool _pendingFit = true;
  int _seenVersion = -1;

  int? _lastMonkey;
  Offset? _monkeyFrom;

  int? _dragNode;
  Offset _dragOffset = Offset.zero;
  double _startScale = 1;
  Offset _startPan = Offset.zero;
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _onController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _anim.dispose();
    super.dispose();
  }

  Offset? _monkeyPos() {
    final id = _lastMonkey;
    if (id == null) return null;
    final target = widget.controller.positions[id];
    if (target == null) return null;
    final from = _monkeyFrom ?? target;
    return Offset.lerp(from, target, Curves.easeInOut.transform(_anim.value));
  }

  void _onController() {
    final c = widget.controller;
    if (c.treeVersion != _seenVersion) {
      _seenVersion = c.treeVersion;
      _pendingFit = true;
      _lastMonkey = null;
      _monkeyFrom = null;
    }
    final m = c.monkeyNode;
    if (m != _lastMonkey) {
      final to = m == null ? null : c.positions[m];
      if (to != null) {
        _monkeyFrom = _lastMonkey == null ? to : (_monkeyPos() ?? to);
        _anim.forward(from: 0);
      }
      _lastMonkey = m;
    }
  }

  // ------------------------------------------------------ Vista (zoom/pan)

  Offset _toWorld(Offset screen) => (screen - _pan) / _scale;

  void _fit(TreeTraversalController c) {
    final pts = c.positions.values;
    if (pts.isEmpty || _viewport.isEmpty) return;
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      minX = min(minX, p.dx);
      maxX = max(maxX, p.dx);
      minY = min(minY, p.dy);
      maxY = max(maxY, p.dy);
    }
    final r = Rect.fromLTRB(minX - 40, minY - 72, maxX + 40, maxY + 40);
    final s = min(_viewport.width / r.width, _viewport.height / r.height)
        .clamp(0.2, 1.3)
        .toDouble();
    _scale = s;
    _pan = Offset(
      _viewport.width / 2 - r.center.dx * s,
      _viewport.height / 2 - r.center.dy * s,
    );
  }

  void _zoomAt(Offset focal, double factor) {
    final ns = (_scale * factor).clamp(0.2, 3.0).toDouble();
    final w = (focal - _pan) / _scale;
    setState(() {
      _scale = ns;
      _pan = focal - w * ns;
    });
  }

  int? _hit(Offset world, TreeTraversalController c) {
    int? best;
    var bestD = TreeStage.nodeR + 8;
    for (final e in c.positions.entries) {
      final d = (e.value - world).distance;
      if (d <= bestD) {
        bestD = d;
        best = e.key;
      }
    }
    return best;
  }

  void _onScaleStart(ScaleStartDetails d, TreeTraversalController c) {
    _startFocal = d.localFocalPoint;
    _startScale = _scale;
    _startPan = _pan;
    _dragNode = null;
    if (d.pointerCount == 1) {
      final w = _toWorld(d.localFocalPoint);
      final hit = _hit(w, c);
      if (hit != null) {
        _dragNode = hit;
        _dragOffset = c.positions[hit]! - w;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d, TreeTraversalController c) {
    if (_dragNode != null) {
      c.moveNode(_dragNode!, _toWorld(d.localFocalPoint) + _dragOffset);
      return;
    }
    final ns = (_startScale * d.scale).clamp(0.2, 3.0).toDouble();
    final w0 = (_startFocal - _startPan) / _startScale;
    setState(() {
      _scale = ns;
      _pan = d.localFocalPoint - w0 * ns;
    });
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _anim]),
      builder: (context, _) {
        final c = widget.controller;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0xFF14261F) : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            children: [
              _header(p, c),
              Expanded(
                child: c.tree.root == null ? _empty(p) : _canvas(p, c),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(AppPalette p, TreeTraversalController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          Text(
            c.origin.isEmpty ? 'Árbol vacío' : c.origin,
            style: TextStyle(
              color: p.accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '${c.tree.size} nodos · ${c.tree.height} niveles',
            style: TextStyle(color: p.mutedText, fontSize: 13),
          ),
          TextButton.icon(
            onPressed: c.tree.root == null ? null : widget.onClear,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Limpiar árbol'),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppPalette p) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: TreeStage.monkeySize,
            height: TreeStage.monkeySize,
            child: CustomPaint(painter: MonkeyPainter()),
          ),
          const SizedBox(height: 8),
          Text(
            'El árbol está vacío.\nCréalo desde el panel de la derecha.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.subtleText),
          ),
        ],
      ),
    );
  }

  Widget _canvas(AppPalette p, TreeTraversalController c) {
    return LayoutBuilder(
      builder: (context, box) {
        _viewport = box.biggest;
        if (_pendingFit) {
          _fit(c);
          _pendingFit = false;
        }
        return Listener(
          onPointerDown: (_) => widget.onInteract?.call(true),
          onPointerUp: (_) => widget.onInteract?.call(false),
          onPointerCancel: (_) => widget.onInteract?.call(false),
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) {
              _zoomAt(e.localPosition, e.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (d) => _onScaleStart(d, c),
                  onScaleUpdate: (d) => _onScaleUpdate(d, c),
                  onScaleEnd: (_) => _dragNode = null,
                  child: CustomPaint(
                    painter: _TreePainter(
                      root: c.tree.root!,
                      positions: c.positions,
                      visited: c.output,
                      pathEdges: c.pathEdges,
                      current: c.monkeyNode,
                      monkeyPos: _monkeyPos(),
                      cheer: c.lastKind == StepKind.visit,
                      scale: _scale,
                      pan: _pan,
                      isDark: p.isDark,
                    ),
                  ),
                ),
              ),
              Positioned(right: 10, bottom: 10, child: _zoomBar(p, c)),
            ],
          ),
        );
      },
    );
  }

  Widget _zoomBar(AppPalette p, TreeTraversalController c) {
    Widget btn(IconData icon, String tip, VoidCallback onTap) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: p.text, size: 20),
      onPressed: onTap,
    );
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    return Container(
      decoration: BoxDecoration(
        color: p.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, 'Alejar', () => _zoomAt(center, 1 / 1.25)),
          btn(Icons.add_rounded, 'Acercar', () => _zoomAt(center, 1.25)),
          btn(Icons.auto_awesome_rounded, 'Ordenar nodos automáticamente',
              c.autoArrange),
          btn(Icons.center_focus_strong_rounded, 'Ajustar árbol a la vista',
              () => setState(() => _fit(c))),
        ],
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final TreeNode root;
  final Map<int, Offset> positions;
  final List<int> visited;
  final Set<String> pathEdges;
  final int? current;
  final Offset? monkeyPos;
  final bool cheer;
  final double scale;
  final Offset pan;
  final bool isDark;

  _TreePainter({
    required this.root,
    required this.positions,
    required this.visited,
    required this.pathEdges,
    required this.current,
    required this.monkeyPos,
    required this.cheer,
    required this.scale,
    required this.pan,
    required this.isDark,
  });

  static const Color banana = Color(0xFFFFB300);
  static const Color coconut = Color(0xFF8D6E63);
  static const Color leaf = Color(0xFF43A047);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    // Ramas.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void edges(TreeNode? n) {
      if (n == null) return;
      for (final ch in [n.left, n.right]) {
        if (ch == null) continue;
        final a = positions[n.value];
        final b = positions[ch.value];
        if (a != null && b != null) {
          final active = pathEdges.contains(edgeKey(n.value, ch.value));
          edge
            ..color = active
                ? banana
                : (isDark ? Colors.white24 : const Color(0xFF6D4C41))
            ..strokeWidth = active ? 4.5 : 2.5;
          canvas.drawLine(a, b, edge);
        }
        edges(ch);
      }
    }

    edges(root);

    // Nodos (cocos).
    for (final e in positions.entries) {
      final v = e.key;
      final pos = e.value;
      final order = visited.indexOf(v);
      final isVisited = order >= 0;
      final isCurrent = v == current;
      const r = TreeStage.nodeR;

      canvas.drawCircle(
        pos,
        r,
        Paint()..color = isCurrent ? leaf : (isVisited ? banana : coconut),
      );
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCurrent ? 3 : 1.5
          ..color = isCurrent ? Colors.white : Colors.black26,
      );
      _text(
        canvas,
        '$v',
        pos,
        TextStyle(
          color: isVisited && !isCurrent ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        2 * r - 8,
      );

      if (isVisited) {
        final badge = pos + const Offset(17, 17);
        canvas.drawCircle(badge, 9, Paint()..color = const Color(0xFF3E2723));
        _text(
          canvas,
          '${order + 1}',
          badge,
          const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          16,
        );
      }
    }

    // Mono encima del nodo actual.
    if (monkeyPos != null) {
      canvas.save();
      canvas.translate(
        monkeyPos!.dx - TreeStage.monkeySize / 2,
        monkeyPos!.dy - TreeStage.nodeR - TreeStage.monkeySize + 12,
      );
      MonkeyPainter(cheer: cheer).paint(
        canvas,
        const Size(TreeStage.monkeySize, TreeStage.monkeySize),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  /// Dibuja texto centrado y lo achica si no cabe en [maxWidth].
  void _text(Canvas canvas, String s, Offset center, TextStyle style,
      double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final k = tp.width > maxWidth ? maxWidth / tp.width : 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(k);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => true;
}

/// El mono. Si [cheer] es true abre la boca (acaba de visitar un nodo).
class MonkeyPainter extends CustomPainter {
  final bool cheer;
  const MonkeyPainter({this.cheer = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 44, size.height / 44);

    final fur = Paint()..color = const Color(0xFF8D5A2B);
    final skin = Paint()..color = const Color(0xFFF3D2A2);
    final black = Paint()..color = Colors.black87;

    for (final x in [6.0, 38.0]) {
      canvas.drawCircle(Offset(x, 22), 7, fur);
      canvas.drawCircle(Offset(x, 22), 4, skin);
    }
    canvas.drawCircle(const Offset(22, 20), 16, fur);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(22, 25), width: 24, height: 19),
      skin,
    );

    for (final x in [16.5, 27.5]) {
      canvas.drawCircle(Offset(x, 20), 2.3, black);
      canvas.drawCircle(Offset(x + 0.7, 19.3), 0.8, Paint()..color = Colors.white);
    }
    canvas.drawCircle(const Offset(20.5, 25), 0.9, black);
    canvas.drawCircle(const Offset(23.5, 25), 0.9, black);

    if (cheer) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(22, 28.5), width: 11, height: 9),
        0,
        pi,
        true,
        Paint()..color = const Color(0xFFC62828),
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(22, 27.5), width: 10, height: 6),
        0.25,
        pi - 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..color = Colors.black87,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MonkeyPainter old) => old.cheer != cheer;
}