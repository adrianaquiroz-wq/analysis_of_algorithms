import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';

/// Las 6 parejas de recorridos que permite el editor.
enum ReconstructPair { inPre, inPost, preIn, postIn, prePost, postPre }

extension ReconstructPairX on ReconstructPair {
  /// Tipo de la primera lista que escribe el usuario.
  TraversalType get first => switch (this) {
    ReconstructPair.inPre || ReconstructPair.inPost => TraversalType.inOrder,
    ReconstructPair.preIn || ReconstructPair.prePost => TraversalType.preOrder,
    ReconstructPair.postIn || ReconstructPair.postPre => TraversalType.postOrder,
  };

  /// Tipo de la segunda lista.
  TraversalType get second => switch (this) {
    ReconstructPair.preIn || ReconstructPair.postIn => TraversalType.inOrder,
    ReconstructPair.inPre || ReconstructPair.postPre => TraversalType.preOrder,
    ReconstructPair.inPost || ReconstructPair.prePost => TraversalType.postOrder,
  };

  String get label => '${first.label} + ${second.label}';
}

class ReconstructException implements Exception {
  final String message;
  const ReconstructException(this.message);
  @override
  String toString() => message;
}

class ReconstructResult {
  final BinaryTree tree;

  /// true si Pre + Post admitía más de un árbol (algún nodo con un solo hijo).
  final bool ambiguous;
  const ReconstructResult(this.tree, this.ambiguous);
}

/// Reconstruye un árbol binario a partir de dos recorridos.
///  - In-order + Pre-order o Post-order: árbol único.
///  - Pre-order + Post-order: puede haber varios; se elige uno con el hijo
///    único a la izquierda y se avisa.
/// Al final se recalculan los recorridos y se comparan con los escritos, así
/// que cualquier pareja incompatible se detecta.
class TreeReconstructor {
  static ReconstructResult run(ReconstructPair pair, List<int> a, List<int> b) {
    if (a.isEmpty || b.isEmpty) {
      throw const ReconstructException('Escribe los dos recorridos.');
    }
    if (a.length != b.length) {
      throw ReconstructException(
        'Los dos recorridos deben tener la misma cantidad de valores (${a.length} y ${b.length}).',
      );
    }
    if (a.length > TreeInput.maxNodes) {
      throw const ReconstructException('Máximo ${TreeInput.maxNodes} nodos.');
    }
    if (a.toSet().length != a.length || b.toSet().length != b.length) {
      throw const ReconstructException(
        'Los valores no deben repetirse dentro de un recorrido.',
      );
    }
    if (!a.toSet().containsAll(b)) {
      throw const ReconstructException(
        'Los dos recorridos deben contener los mismos valores.',
      );
    }

    final byType = {pair.first: a, pair.second: b};
    final pre = byType[TraversalType.preOrder];
    final inn = byType[TraversalType.inOrder];
    final post = byType[TraversalType.postOrder];
    final n = a.length;
    final amb = [false];

    TreeNode? root;
    if (pre != null && inn != null) {
      root = _preIn(pre, inn, _index(inn), 0, n - 1, 0, n - 1);
    } else if (post != null && inn != null) {
      root = _postIn(post, inn, _index(inn), 0, n - 1, 0, n - 1);
    } else {
      root = _prePost(pre!, post!, _index(post), 0, n - 1, 0, n - 1, amb);
    }

    final tree = BinaryTree(root);
    if ((pre != null && !_same(tree.preOrder(), pre)) ||
        (inn != null && !_same(tree.inOrder(), inn)) ||
        (post != null && !_same(tree.postOrder(), post))) {
      throw _bad();
    }
    return ReconstructResult(tree, amb[0]);
  }

  static ReconstructException _bad() => const ReconstructException(
    'Los recorridos no son compatibles: ningún árbol puede producir ambos.',
  );

  static Map<int, int> _index(List<int> l) => {
    for (var i = 0; i < l.length; i++) l[i]: i,
  };

  static bool _same(List<int> x, List<int> y) {
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }

  static TreeNode? _preIn(List<int> pre, List<int> inn, Map<int, int> inIdx,
      int pl, int pr, int il, int ir) {
    if (pl > pr) return null;
    final rootV = pre[pl];
    final k = inIdx[rootV];
    if (k == null || k < il || k > ir) throw _bad();
    final leftSize = k - il;
    return TreeNode(
      rootV,
      left: _preIn(pre, inn, inIdx, pl + 1, pl + leftSize, il, k - 1),
      right: _preIn(pre, inn, inIdx, pl + leftSize + 1, pr, k + 1, ir),
    );
  }

  static TreeNode? _postIn(List<int> post, List<int> inn, Map<int, int> inIdx,
      int pl, int pr, int il, int ir) {
    if (pl > pr) return null;
    final rootV = post[pr];
    final k = inIdx[rootV];
    if (k == null || k < il || k > ir) throw _bad();
    final leftSize = k - il;
    return TreeNode(
      rootV,
      left: _postIn(post, inn, inIdx, pl, pl + leftSize - 1, il, k - 1),
      right: _postIn(post, inn, inIdx, pl + leftSize, pr - 1, k + 1, ir),
    );
  }

  static TreeNode? _prePost(List<int> pre, List<int> post,
      Map<int, int> postIdx, int pl, int pr, int ql, int qr, List<bool> amb) {
    if (pl > pr) return null;
    final rootV = pre[pl];
    if (post[qr] != rootV) throw _bad();
    if (pl == pr) return TreeNode(rootV);

    final leftRoot = pre[pl + 1];
    final idx = postIdx[leftRoot];
    if (idx == null || idx < ql || idx > qr - 1) throw _bad();
    final leftSize = idx - ql + 1;

    if (leftSize == pr - pl) {
      // Un solo hijo: podría ser el izquierdo o el derecho. Se elige el izquierdo.
      amb[0] = true;
      return TreeNode(
        rootV,
        left: _prePost(pre, post, postIdx, pl + 1, pr, ql, qr - 1, amb),
      );
    }
    return TreeNode(
      rootV,
      left: _prePost(pre, post, postIdx, pl + 1, pl + leftSize, ql, idx, amb),
      right: _prePost(pre, post, postIdx, pl + leftSize + 1, pr, idx + 1, qr - 1, amb),
    );
  }
}