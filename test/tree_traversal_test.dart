import 'package:flutter_test/flutter_test.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_traversal_controller.dart';
import 'package:graph_app/algorithms/binary_trees/storage/saved_tree.dart';

BinaryTree _build(List<int> values) {
  final tree = BinaryTree();
  for (final v in values) {
    tree.insert(v);
  }
  return tree;
}

List<int> _order(BinaryTree tree, TraversalType type) =>
    TreeTraversalAlgorithm.run(tree, type).order;

void main() {
  group('árbol balanceado [50,30,70,20,40,60,80]', () {
    final tree = _build([50, 30, 70, 20, 40, 60, 80]);

    test('in-order da los valores ordenados', () {
      expect(_order(tree, TraversalType.inOrder), [20, 30, 40, 50, 60, 70, 80]);
    });

    test('pre-order', () {
      expect(_order(tree, TraversalType.preOrder), [50, 30, 20, 40, 70, 60, 80]);
    });

    test('post-order', () {
      expect(_order(tree, TraversalType.postOrder), [20, 40, 30, 60, 80, 70, 50]);
    });

    test('cada recorrido registra n llegadas, n visitas y n-1 regresos', () {
      for (final type in TraversalType.values) {
        final steps = TreeTraversalAlgorithm.run(tree, type).steps;
        expect(steps.where((s) => s.kind == StepKind.arrive).length, 7);
        expect(steps.where((s) => s.kind == StepKind.visit).length, 7);
        expect(steps.where((s) => s.kind == StepKind.back).length, 6);
        expect(steps.first.kind, StepKind.arrive);
        expect(steps.first.node, 50);
      }
    });
  });

  group('árbol desbalanceado [10,5,15,3,7]', () {
    final tree = _build([10, 5, 15, 3, 7]);

    test('in-order', () {
      expect(_order(tree, TraversalType.inOrder), [3, 5, 7, 10, 15]);
    });

    test('pre-order', () {
      expect(_order(tree, TraversalType.preOrder), [10, 5, 3, 7, 15]);
    });

    test('post-order', () {
      expect(_order(tree, TraversalType.postOrder), [3, 7, 5, 15, 10]);
    });
  });

  group('casos borde', () {
    test('árbol vacío no genera pasos', () {
      final r = TreeTraversalAlgorithm.run(BinaryTree(), TraversalType.inOrder);
      expect(r.order, isEmpty);
      expect(r.steps, isEmpty);
    });

    test('un solo nodo', () {
      final tree = _build([42]);
      for (final type in TraversalType.values) {
        expect(_order(tree, type), [42]);
      }
    });

    test('no acepta valores repetidos', () {
      final tree = _build([5, 3]);
      expect(tree.insert(3), isFalse);
      expect(tree.size, 2);
    });

    test('altura y camino de inserción', () {
      final tree = _build([50, 30, 70, 20]);
      expect(tree.height, 3);
      expect(tree.insertPath(25), [50, 30, 20]);
    });

    test('el layout ordena las columnas como in-order', () {
      final layout = _build([50, 30, 70]).layout();
      expect(layout[30]!.col, 0);
      expect(layout[50]!.col, 1);
      expect(layout[70]!.col, 2);
      expect(layout[50]!.row, 0);
      expect(layout[30]!.row, 1);
    });
  });

  group('guardado', () {
    test('SavedTree conserva valores, recorrido, paso y procedimiento', () {
      final tree = _build([50, 30, 70, 20, 40, 60, 80]);
      final saved = SavedTree(
        id: '1',
        name: 'prueba',
        updatedAt: DateTime(2026, 10, 25),
        values: [50, 30, 70, 20, 40, 60, 80],
        type: TraversalType.preOrder,
        cursor: 5,
        results: {
          for (final t in TraversalType.values)
            t: TreeTraversalAlgorithm.run(tree, t),
        },
      );

      final copy = SavedTree.fromJson(saved.toJson());

      expect(copy.name, 'prueba');
      expect(copy.values, saved.values);
      expect(copy.type, TraversalType.preOrder);
      expect(copy.cursor, 5);
      for (final t in TraversalType.values) {
        expect(copy.results[t]!.order, saved.results[t]!.order);
        expect(copy.results[t]!.steps.length, saved.results[t]!.steps.length);
        expect(copy.results[t]!.steps.first.note, saved.results[t]!.steps.first.note);
      }
    });
  });

  group('controlador', () {
    test('setValues arma el árbol y descarta repetidos', () {
      final c = TreeTraversalController();
      c.setValues([50, 30, 50, 70]);
      expect(c.values, [50, 30, 70]);
      expect(c.tree.size, 3);
      expect(c.monkeyNode, 50);
      c.dispose();
    });

    test('addValue rechaza repetidos y valores fuera de rango', () async {
      final c = TreeTraversalController();
      c.setValues([50]);
      expect(await c.addValue(50), isNotNull);
      expect(await c.addValue(0), isNotNull);
      expect(await c.addValue(1000), isNotNull);
      expect(c.values, [50]);
      c.dispose();
    });

    test('stepForward avanza paso a paso hasta terminar', () {
      final c = TreeTraversalController();
      c.setValues([2, 1, 3]);
      c.setType(TraversalType.preOrder);

      final total = TreeTraversalAlgorithm.run(c.tree, TraversalType.preOrder)
          .steps
          .length;
      for (var i = 0; i < total; i++) {
        c.stepForward();
      }

      expect(c.state, PlayState.done);
      expect(c.output, [2, 1, 3]);
      c.dispose();
    });

    test('loadSaved restaura el paso exacto en que se guardó', () {
      final tree = _build([50, 30, 70, 20, 40, 60, 80]);
      final saved = SavedTree(
        id: '1',
        name: 'x',
        updatedAt: DateTime(2026, 10, 25),
        values: [50, 30, 70, 20, 40, 60, 80],
        type: TraversalType.preOrder,
        cursor: 3, // llegó a 50, visitó 50, bajó a 30
        results: {
          for (final t in TraversalType.values)
            t: TreeTraversalAlgorithm.run(tree, t),
        },
      );

      final c = TreeTraversalController();
      c.loadSaved(saved);

      expect(c.type, TraversalType.preOrder);
      expect(c.cursor, 3);
      expect(c.state, PlayState.paused);
      expect(c.output, [50]);
      expect(c.trail, [50, 30]);
      expect(c.monkeyNode, 30);
      c.dispose();
    });
  });
}