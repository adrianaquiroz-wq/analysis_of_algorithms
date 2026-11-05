import 'dart:ui' show Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_model.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_reconstructor.dart';
import 'package:graph_app/algorithms/binary_trees/logic/tree_traversal_controller.dart';
import 'package:graph_app/algorithms/binary_trees/storage/saved_tree.dart';

void main() {
  final sample = BinaryTree.fromValues([8, 3, 10, 1, 6, 14, 4, 7, 13]);

  group('recorridos', () {
    test('árbol de las capturas (8, 3, 10, 1, 6, 14, 4, 7, 13)', () {
      expect(sample.preOrder(), [8, 3, 1, 6, 4, 7, 10, 14, 13]);
      expect(sample.inOrder(), [1, 3, 4, 6, 7, 8, 10, 13, 14]);
      expect(sample.postOrder(), [1, 4, 7, 6, 3, 13, 14, 10, 8]);
    });

    test('ejemplo del manual: 8, 3, 10', () {
      final t = BinaryTree.fromValues([8, 3, 10]);
      expect(t.preOrder(), [8, 3, 10]);
      expect(t.inOrder(), [3, 8, 10]);
      expect(t.postOrder(), [3, 10, 8]);
    });

    test('pasos: n llegadas, n visitas y n-1 regresos', () {
      for (final type in TraversalType.values) {
        final steps = TreeTraversalAlgorithm.run(sample, type).steps;
        expect(steps.where((s) => s.kind == StepKind.arrive).length, 9);
        expect(steps.where((s) => s.kind == StepKind.visit).length, 9);
        expect(steps.where((s) => s.kind == StepKind.back).length, 8);
        expect(steps.first.node, 8);
      }
    });

    test('árbol vacío y un solo nodo', () {
      expect(TreeTraversalAlgorithm.run(BinaryTree(), TraversalType.inOrder).steps, isEmpty);
      for (final t in TraversalType.values) {
        expect(BinaryTree.fromValues([42]).traversal(t), [42]);
      }
    });

    test('no acepta repetidos; admite negativos', () {
      final t = BinaryTree.fromValues([5, -3]);
      expect(t.insert(5), isFalse);
      expect(t.inOrder(), [-3, 5]);
    });
  });

  group('lectura de números', () {
    test('acepta comas, espacios y negativos', () {
      final r = TreeInput.parse('8, 3  -10;1');
      expect(r.error, isNull);
      expect(r.values, [8, 3, -10, 1]);
    });

    test('rechaza texto, vacío y fuera de rango', () {
      expect(TreeInput.parse('').error, isNotNull);
      expect(TreeInput.parse('a, 2').error, isNotNull);
      expect(TreeInput.parse('5-3').error, isNotNull);
      expect(TreeInput.parse('1000000000').error, isNotNull);
    });
  });

  group('reconstrucción', () {
    test('In-order + Pre-order (ejemplo del manual)', () {
      final r = TreeReconstructor.run(
        ReconstructPair.inPre,
        [3, 8, 10],
        [8, 3, 10],
      );
      expect(r.tree.root!.value, 8);
      expect(r.tree.root!.left!.value, 3);
      expect(r.tree.root!.right!.value, 10);
      expect(r.ambiguous, isFalse);
    });

    test('las 4 parejas con In-order recuperan el árbol exacto', () {
      final pre = sample.preOrder(), inn = sample.inOrder(), post = sample.postOrder();
      final cases = {
        ReconstructPair.preIn: [pre, inn],
        ReconstructPair.inPre: [inn, pre],
        ReconstructPair.postIn: [post, inn],
        ReconstructPair.inPost: [inn, post],
      };
      for (final e in cases.entries) {
        final r = TreeReconstructor.run(e.key, e.value[0], e.value[1]);
        expect(r.tree.toJson(), sample.toJson(), reason: e.key.label);
        expect(r.ambiguous, isFalse);
      }
    });

    test('Pre + Post sin hijos únicos es exacto', () {
      final r = TreeReconstructor.run(
        ReconstructPair.prePost,
        [8, 3, 10],
        [3, 10, 8],
      );
      expect(r.ambiguous, isFalse);
      expect(r.tree.inOrder(), [3, 8, 10]);
    });

    test('Pre + Post con hijo único es ambiguo y mantiene los recorridos', () {
      final r = TreeReconstructor.run(
        ReconstructPair.prePost,
        sample.preOrder(),
        sample.postOrder(),
      );
      expect(r.ambiguous, isTrue);
      expect(r.tree.preOrder(), sample.preOrder());
      expect(r.tree.postOrder(), sample.postOrder());

      final two = TreeReconstructor.run(ReconstructPair.postPre, [2, 1], [1, 2]);
      expect(two.ambiguous, isTrue);
      expect(two.tree.root!.value, 1);
      expect(two.tree.root!.left!.value, 2);
    });

    test('errores: cantidad, valores, repetidos e incompatibles', () {
      void fails(ReconstructPair p, List<int> a, List<int> b) {
        expect(
          () => TreeReconstructor.run(p, a, b),
          throwsA(isA<ReconstructException>()),
        );
      }

      fails(ReconstructPair.preIn, [1, 2, 3], [1, 2]);
      fails(ReconstructPair.preIn, [1, 2, 3], [3, 1, 4]);
      fails(ReconstructPair.preIn, [1, 1], [1, 1]);
      fails(ReconstructPair.preIn, [1, 2, 3], [3, 1, 2]);
      fails(ReconstructPair.prePost, [1, 2, 3], [1, 2, 3]);
      fails(ReconstructPair.preIn, [], []);
    });
  });

  group('guardado', () {
    test('SavedTree conserva forma, posiciones, paso y procedimiento', () {
      final saved = SavedTree(
        id: '1',
        name: 'prueba',
        updatedAt: DateTime(2026, 11, 4),
        origin: 'Árbol reconstruido · In-order + Pre-order',
        tree: sample,
        positions: {
          for (final v in sample.preOrder()) v: Offset(v * 10.0, v * 5.5),
        },
        type: TraversalType.preOrder,
        cursor: 5,
        ambiguity: 'aviso',
        results: {
          for (final t in TraversalType.values)
            t: TreeTraversalAlgorithm.run(sample, t),
        },
      );

      final copy = SavedTree.fromJson(saved.toJson());

      expect(copy.name, 'prueba');
      expect(copy.origin, saved.origin);
      expect(copy.tree.toJson(), sample.toJson());
      expect(copy.positions[8], const Offset(80, 44));
      expect(copy.type, TraversalType.preOrder);
      expect(copy.cursor, 5);
      expect(copy.ambiguity, 'aviso');
      for (final t in TraversalType.values) {
        expect(copy.results[t]!.order, saved.results[t]!.order);
        expect(copy.results[t]!.steps.length, saved.results[t]!.steps.length);
      }
    });
  });

  group('controlador', () {
    test('createFromText crea el árbol y valida', () {
      final c = TreeTraversalController();
      expect(c.createFromText('8, 3, 10'), isNull);
      expect(c.tree.preOrder(), [8, 3, 10]);
      expect(c.monkeyNode, 8);
      expect(c.positions.length, 3);

      expect(c.createFromText('1, 2, 2'), isNotNull); // repetido
      expect(c.createFromText('abc'), isNotNull);
      expect(c.tree.preOrder(), [8, 3, 10]); // conserva el anterior
      c.dispose();
    });

    test('máximo 63 nodos', () {
      final c = TreeTraversalController();
      expect(c.createFromText(List.generate(64, (i) => i).join(',')), isNotNull);
      expect(c.createFromText(List.generate(63, (i) => i).join(',')), isNull);
      expect(c.tree.size, 63);
      c.dispose();
    });

    test('generateRandom respeta cantidad y valida el rango', () {
      final c = TreeTraversalController();
      expect(c.generateRandom(1, 100, 9), isNull);
      expect(c.tree.size, 9);
      expect(c.generateRandom(1, 5, 10), isNotNull);
      expect(c.generateRandom(10, 1, 3), isNotNull);
      expect(c.generateRandom(null, 5, 3), isNotNull);
      expect(c.tree.size, 9);
      c.dispose();
    });

    test('reconstructFromText conserva el árbol anterior si falla', () {
      final c = TreeTraversalController();
      c.createFromText('8, 3, 10');
      expect(
        c.reconstructFromText(ReconstructPair.preIn, '1, 2, 3', '3, 1, 2'),
        isNotNull,
      );
      expect(c.tree.preOrder(), [8, 3, 10]);

      expect(
        c.reconstructFromText(ReconstructPair.inPre, '3, 8, 10', '8, 3, 10'),
        isNull,
      );
      expect(c.origin, contains('reconstruido'));
      c.dispose();
    });

    test('Pre + Post ambiguo deja un aviso', () {
      final c = TreeTraversalController();
      expect(c.reconstructFromText(ReconstructPair.prePost, '1, 2', '2, 1'), isNull);
      expect(c.ambiguity, isNotNull);
      c.createFromText('1, 2');
      expect(c.ambiguity, isNull);
      c.dispose();
    });

    test('moveNode y autoArrange', () {
      final c = TreeTraversalController();
      c.createFromText('8, 3, 10');
      final original = c.positions[3]!;
      c.moveNode(3, const Offset(500, 500));
      expect(c.positions[3], const Offset(500, 500));
      c.autoArrange();
      expect(c.positions[3], original);
      c.dispose();
    });

    test('stepForward avanza hasta terminar', () {
      final c = TreeTraversalController();
      c.createFromText('2, 1, 3');
      c.setType(TraversalType.preOrder);
      final total =
          TreeTraversalAlgorithm.run(c.tree, TraversalType.preOrder).steps.length;
      for (var i = 0; i < total; i++) {
        c.stepForward();
      }
      expect(c.state, PlayState.done);
      expect(c.output, [2, 1, 3]);
      c.dispose();
    });

    test('loadSaved restaura forma, posiciones y paso exacto', () {
      final saved = SavedTree(
        id: '1',
        name: 'x',
        updatedAt: DateTime(2026, 11, 4),
        origin: 'Árbol de búsqueda · Inserción por teclado',
        tree: sample,
        positions: {for (final v in sample.preOrder()) v: Offset(v * 3.0, 7)},
        type: TraversalType.preOrder,
        cursor: 3, // llegó a 8, visitó 8, bajó a 3
        results: {
          for (final t in TraversalType.values)
            t: TreeTraversalAlgorithm.run(sample, t),
        },
      );

      final c = TreeTraversalController();
      c.loadSaved(saved);

      expect(c.tree.toJson(), sample.toJson());
      expect(c.positions[10], const Offset(30, 7));
      expect(c.type, TraversalType.preOrder);
      expect(c.cursor, 3);
      expect(c.state, PlayState.paused);
      expect(c.output, [8]);
      expect(c.trail, [8, 3]);
      expect(c.monkeyNode, 3);
      c.dispose();
    });
  });
}