import 'dart:math';
import 'dart:ui' show Offset;

enum TraversalType { inOrder, preOrder, postOrder }

extension TraversalTypeX on TraversalType {
  String get label => switch (this) {
    TraversalType.inOrder => 'In-order',
    TraversalType.preOrder => 'Pre-order',
    TraversalType.postOrder => 'Post-order',
  };

  String get rule => switch (this) {
    TraversalType.inOrder => 'Izquierda → Raíz → Derecha',
    TraversalType.preOrder => 'Raíz → Izquierda → Derecha',
    TraversalType.postOrder => 'Izquierda → Derecha → Raíz',
  };
}

/// Clave de una arista sin importar el sentido en que se recorra.
String edgeKey(int a, int b) => a < b ? '$a-$b' : '$b-$a';

/// Lectura y límites de los números que escribe el usuario.
class TreeInput {
  static const int maxNodes = 63;
  static const int minValue = -999999999;
  static const int maxValue = 999999999;

  /// Separa por comas, punto y coma o espacios. Devuelve un error si algo no sirve.
  static ({List<int> values, String? error}) parse(String text) {
    final raw = text.trim();
    if (raw.isEmpty) {
      return (values: const <int>[], error: 'Escribe al menos un número.');
    }
    if (!RegExp(r'^[0-9,;\s\-]+$').hasMatch(raw)) {
      return (
        values: const <int>[],
        error: 'Solo se permiten enteros separados por comas o espacios.',
      );
    }
    final out = <int>[];
    for (final tok in raw.split(RegExp(r'[\s,;]+'))) {
      if (tok.isEmpty) continue;
      final v = int.tryParse(tok);
      if (v == null) {
        return (values: const <int>[], error: 'Valor inválido: "$tok".');
      }
      if (v < minValue || v > maxValue) {
        return (
          values: const <int>[],
          error: 'Cada valor debe estar entre $minValue y $maxValue.',
        );
      }
      out.add(v);
    }
    if (out.isEmpty) {
      return (values: const <int>[], error: 'Escribe al menos un número.');
    }
    return (values: out, error: null);
  }
}

class TreeNode {
  final int value;
  TreeNode? left;
  TreeNode? right;
  TreeNode(this.value, {this.left, this.right});

  Map<String, dynamic> toJson() => {
    'v': value,
    'l': left?.toJson(),
    'r': right?.toJson(),
  };

  factory TreeNode.fromJson(Map<String, dynamic> j) => TreeNode(
    j['v'] as int,
    left: j['l'] == null
        ? null
        : TreeNode.fromJson(j['l'] as Map<String, dynamic>),
    right: j['r'] == null
        ? null
        : TreeNode.fromJson(j['r'] as Map<String, dynamic>),
  );
}

/// Árbol binario. Puede venir de insertar números (búsqueda) o de una
/// reconstrucción (forma general).
class BinaryTree {
  TreeNode? root;
  BinaryTree([this.root]);

  static BinaryTree fromValues(List<int> values) {
    final t = BinaryTree();
    for (final v in values) {
      t.insert(v);
    }
    return t;
  }

  int get size {
    int count(TreeNode? n) => n == null ? 0 : 1 + count(n.left) + count(n.right);
    return count(root);
  }

  /// Cantidad de niveles (0 si está vacío).
  int get height {
    int h(TreeNode? n) => n == null ? 0 : 1 + max(h(n.left), h(n.right));
    return h(root);
  }

  bool contains(int v) {
    bool go(TreeNode? n) =>
        n != null && (n.value == v || go(n.left) || go(n.right));
    return go(root);
  }

  /// Inserción de búsqueda: menores a la izquierda, mayores a la derecha.
  /// false si el valor ya existía.
  bool insert(int v) {
    if (root == null) {
      root = TreeNode(v);
      return true;
    }
    var cur = root!;
    while (true) {
      if (v == cur.value) return false;
      if (v < cur.value) {
        if (cur.left == null) {
          cur.left = TreeNode(v);
          return true;
        }
        cur = cur.left!;
      } else {
        if (cur.right == null) {
          cur.right = TreeNode(v);
          return true;
        }
        cur = cur.right!;
      }
    }
  }

  List<int> preOrder() {
    final out = <int>[];
    void go(TreeNode? n) {
      if (n == null) return;
      out.add(n.value);
      go(n.left);
      go(n.right);
    }

    go(root);
    return out;
  }

  List<int> inOrder() {
    final out = <int>[];
    void go(TreeNode? n) {
      if (n == null) return;
      go(n.left);
      out.add(n.value);
      go(n.right);
    }

    go(root);
    return out;
  }

  List<int> postOrder() {
    final out = <int>[];
    void go(TreeNode? n) {
      if (n == null) return;
      go(n.left);
      go(n.right);
      out.add(n.value);
    }

    go(root);
    return out;
  }

  List<int> traversal(TraversalType t) => switch (t) {
    TraversalType.inOrder => inOrder(),
    TraversalType.preOrder => preOrder(),
    TraversalType.postOrder => postOrder(),
  };

  /// Columna = orden in-order (así nunca se encima nada), fila = profundidad.
  Map<int, ({int col, int row})> layout() {
    final result = <int, ({int col, int row})>{};
    var col = 0;
    void go(TreeNode? n, int row) {
      if (n == null) return;
      go(n.left, row + 1);
      result[n.value] = (col: col++, row: row);
      go(n.right, row + 1);
    }

    go(root, 0);
    return result;
  }

  /// Posiciones del lienzo (coordenadas del "mundo") con la distribución automática.
  Map<int, Offset> autoPositions({double colW = 64, double rowH = 92}) => {
    for (final e in layout().entries)
      e.key: Offset(e.value.col * colW, e.value.row * rowH),
  };

  Map<String, dynamic> toJson() => {'root': root?.toJson()};

  factory BinaryTree.fromJson(Map<String, dynamic> j) => BinaryTree(
    j['root'] == null
        ? null
        : TreeNode.fromJson(j['root'] as Map<String, dynamic>),
  );
}

// ---------------------------------------------------------------- Recorridos

enum StepKind { arrive, visit, back }

/// Un paso del mono: llegar a un nodo, visitarlo (anotarlo) o volver a él.
class TraversalStep {
  final int node;
  final StepKind kind;

  /// Nodo desde el que viene el mono (para pintar la arista recorrida).
  final int? from;
  final String note;

  const TraversalStep({
    required this.node,
    required this.kind,
    required this.note,
    this.from,
  });

  Map<String, dynamic> toJson() => {
    'node': node,
    'kind': kind.name,
    'from': from,
    'note': note,
  };

  factory TraversalStep.fromJson(Map<String, dynamic> j) => TraversalStep(
    node: j['node'] as int,
    kind: StepKind.values.byName(j['kind'] as String),
    from: j['from'] as int?,
    note: j['note'] as String,
  );
}

class TraversalResult {
  final TraversalType type;
  final List<TraversalStep> steps;

  /// Valores en el orden en que fueron visitados.
  final List<int> order;

  const TraversalResult({
    required this.type,
    required this.steps,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'order': order,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory TraversalResult.fromJson(Map<String, dynamic> j) => TraversalResult(
    type: TraversalType.values.byName(j['type'] as String),
    order: (j['order'] as List).map((e) => (e as num).toInt()).toList(),
    steps: (j['steps'] as List)
        .map((e) => TraversalStep.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// Recorre el árbol y registra cada paso. No sabe nada de la animación.
class TreeTraversalAlgorithm {
  static TraversalResult run(BinaryTree tree, TraversalType type) {
    final steps = <TraversalStep>[];
    final order = <int>[];
    if (tree.root != null) {
      _walk(tree.root!, type, null, '', steps, order);
    }
    return TraversalResult(type: type, steps: steps, order: order);
  }

  static void _walk(
    TreeNode n,
    TraversalType type,
    int? from,
    String via,
    List<TraversalStep> steps,
    List<int> order,
  ) {
    void visit() {
      order.add(n.value);
      steps.add(TraversalStep(
        node: n.value,
        kind: StepKind.visit,
        note: 'Visita ${n.value}: lo anota en el recorrido.',
      ));
    }

    steps.add(TraversalStep(
      node: n.value,
      kind: StepKind.arrive,
      from: from,
      note: from == null
          ? 'Empieza en la raíz ${n.value}.'
          : 'Baja $via hacia ${n.value}.',
    ));

    if (type == TraversalType.preOrder) visit();

    if (n.left != null) {
      _walk(n.left!, type, n.value, 'a la izquierda', steps, order);
      steps.add(TraversalStep(
        node: n.value,
        kind: StepKind.back,
        from: n.left!.value,
        note: 'Terminó la izquierda de ${n.value}: sube a ${n.value}.',
      ));
    }

    if (type == TraversalType.inOrder) visit();

    if (n.right != null) {
      _walk(n.right!, type, n.value, 'a la derecha', steps, order);
      steps.add(TraversalStep(
        node: n.value,
        kind: StepKind.back,
        from: n.right!.value,
        note: 'Terminó la derecha de ${n.value}: sube a ${n.value}.',
      ));
    }

    if (type == TraversalType.postOrder) visit();
  }
}