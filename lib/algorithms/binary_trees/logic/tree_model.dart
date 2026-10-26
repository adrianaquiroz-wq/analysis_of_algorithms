import 'dart:math';

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

class TreeNode {
  final int value;
  TreeNode? left;
  TreeNode? right;
  TreeNode(this.value);
}

/// Árbol binario de búsqueda (menores a la izquierda, mayores a la derecha).
class BinaryTree {
  TreeNode? root;

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
    var cur = root;
    while (cur != null) {
      if (v == cur.value) return true;
      cur = v < cur.value ? cur.left : cur.right;
    }
    return false;
  }

  /// Valores por los que pasa el mono desde la raíz hasta el padre del nuevo nodo.
  List<int> insertPath(int v) {
    final path = <int>[];
    var cur = root;
    while (cur != null) {
      path.add(cur.value);
      cur = v < cur.value ? cur.left : cur.right;
    }
    return path;
  }

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

  /// Posición de cada nodo: columna = orden in-order (así nunca se
  /// encimen), fila = profundidad.
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