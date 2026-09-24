import '../models/node_model.dart';
import '../models/edge_model.dart';
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

  const CpmResult({
    required this.hasCycle,
    required this.earliestTimes,
    required this.latestTimes,
    required this.slacks,
    required this.criticalEdgeIds,
    required this.criticalNodeIds,
    required this.projectDuration,
    required this.steps,
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
      steps.add(
        CpmStep(
          phase: CpmPhase.forwardPass,
          title: 'ES(${nm(u)}) = ${_fmt(value)}',
          description: preds.isEmpty
              ? '${nm(u)} no tiene actividades previas: su tiempo más '
                    'temprano es 0.'
              : 'El tiempo más temprano de ${nm(u)} es el mayor de sus '
                    'llegadas: ES = ${_fmt(value)}.',
          activeNodeIds: [u],
          activeEdgeId: viaEdge,
          earliestTimes: Map.of(es),
          changes: [
            CpmValueChange(targetId: u, oldValue: 0, newValue: value),
          ],
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
      steps.add(
        CpmStep(
          phase: CpmPhase.backwardPass,
          title: 'LS(${nm(u)}) = ${_fmt(value)}',
          description: succs.isEmpty
              ? '${nm(u)} es un evento final: su tiempo más tardío coincide '
                    'con su tiempo más temprano.'
              : 'El tiempo más tardío de ${nm(u)} es el menor límite que '
                    'imponen sus actividades siguientes: LS = ${_fmt(value)}.',
          activeNodeIds: [u],
          activeEdgeId: viaEdge,
          earliestTimes: Map.of(es),
          latestTimes: Map.of(ls),
          changes: [
            CpmValueChange(
              targetId: u,
              oldValue: es[u] ?? 0,
              newValue: value,
            ),
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
              'Holgura ${nm(e.sourceId)} → ${nm(e.targetId)} = '
              '${_fmt(slack)}',
          description: isCritical
              ? 'Holgura 0: esta actividad es crítica, cualquier retraso '
                    'retrasa todo el proyecto.'
              : 'Holgura = LS(${nm(e.targetId)}) − ES(${nm(e.sourceId)}) − '
                    'duración = ${_fmt(slack)}. Hay margen antes de afectar '
                    'el proyecto.',
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

    steps.add(
      CpmStep(
        phase: CpmPhase.criticalPath,
        title: 'Ruta crítica',
        description:
            'La ruta crítica es la secuencia de actividades con holgura 0: '
            '${criticalNodes.map(nm).join(' → ')}. Define la duración '
            'mínima del proyecto.',
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
        title: 'Duración total del proyecto: ${_fmt(projectDuration)}',
        description:
            'Con el recorrido hacia adelante y hacia atrás completos, el '
            'proyecto no puede terminar antes de ${_fmt(projectDuration)} '
            'unidades de tiempo. La ruta crítica queda resaltada en el '
            'grafo.',
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
    );
  }

  static String _fmt(double v) {
    if (v == double.infinity) return '∞';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}
