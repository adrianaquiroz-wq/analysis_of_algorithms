import '../models/node_model.dart';
import '../models/edge_model.dart';
import '../models/johnson_step.dart';

class JohnsonResult {
  final bool hasNegativeCycle;
  final String? negativeCycleEdgeId;

  /// Potenciales h(v) calculados por Bellman-Ford desde el nodo virtual q.
  final Map<String, double> potentials;

  /// Distancias reales más cortas: distances[origen][destino].
  final Map<String, Map<String, double>> distances;

  /// Historial completo de pasos, listo para reproducir/animar.
  final List<JohnsonStep> steps;

  const JohnsonResult({
    required this.hasNegativeCycle,
    this.negativeCycleEdgeId,
    required this.potentials,
    required this.distances,
    required this.steps,
  });
}

/// Implementación del algoritmo de Johnson para caminos más cortos entre
/// todos los pares de nodos, tolerando pesos negativos (sin ciclos
/// negativos). Cada etapa del algoritmo queda registrada como [JohnsonStep]
/// para poder animarla en la UI.
class JohnsonAlgorithm {
  static JohnsonResult solve({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
  }) {
    final steps = <JohnsonStep>[];
    final ids = nodes.map((n) => n.id).toList();

    // Nombre "legible" de cada nodo: su label si tiene, si no su id.
    final name = <String, String>{
      for (final n in nodes) n.id: n.label.trim().isNotEmpty ? n.label : n.id,
    };
    String nm(String id) => name[id] ?? id;

    // ---------- Paso 0: nodo virtual q ----------
    steps.add(
      JohnsonStep(
        phase: JohnsonPhase.setup,
        title: 'Nodo virtual q',
        description:
            'Se agrega un nodo virtual q conectado a todos los nodos con '
            'aristas de peso 0. Sirve para calcular un sistema de '
            'potenciales h(v) sin favorecer a ningún nodo del grafo.',
        activeNodeIds: [kJohnsonVirtualNodeId, ...ids],
        virtualNodeVisible: true,
        potentials: {for (final id in ids) id: 0},
      ),
    );

    // ---------- Bellman-Ford desde q ----------
    // Como todas las aristas q -> v pesan 0, h(v) parte en 0 para todos y
    // basta relajar las aristas reales hasta |V|-1 veces.
    final h = {for (final id in ids) id: 0.0};
    final n = ids.length;
    String? negativeCycleEdgeId;

    for (int i = 0; i < n - 1; i++) {
      bool relaxedAny = false;
      for (final e in edges) {
        final candidate = h[e.sourceId]! + e.weight;
        if (candidate < h[e.targetId]!) {
          final oldValue = h[e.targetId]!;
          h[e.targetId] = candidate;
          relaxedAny = true;
          steps.add(
            JohnsonStep(
              phase: JohnsonPhase.bellmanFord,
              title: 'Bellman-Ford · iteración ${i + 1}',
              description:
                  'Se relaja la arista ${nm(e.sourceId)} → ${nm(e.targetId)}: '
                  'h(${nm(e.targetId)}) pasa de ${_fmt(oldValue)} a '
                  '${_fmt(candidate)}.',
              activeNodeIds: [e.sourceId, e.targetId],
              activeEdgeId: e.id,
              potentials: Map.of(h),
              changes: [
                JohnsonValueChange(
                  targetId: e.targetId,
                  oldValue: oldValue,
                  newValue: candidate,
                ),
              ],
              virtualNodeVisible: true,
            ),
          );
        }
      }
      if (!relaxedAny) break;
    }

    // Pasada de control: si algo todavía se puede relajar, hay ciclo
    // negativo alcanzable y Johnson no puede continuar.
    for (final e in edges) {
      if (h[e.sourceId]! + e.weight < h[e.targetId]!) {
        negativeCycleEdgeId = e.id;
        break;
      }
    }

    if (negativeCycleEdgeId != null) {
      final badEdge = edges.firstWhere((e) => e.id == negativeCycleEdgeId);
      steps.add(
        JohnsonStep(
          phase: JohnsonPhase.negativeCycle,
          title: 'Ciclo negativo detectado',
          description:
              'El grafo contiene un ciclo de peso negativo que pasa por '
              '${nm(badEdge.sourceId)} → ${nm(badEdge.targetId)}, así que no '
              'existe un camino más corto bien definido. Johnson se detiene '
              'acá.',
          activeEdgeId: negativeCycleEdgeId,
          potentials: Map.of(h),
          virtualNodeVisible: true,
        ),
      );
      return JohnsonResult(
        hasNegativeCycle: true,
        negativeCycleEdgeId: negativeCycleEdgeId,
        potentials: h,
        distances: const {},
        steps: steps,
      );
    }

    // ---------- Repesaje ----------
    final reweighted = <String, double>{}; // edge.id -> nuevo peso ŵ
    for (final e in edges) {
      final newWeight = e.weight + h[e.sourceId]! - h[e.targetId]!;
      reweighted[e.id] = newWeight;
      steps.add(
        JohnsonStep(
          phase: JohnsonPhase.reweight,
          title: 'Repesaje ${nm(e.sourceId)} → ${nm(e.targetId)}',
          description:
              'ŵ(${nm(e.sourceId)},${nm(e.targetId)}) = ${_fmt(e.weight)} + '
              'h(${nm(e.sourceId)}) − h(${nm(e.targetId)}) = '
              '${_fmt(newWeight)}.',
          activeEdgeId: e.id,
          potentials: Map.of(h),
          changes: [
            JohnsonValueChange(
              targetId: e.id,
              oldValue: e.weight,
              newValue: newWeight,
            ),
          ],
          virtualNodeVisible: true,
        ),
      );
    }

    steps.add(
      JohnsonStep(
        phase: JohnsonPhase.removeVirtualNode,
        title: 'Se retira el nodo virtual',
        description:
            'El nodo q y sus aristas temporales ya cumplieron su función. '
            'El grafo original vuelve a ser protagonista, ahora con los '
            'pesos ŵ (todos no negativos).',
        potentials: Map.of(h),
        virtualNodeVisible: false,
      ),
    );

    // ---------- Dijkstra por cada nodo, sobre el grafo repesado ----------
    final outEdges = <String, List<EdgeModel>>{for (final id in ids) id: []};
    for (final e in edges) {
      outEdges[e.sourceId]?.add(e);
    }

    final allDistances = <String, Map<String, double>>{};

    for (final source in ids) {
      final dist = {for (final id in ids) id: double.infinity};
      dist[source] = 0;
      final settled = <String>{};

      steps.add(
        JohnsonStep(
          phase: JohnsonPhase.dijkstra,
          title: 'Dijkstra desde ${nm(source)}',
          description:
              'Se inicia una nueva búsqueda de caminos más cortos usando '
              '${nm(source)} como origen, sobre el grafo con pesos ŵ.',
          activeNodeIds: [source],
          sourceNodeId: source,
          distances: Map.of(dist),
        ),
      );

      while (settled.length < ids.length) {
        String? u;
        double best = double.infinity;
        for (final id in ids) {
          if (!settled.contains(id) && dist[id]! < best) {
            best = dist[id]!;
            u = id;
          }
        }
        if (u == null) break; // el resto es inalcanzable
        settled.add(u);

        steps.add(
          JohnsonStep(
            phase: JohnsonPhase.dijkstra,
            title: 'Nodo sellado: ${nm(u)}',
            description:
                'Se marca ${nm(u)} como visitado, con distancia '
                '${_fmt(dist[u]!)} desde ${nm(source)}. Su distancia ya no '
                'puede mejorar.',
            activeNodeIds: [u],
            sourceNodeId: source,
            settledNodeIds: settled.toList(),
            distances: Map.of(dist),
          ),
        );

        for (final e in outEdges[u] ?? const <EdgeModel>[]) {
          if (settled.contains(e.targetId)) continue;
          final w = reweighted[e.id]!;
          final candidate = dist[u]! + w;
          if (candidate < dist[e.targetId]!) {
            final oldValue = dist[e.targetId]!;
            dist[e.targetId] = candidate;
            steps.add(
              JohnsonStep(
                phase: JohnsonPhase.dijkstra,
                title: 'Relajación ${nm(u)} → ${nm(e.targetId)}',
                description:
                    'Aparece un camino mejor hacia ${nm(e.targetId)} '
                    'pasando por ${nm(u)}: distancia ${_fmt(candidate)} '
                    '(antes ${oldValue.isFinite ? _fmt(oldValue) : '∞'}).',
                activeNodeIds: [u, e.targetId],
                activeEdgeId: e.id,
                sourceNodeId: source,
                settledNodeIds: settled.toList(),
                distances: Map.of(dist),
                changes: [
                  JohnsonValueChange(
                    targetId: e.targetId,
                    oldValue: oldValue.isFinite ? oldValue : candidate,
                    newValue: candidate,
                  ),
                ],
              ),
            );
          }
        }
      }

      // Se recuperan las distancias reales: d(u,v) = d'(u,v) - h(u) + h(v)
      final realDist = <String, double>{};
      for (final id in ids) {
        realDist[id] = dist[id]!.isFinite
            ? dist[id]! - h[source]! + h[id]!
            : double.infinity;
      }
      allDistances[source] = realDist;
    }

    steps.add(
      JohnsonStep(
        phase: JohnsonPhase.done,
        title: 'Matriz de distancias completa',
        description:
            'Se recuperan las distancias reales con '
            "d(u,v) = d'(u,v) − h(u) + h(v) para cada par de nodos. Este es "
            'el resultado final del algoritmo de Johnson.',
        potentials: Map.of(h),
      ),
    );

    return JohnsonResult(
      hasNegativeCycle: false,
      potentials: h,
      distances: allDistances,
      steps: steps,
    );
  }

  static String _fmt(double v) {
    if (v == double.infinity) return '∞';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}
