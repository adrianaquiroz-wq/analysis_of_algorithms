/// Fases del método de la ruta crítica (CPM - Critical Path Method).
/// El grafo se interpreta como una red de actividades sobre flechas
/// (AOA): los nodos son "eventos" y las aristas son "actividades" cuyo
/// peso (weight) representa la duración.
enum CpmPhase {
  topoOrder, // se calcula el orden topológico de los eventos
  forwardPass, // recorrido hacia adelante: tiempos más tempranos (ES)
  backwardPass, // recorrido hacia atrás: tiempos más tardíos (LS)
  slack, // holgura por actividad: LS(destino) - ES(origen) - duración
  criticalPath, // se traza la ruta crítica (holgura = 0)
  done, // resumen final: duración total del proyecto y ruta crítica
}

/// Un cambio de valor numérico (ES, LS u holgura) ocurrido en este paso.
/// Se usa para animar el número viejo -> número nuevo (counter tween con
/// rebote elástico).
class CpmValueChange {
  final String targetId; // id de nodo o de arista
  final double oldValue;
  final double newValue;

  const CpmValueChange({
    required this.targetId,
    required this.oldValue,
    required this.newValue,
  });
}

/// Un fotograma del algoritmo CPM, listo para animarse en pantalla.
class CpmStep {
  final CpmPhase phase;
  final String title;
  final String description;

  /// Nodo(s) a resaltar con el efecto de onda expansiva (ripple).
  final List<String> activeNodeIds;

  /// Arista a resaltar con el trazo líquido (glow dash) mientras se
  /// calcula.
  final String? activeEdgeId;

  /// Tiempos más tempranos (ES) vigentes en este paso, por nodo.
  final Map<String, double> earliestTimes;

  /// Tiempos más tardíos (LS) vigentes en este paso, por nodo.
  final Map<String, double> latestTimes;

  /// Holgura vigente por arista (id de arista -> holgura).
  final Map<String, double> slacks;

  /// Aristas que ya se confirmaron como parte de la ruta crítica
  /// (holgura = 0). Se dibujan siempre con el trazo líquido, no solo la
  /// activa del paso actual.
  final List<String> criticalEdgeIds;

  /// Nodos sobre la ruta crítica.
  final List<String> criticalNodeIds;

  /// Cambios de valor a animar en este paso.
  final List<CpmValueChange> changes;

  /// Duración total del proyecto (solo se llena en la fase [done]).
  final double? projectDuration;

  const CpmStep({
    required this.phase,
    required this.title,
    required this.description,
    this.activeNodeIds = const [],
    this.activeEdgeId,
    this.earliestTimes = const {},
    this.latestTimes = const {},
    this.slacks = const {},
    this.criticalEdgeIds = const [],
    this.criticalNodeIds = const [],
    this.changes = const [],
    this.projectDuration,
  });
}
