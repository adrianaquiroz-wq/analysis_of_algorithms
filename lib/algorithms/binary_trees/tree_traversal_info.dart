import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/binary_trees/screens/tree_traversal_screen.dart';
import 'package:graph_app/algorithms/binary_trees/widgets/tree_traversal_preview.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

final SortingInfo treeTraversalInfo = SortingInfo(
  id: 'tree_traversal',
  title: 'Recorridos de un Árbol',
  subtitle: 'In-order, Pre-order y Post-order · O(n)',
  icon: Icons.account_tree_rounded,
  theory:
      'Un árbol binario es una estructura donde cada nodo tiene a lo sumo un '
      'hijo izquierdo y uno derecho. Recorrerlo es visitar cada nodo una sola '
      'vez, y lo que cambia entre los tres recorridos clásicos es el momento '
      'en que se "visita" la raíz de cada subárbol: antes de sus hijos '
      '(pre-order), entre ellos (in-order) o después (post-order). En un árbol '
      'binario de búsqueda, el recorrido in-order entrega los valores '
      'ordenados. Los tres recorren n nodos, así que su costo es O(n).',
  steps: [
    'Pre-order: se visita la raíz, luego el subárbol izquierdo y luego el derecho.',
    'In-order: se recorre el subárbol izquierdo, se visita la raíz y luego se recorre el derecho.',
    'Post-order: se recorre el subárbol izquierdo, luego el derecho y al final se visita la raíz.',
    'Cuando un nodo no tiene hijo en un lado, simplemente se omite ese lado.',
    'Complejidad: O(n) en tiempo; el espacio extra es O(h), donde h es la altura del árbol (por la recursión).',
  ],
  previewBuilder: (_) => const TreeTraversalPreview(),
  screenBuilder: (_) => const TreeTraversalScreen(),
);

