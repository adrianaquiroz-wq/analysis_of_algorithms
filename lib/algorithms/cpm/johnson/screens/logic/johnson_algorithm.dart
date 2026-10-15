import '../../../../../models/node_model.dart';
import '../../../../../models/edge_model.dart';

enum JohnsonMode { max, min }

class JohnsonResult {
  final bool ok;
  final String? error;
  final JohnsonMode mode;
  final String originId;
  final String destId;

  /// Nodos y aristas de la ruta encontrada, en orden (origen -> destino).
  final List<String> routeNodeIds;
  final List<String> routeEdgeIds;

  /// Peso total de la ruta.
  final double total;

  /// Etiquetas [temprano | tardío] por nodo (solo nodos entre origen y destino).
  final Map<String, double> earliest;
  final Map<String, double> latest;

  /// Holgura por arista (id de arista -> holgura). 0 = está en el camino.
  final Map<String, double> slacks;

  /// Texto del desglose: "5 (A→C) + 7 (C→B) + 4 (B→D) = 16".
  final String breakdown;

  /// Explicación del porqué se eligió esa ruta.
  final List<String> reasons;

  const JohnsonResult({
    required this.ok,
    this.error,
    required this.mode,
    required this.originId,
    required this.destId,
    this.routeNodeIds = const [],
    this.routeEdgeIds = const [],
    this.total = 0,
    this.earliest = const {},
    this.latest = const {},
    this.slacks = const {},
    this.breakdown = '',
    this.reasons = const [],
  });

  factory JohnsonResult.failure(
    JohnsonMode mode,
    String originId,
    String destId,
    String message,
  ) {
    return JohnsonResult(
      ok: false,
      error: message,
      mode: mode,
      originId: originId,
      destId: destId,
    );
  }
}

/// Algoritmo de Johnson (método de etiquetas) para el camino MÁXIMO o MÍNIMO
/// entre un nodo origen y un nodo destino.
///
/// - Máximo: pasada hacia adelante (mayor temprano) y hacia atrás (menor
///   tardío), igual que la ruta crítica. Necesita una red sin ciclos.
/// - Mínimo: distancia mínima desde el origen (acepta pesos negativos y
///   ciclos, siempre que no haya ciclos negativos).
class JohnsonAlgorithm {
  static JohnsonResult solve({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required String originId,
    required String destId,
    required JohnsonMode mode,
  }) {
    final isMax = mode == JohnsonMode.max;

    final name = <String, String>{
      for (final n in nodes) n.id: n.label.trim().isNotEmpty ? n.label : n.id,
    };
    String nm(String id) => name[id] ?? id;
    JohnsonResult fail(String msg) =>
        JohnsonResult.failure(mode, originId, destId, msg);

    if (originId == destId) {
      return fail('El origen y el destino tienen que ser nodos distintos.');
    }

    // ---------- Alcanzabilidad ----------
    final fwd = <String, List<String>>{};
    final bwd = <String, List<String>>{};
    for (final e in edges) {
      (fwd[e.sourceId] ??= []).add(e.targetId);
      (bwd[e.targetId] ??= []).add(e.sourceId);
    }
    final fromOrigin = _reach(originId, fwd);
    if (!fromOrigin.contains(destId)) {
      return fail(
        'No existe ningún camino que vaya de ${nm(originId)} a '
        '${nm(destId)}. Acordate de que las aristas tienen dirección.',
      );
    }
    final toDest = _reach(destId, bwd);
    final relevant = fromOrigin.intersection(toDest);

    final relEdges = <EdgeModel>[
      for (final e in edges)
        if (relevant.contains(e.sourceId) && relevant.contains(e.targetId)) e,
    ];
    final relIn = <String, List<EdgeModel>>{for (final id in relevant) id: []};
    final relOut = <String, List<EdgeModel>>{for (final id in relevant) id: []};
    for (final e in relEdges) {
      relIn[e.targetId]!.add(e);
      relOut[e.sourceId]!.add(e);
    }

    final earliest = <String, double>{};
    final latest = <String, double>{};
    final pred = <String, EdgeModel>{}; // nodo -> arista elegida para llegar

    if (isMax) {
      // ---------- Orden topológico (Kahn) sobre el tramo origen-destino ----------
      final indeg = <String, int>{
        for (final id in relevant) id: relIn[id]!.length,
      };
      final queue = <String>[
        for (final id in relevant)
          if (indeg[id] == 0) id,
      ];
      final topo = <String>[];
      while (queue.isNotEmpty) {
        final u = queue.removeAt(0);
        topo.add(u);
        for (final e in relOut[u]!) {
          indeg[e.targetId] = indeg[e.targetId]! - 1;
          if (indeg[e.targetId] == 0) queue.add(e.targetId);
        }
      }
      if (topo.length != relevant.length) {
        return fail(
          'Hay un ciclo en el tramo entre ${nm(originId)} y ${nm(destId)}, '
          'así que el camino máximo no está definido (se podría dar vueltas '
          'para siempre). Sacá el ciclo o probá con el camino mínimo.',
        );
      }

      // ---------- Hacia adelante: temprano = MAYOR (anterior + peso) ----------
      for (final u in topo) {
        if (u == originId) {
          earliest[u] = 0;
          continue;
        }
        double best = double.negativeInfinity;
        EdgeModel? via;
        for (final e in relIn[u]!) {
          final cand = earliest[e.sourceId]! + e.weight;
          if (cand > best) {
            best = cand;
            via = e;
          }
        }
        earliest[u] = best;
        pred[u] = via!;
      }

      // ---------- Hacia atrás: tardío = MENOR (siguiente - peso) ----------
      latest[destId] = earliest[destId]!;
      for (final u in topo.reversed) {
        if (u == destId) continue;
        double best = double.infinity;
        for (final e in relOut[u]!) {
          final cand = latest[e.targetId]! - e.weight;
          if (cand < best) best = cand;
        }
        latest[u] = best;
      }
    } else {
      // ---------- Mínimo: Bellman-Ford desde el origen ----------
      final dist = <String, double>{
        for (final n in nodes) n.id: double.infinity,
      };
      dist[originId] = 0;
      final predAll = <String, EdgeModel>{};
      for (int i = 0; i < nodes.length - 1; i++) {
        bool changed = false;
        for (final e in edges) {
          final ds = dist[e.sourceId];
          final dt = dist[e.targetId];
          if (ds == null || dt == null || ds == double.infinity) continue;
          if (ds + e.weight < dt - 1e-12) {
            dist[e.targetId] = ds + e.weight;
            predAll[e.targetId] = e;
            changed = true;
          }
        }
        if (!changed) break;
      }
      for (final e in edges) {
        final ds = dist[e.sourceId];
        final dt = dist[e.targetId];
        if (ds == null || dt == null || ds == double.infinity) continue;
        if (ds + e.weight < dt - 1e-12) {
          return fail(
            'Hay un ciclo de peso negativo alcanzable desde ${nm(originId)} '
            '(pasa por ${nm(e.sourceId)} → ${nm(e.targetId)}), así que no '
            'existe un camino mínimo bien definido.',
          );
        }
      }

      // Distancia que falta hasta el destino (Bellman-Ford al revés).
      final rest = <String, double>{
        for (final n in nodes) n.id: double.infinity,
      };
      rest[destId] = 0;
      for (int i = 0; i < nodes.length - 1; i++) {
        bool changed = false;
        for (final e in edges) {
          final rs = rest[e.sourceId];
          final rt = rest[e.targetId];
          if (rs == null || rt == null || rt == double.infinity) continue;
          if (rt + e.weight < rs - 1e-12) {
            rest[e.sourceId] = rt + e.weight;
            changed = true;
          }
        }
        if (!changed) break;
      }

      final d = dist[destId]!;
      for (final id in relevant) {
        earliest[id] = dist[id]!;
        // tardío = lo más tarde que se puede llegar sin alargar el mínimo
        latest[id] = d - rest[id]!;
        if (id != originId && predAll[id] != null) pred[id] = predAll[id]!;
      }
    }

    // ---------- Holguras ----------
    final slacks = <String, double>{};
    for (final e in relEdges) {
      double s;
      if (isMax) {
        s = latest[e.targetId]! - earliest[e.sourceId]! - e.weight;
      } else {
        // dist(u) + w + resto(v) - D, con tardío(v) = D - resto(v)
        s = earliest[e.sourceId]! + e.weight - latest[e.targetId]!;
      }
      slacks[e.id] = s.abs() < 1e-9 ? 0 : s;
    }

    // ---------- Reconstrucción de la ruta ----------
    final routeNodes = <String>[destId];
    final routeEdges = <EdgeModel>[];
    String cur = destId;
    int guard = 0;
    while (cur != originId && guard <= nodes.length + 1) {
      final e = pred[cur];
      if (e == null) break;
      routeEdges.insert(0, e);
      cur = e.sourceId;
      routeNodes.insert(0, cur);
      guard++;
    }
    if (cur != originId) {
      return fail('No se pudo reconstruir la ruta. Revisá las aristas.');
    }

    final total = earliest[destId]!;

    // ---------- Desglose ----------
    String w(double v) => v < 0 ? '(${fmt(v)})' : fmt(v);
    final parts = [
      for (final e in routeEdges)
        '${w(e.weight)} (${nm(e.sourceId)}→${nm(e.targetId)})',
    ];
    final breakdown =
        '${isMax ? 'Camino crítico' : 'Camino más corto'}: '
        '${parts.join(' + ')} = ${fmt(total)}';

    // ---------- Porqué ----------
    final reasons = <String>[];
    if (isMax) {
      reasons.add(
        'Hacia adelante: el temprano de cada nodo es el MAYOR de '
        '(temprano del anterior + peso), porque para llegar hay que esperar '
        'al camino más largo.',
      );
      reasons.add(
        'Hacia atrás: el tardío es el MENOR de (tardío del siguiente − '
        'peso). Si temprano = tardío (holgura 0), el nodo está en el camino '
        'máximo.',
      );
    } else {
      reasons.add(
        'Hacia adelante: el temprano de cada nodo es la distancia mínima '
        'desde ${nm(originId)}, o sea el MENOR de (temprano del anterior + '
        'peso).',
      );
      reasons.add(
        'El tardío es lo más tarde que podés llegar al nodo sin alargar el '
        'camino mínimo. Si temprano = tardío (holgura 0), el nodo está en el '
        'camino mínimo.',
      );
    }
    for (final v in routeNodes) {
      if (v == originId) continue;
      final incoming = relIn[v]!;
      if (incoming.length < 2) continue;
      final cands = [
        for (final e in incoming)
          '${nm(e.sourceId)}→${nm(v)}: ${fmt(earliest[e.sourceId]!)} + '
              '${fmt(e.weight)} = ${fmt(earliest[e.sourceId]! + e.weight)}',
      ];
      reasons.add(
        'En ${nm(v)} llegan ${incoming.length} caminos (${cands.join(' | ')}) '
        '→ se elige el ${isMax ? 'mayor' : 'menor'}: ${fmt(earliest[v]!)}'
        '${pred[v] != null ? ' (viene de ${nm(pred[v]!.sourceId)})' : ''}.',
      );
    }
    final routeIds = {for (final e in routeEdges) e.id};
    final hasTie = slacks.entries.any(
      (s) => s.value == 0 && !routeIds.contains(s.key),
    );
    if (hasTie) {
      reasons.add(
        'Ojo: hay otro camino con el mismo peso (empate); se muestra uno de '
        'ellos.',
      );
    }

    return JohnsonResult(
      ok: true,
      mode: mode,
      originId: originId,
      destId: destId,
      routeNodeIds: routeNodes,
      routeEdgeIds: [for (final e in routeEdges) e.id],
      total: total,
      earliest: earliest,
      latest: latest,
      slacks: slacks,
      breakdown: breakdown,
      reasons: reasons,
    );
  }

  static Set<String> _reach(String start, Map<String, List<String>> adj) {
    final seen = <String>{start};
    final stack = <String>[start];
    while (stack.isNotEmpty) {
      final u = stack.removeLast();
      for (final v in adj[u] ?? const <String>[]) {
        if (seen.add(v)) stack.add(v);
      }
    }
    return seen;
  }

  static String fmt(double v) {
    if (v == double.infinity) return '∞';
    if (v == double.negativeInfinity) return '-∞';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}
