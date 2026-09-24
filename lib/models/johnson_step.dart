/// Id que representa al nodo virtual "q" que Johnson agrega temporalmente
/// para calcular el sistema de potenciales h(v). No forma parte del
/// grafo real: el painter lo dibuja en una posición calculada aparte.
const String kJohnsonVirtualNodeId = '__q__';

enum JohnsonPhase {
  setup, // se agrega el nodo virtual q
  bellmanFord, // Bellman-Ford desde q, calculando h(v)
  negativeCycle, // se detectó un ciclo negativo: el algoritmo se detiene
  reweight, // se recalculan los pesos ŵ(u,v) = w + h(u) - h(v)
  removeVirtualNode, // q y sus aristas temporales se retiran
  dijkstra, // Dijkstra por cada nodo sobre el grafo repesado
  done, // matriz final de distancias reales
}

/// Un cambio de valor numérico (peso, potencial o distancia) ocurrido en
/// este paso. Se usa para animar el número viejo -> número nuevo
/// ("counter tween" con rebote elástico).
class JohnsonValueChange {
  final String targetId; // id de nodo o de arista
  final double oldValue;
  final double newValue;

  const JohnsonValueChange({
    required this.targetId,
    required this.oldValue,
    required this.newValue,
  });
}

/// Un fotograma del algoritmo de Johnson, listo para animarse en pantalla.
class JohnsonStep {
  final JohnsonPhase phase;
  final String title;
  final String description;

  /// Nodo(s) a resaltar con el efecto de onda expansiva (ripple).
  final List<String> activeNodeIds;

  /// Arista a resaltar con el trazo líquido (glow dash).
  final String? activeEdgeId;

  /// Nodo origen del recorrido Dijkstra actual (null fuera de esa fase).
  final String? sourceNodeId;

  /// Nodos ya "sellados" (visitados) en el Dijkstra actual.
  final List<String> settledNodeIds;

  /// Potenciales h(v) vigentes en este paso.
  final Map<String, double> potentials;

  /// Distancias tentativas del Dijkstra actual, por nodo destino.
  final Map<String, double> distances;

  /// Cambios de valor a animar en este paso.
  final List<JohnsonValueChange> changes;

  /// Si el nodo virtual q (y sus aristas) sigue visible en este paso.
  final bool virtualNodeVisible;

  const JohnsonStep({
    required this.phase,
    required this.title,
    required this.description,
    this.activeNodeIds = const [],
    this.activeEdgeId,
    this.sourceNodeId,
    this.settledNodeIds = const [],
    this.potentials = const {},
    this.distances = const {},
    this.changes = const [],
    this.virtualNodeVisible = false,
  });
}
