import '../../../models/node_model.dart';
import '../../../models/edge_model.dart';
import '../models/cpm_step.dart';

class CpmResult {
  final bool hasCycle;

  /// Tiempos más tempranos (ES) por nodo.
  final Map<String, double> earliestTimes;

  /// Tiempos más tardíos (LS) por nodo.
  final Map<String, double> latestTimes;

  /// Holgura por arista (id de arista -> holgura).
  final Map<String, double> slacks;

  /// Aristas que forman la ruta crítica, en orden.
  final List<String> criticalEdgeIds;

  /// Nodos que forman la ruta crítica, en orden.
  final List<String> criticalNodeIds;

  /// Duración total del proyecto.
  final double projectDuration;

  /// Historial completo de pasos, listo para reproducir/animar.
  final List<CpmStep> steps;

  /// Orden topológico de los eventos (útil para mostrar las tablas).
  final List<String> topoOrder;

  const CpmResult({
    required this.hasCycle,
    required this.earliestTimes,
    required this.latestTimes,
    required this.slacks,
    required this.criticalEdgeIds,
    required this.criticalNodeIds,
    required this.projectDuration,
    required this.steps,
    this.topoOrder = const [],
  });
}

/// Implementación del método de la ruta crítica (CPM), sobre una red de
/// actividades en flechas (AOA): los nodos son eventos y cada arista es
/// una actividad cuya duración es su peso (`weight`). Cada etapa queda
/// registrada como [CpmStep] para poder animarla en la UI.
class CpmAlgorithm {
  static CpmResult solve({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
  }) {
    final steps = <CpmStep>[];
    final ids = nodes.map((n) => n.id).toList();

    final name = <String, String>{
      for (final n in nodes) n.id: n.label.trim().isNotEmpty ? n.label : n.id,
    };
    String nm(String id) => name[id] ?? id;

    final outEdges = <String, List<EdgeModel>>{for (final id in ids) id: []};
    final inEdges = <String, List<EdgeModel>>{for (final id in ids) id: []};
    for (final e in edges) {
      outEdges[e.sourceId]?.add(e);
      inEdges[e.targetId]?.add(e);
    }

    // ---------- Orden topológico (Kahn) ----------
    final inDegree = <String, int>{
      for (final id in ids) id: inEdges[id]?.length ?? 0,
    };
    final queue = <String>[
      for (final id in ids)
        if (inDegree[id] == 0) id,
    ];
    final topoOrder = <String>[];
    final pending = List<String>.of(queue);
    while (pending.isNotEmpty) {
      pending.sort();
      final u = pending.removeAt(0);
      topoOrder.add(u);
      for (final e in outEdges[u] ?? const <EdgeModel>[]) {
        inDegree[e.targetId] = (inDegree[e.targetId] ?? 0) - 1;
        if (inDegree[e.targetId] == 0) pending.add(e.targetId);
      }
    }

    if (topoOrder.length != ids.length) {
      steps.add(
        const CpmStep(
          phase: CpmPhase.topoOrder,
          title: 'Ciclo detectado',
          description:
              'La red tiene un ciclo de actividades, así que no es una red '
              'de proyecto válida (debe ser un grafo dirigido acíclico). '
              'CPM no puede continuar.',
        ),
      );
      return CpmResult(
        hasCycle: true,
        earliestTimes: const {},
        latestTimes: const {},
        slacks: const {},
        criticalEdgeIds: const [],
        criticalNodeIds: const [],
        projectDuration: 0,
        steps: steps,
      );
    }

    steps.add(
      CpmStep(
        phase: CpmPhase.topoOrder,
        title: 'Orden topológico',
        description:
            'Se ordenan los eventos respetando las dependencias: '
            '${topoOrder.map(nm).join(' → ')}.',
        activeNodeIds: topoOrder,
      ),
    );

    // ---------- Recorrido hacia adelante: ES (tiempos más tempranos) ----------
    final es = <String, double>{};
    for (final u in topoOrder) {
      final preds = inEdges[u] ?? const <EdgeModel>[];
      double value = 0;
      String? viaEdge;
      for (final e in preds) {
        final candidate = (es[e.sourceId] ?? 0) + e.weight;
        if (candidate > value) {
          value = candidate;
          viaEdge = e.id;
        }
      }
      es[u] = value;
      final fwdLines = <String>[];
      for (final e in preds) {
        final base = es[e.sourceId] ?? 0;
        fwdLines.add(
          '• ${nm(e.sourceId)} → ${nm(u)}:  ES(${nm(e.sourceId)}) + duración = '
          '${_fmt(base)} + ${_fmt(e.weight)} = ${_fmt(base + e.weight)}',
        );
      }
      steps.add(
        CpmStep(
          phase: CpmPhase.forwardPass,
          title: 'IDA · ES(${nm(u)}) = ${_fmt(value)}',
          description: preds.isEmpty
              ? '${nm(u)} es un evento inicial (no le llega ninguna '
                    'actividad), así que arranca en 0.\nES(${nm(u)}) = 0'
              : 'ES = el mayor de los tiempos de llegada (hay que esperar a '
                    'que termine la actividad más lenta).\n'
                    '${fwdLines.join('\n')}\n'
                    'ES(${nm(u)}) = ${preds.length > 1 ? 'máx → ' : ''}${_fmt(value)}',
          activeNodeIds: [u],
          activeEdgeId: viaEdge,
          candidateEdgeIds: [for (final e in preds) e.id],
          earliestTimes: Map.of(es),
          changes: [CpmValueChange(targetId: u, oldValue: 0, newValue: value)],
        ),
      );
    }

    // Nodos "sumidero": sin actividades salientes. La duración del
    // proyecto es el mayor ES entre ellos.
    final sinks = [
      for (final id in ids)
        if ((outEdges[id] ?? const []).isEmpty) id,
    ];
    final projectDuration = sinks.isEmpty
        ? (es.values.isEmpty ? 0.0 : es.values.reduce((a, b) => a > b ? a : b))
        : sinks.map((s) => es[s] ?? 0).reduce((a, b) => a > b ? a : b);

    // ---------- Recorrido hacia atrás: LS (tiempos más tardíos) ----------
    final ls = <String, double>{};
    for (final u in topoOrder.reversed) {
      final succs = outEdges[u] ?? const <EdgeModel>[];
      double value;
      String? viaEdge;
      if (succs.isEmpty) {
        value = es[u] ?? 0; // nodo sumidero: no puede haber holgura propia
      } else {
        value = double.infinity;
        for (final e in succs) {
          final candidate = (ls[e.targetId] ?? double.infinity) - e.weight;
          if (candidate < value) {
            value = candidate;
            viaEdge = e.id;
          }
        }
      }
      ls[u] = value;
      final bwdLines = <String>[];
      for (final e in succs) {
        final lim = ls[e.targetId] ?? double.infinity;
        bwdLines.add(
          '• ${nm(u)} → ${nm(e.targetId)}:  LS(${nm(e.targetId)}) − duración = '
          '${_fmt(lim)} − ${_fmt(e.weight)} = ${_fmt(lim - e.weight)}',
        );
      }
      steps.add(
        CpmStep(
          phase: CpmPhase.backwardPass,
          title: 'VUELTA · LS(${nm(u)}) = ${_fmt(value)}',
          description: succs.isEmpty
              ? '${nm(u)} es un evento final: no puede haber holgura, así '
                    'que su tiempo más tardío es igual al más temprano.\n'
                    'LS(${nm(u)}) = ES(${nm(u)}) = ${_fmt(value)}'
              : 'LS = el menor de los límites que imponen las actividades '
                    'siguientes (si te pasás del menor, atrasás el '
                    'proyecto).\n'
                    '${bwdLines.join('\n')}\n'
                    'LS(${nm(u)}) = ${succs.length > 1 ? 'mín → ' : ''}${_fmt(value)}',
          activeNodeIds: [u],
          activeEdgeId: viaEdge,
          candidateEdgeIds: [for (final e in succs) e.id],
          earliestTimes: Map.of(es),
          latestTimes: Map.of(ls),
          changes: [
            CpmValueChange(targetId: u, oldValue: es[u] ?? 0, newValue: value),
          ],
        ),
      );
    }

    // ---------- Holgura por actividad ----------
    final slacks = <String, double>{};
    for (final e in edges) {
      final slack = (ls[e.targetId] ?? 0) - (es[e.sourceId] ?? 0) - e.weight;
      slacks[e.id] = slack;
      final isCritical = slack.abs() < 1e-9;
      steps.add(
        CpmStep(
          phase: CpmPhase.slack,
          title:
              'HOLGURA ${nm(e.sourceId)} → ${nm(e.targetId)} = '
              '${_fmt(slack)}',
          description:
              'H = LS(${nm(e.targetId)}) − ES(${nm(e.sourceId)}) − duración\n'
              'H = ${_fmt(ls[e.targetId] ?? 0)} − ${_fmt(es[e.sourceId] ?? 0)} '
              '− ${_fmt(e.weight)} = ${_fmt(slack)}\n'
              '${isCritical ? 'Holgura 0 → actividad CRÍTICA: si se atrasa, se atrasa todo el proyecto.' : 'Holgura > 0 → NO es crítica: se puede atrasar ${_fmt(slack)} sin afectar el proyecto.'}',
          activeEdgeId: e.id,
          activeNodeIds: [e.sourceId, e.targetId],
          earliestTimes: Map.of(es),
          latestTimes: Map.of(ls),
          slacks: Map.of(slacks),
          criticalEdgeIds: [
            for (final entry in slacks.entries)
              if (entry.value.abs() < 1e-9) entry.key,
          ],
        ),
      );
    }

    // ---------- Ruta crítica ----------
    final criticalEdges = <String>[];
    final criticalNodes = <String>[];
    // Se arma la ruta crítica siguiendo, desde cada fuente, actividades de
    // holgura 0 hasta llegar a un sumidero.
    final sources = [
      for (final id in ids)
        if ((inEdges[id] ?? const []).isEmpty) id,
    ];
    for (final start in sources) {
      String current = start;
      if (!criticalNodes.contains(current)) criticalNodes.add(current);
      bool advanced = true;
      while (advanced) {
        advanced = false;
        for (final e in outEdges[current] ?? const <EdgeModel>[]) {
          if ((slacks[e.id] ?? 1).abs() < 1e-9) {
            criticalEdges.add(e.id);
            current = e.targetId;
            if (!criticalNodes.contains(current)) {
              criticalNodes.add(current);
            }
            advanced = true;
            break;
          }
        }
      }
    }

    String criticalSumText() {
      final ws = <double>[];
      for (final id in criticalEdges) {
        for (final e in edges) {
          if (e.id == id) ws.add(e.weight);
        }
      }
      final total = ws.fold<double>(0, (a, b) => a + b);
      if (ws.isEmpty || (total - projectDuration).abs() > 1e-9) {
        return _fmt(projectDuration);
      }
      return '${ws.map(_fmt).join(' + ')} = ${_fmt(projectDuration)}';
    }

    steps.add(
      CpmStep(
        phase: CpmPhase.criticalPath,
        title: 'RUTA CRÍTICA',
        description:
            'Se unen las actividades con holgura 0, desde el inicio hasta '
            'el final:\n'
            '${criticalNodes.map(nm).join(' → ')}\n'
            'Es la cadena más larga: define la duración mínima del '
            'proyecto.',
        candidateEdgeIds: criticalEdges,
        activeNodeIds: criticalNodes,
        earliestTimes: Map.of(es),
        latestTimes: Map.of(ls),
        slacks: Map.of(slacks),
        criticalEdgeIds: criticalEdges,
        criticalNodeIds: criticalNodes,
      ),
    );

    steps.add(
      CpmStep(
        phase: CpmPhase.done,
        title: 'RESULTADO · Duración total = ${_fmt(projectDuration)}',
        description:
            'Duración del proyecto = ${criticalSumText()}\n'
            'Ruta crítica: ${criticalNodes.map(nm).join(' → ')}\n'
            'Deslizá a la derecha (o tocá el botón de tabla) para ver la '
            'tabla final paso a paso.',
        earliestTimes: Map.of(es),
        latestTimes: Map.of(ls),
        slacks: Map.of(slacks),
        criticalEdgeIds: criticalEdges,
        criticalNodeIds: criticalNodes,
        projectDuration: projectDuration,
      ),
    );

    return CpmResult(
      hasCycle: false,
      earliestTimes: es,
      latestTimes: ls,
      slacks: slacks,
      criticalEdgeIds: criticalEdges,
      criticalNodeIds: criticalNodes,
      projectDuration: projectDuration,
      steps: steps,
      topoOrder: topoOrder,
    );
  }

  static String _fmt(double v) {
    if (v == double.infinity) return '∞';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}
