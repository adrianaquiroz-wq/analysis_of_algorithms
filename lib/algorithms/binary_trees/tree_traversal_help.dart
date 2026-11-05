import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

final List<SortingHelpSection> treeTraversalHelp = [
  const SortingHelpSection(
    title: 'Crear por teclado',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribe enteros separados por comas o espacios y pulsa "Crear árbol".',
      'La primera cifra es la raíz; los menores van a la izquierda y los mayores a la derecha.',
      'Cada valor debe ser único. Cambiar el orden de inserción puede cambiar la forma del árbol.',
      'Se admiten hasta 63 nodos y valores entre -999999999 y 999999999.',
      '"Probar ejemplo listo" crea el árbol 8, 3, 10, 1, 6, 14, 4, 7, 13.',
    ],
  ),
  const SortingHelpSection(
    title: 'Aleatorios por rango',
    icon: Icons.shuffle_rounded,
    items: [
      'Indica mínimo, máximo y cantidad. Se incluyen ambos extremos.',
      'El rango debe tener al menos tantos valores diferentes como nodos pidas.',
    ],
  ),
  const SortingHelpSection(
    title: 'Los tres recorridos',
    icon: Icons.info_outline_rounded,
    items: [
      'Pre-order: Raíz → Izquierda → Derecha.',
      'In-order: Izquierda → Raíz → Derecha. En un árbol de búsqueda sale ordenado; en un árbol reconstruido no tiene por qué.',
      'Post-order: Izquierda → Derecha → Raíz.',
      'Los tres se muestran siempre debajo, y se actualizan al cambiar el árbol.',
    ],
  ),
  const SortingHelpSection(
    title: 'Reconstruir con dos recorridos',
    icon: Icons.build_circle_outlined,
    items: [
      'Elige una pareja (por ejemplo In-order + Pre-order) y escribe las dos listas.',
      'Deben tener la misma cantidad de valores, los mismos valores sin repetir y un orden compatible.',
      'Si no coinciden aparece un error y se conserva el árbol anterior.',
      'In-order con Pre-order o Post-order da un árbol único. Pre-order con Post-order puede tener varias soluciones cuando hay un hijo único: se muestra una válida con ese hijo a la izquierda y se avisa.',
      '"Usar recorridos del árbol actual" rellena las listas con los del árbol que tienes.',
    ],
  ),
  const SortingHelpSection(
    title: 'Recorrer con el mono',
    icon: Icons.pets_rounded,
    items: [
      'Elige In-order, Pre-order o Post-order y pulsa "Soltar al mono".',
      'El mono baja a un hijo y, cuando termina esa rama, sube de vuelta al padre. Las ramas recorridas se pintan en amarillo.',
      'Al visitar un nodo abre la boca, el coco se vuelve banana y aparece su número de orden.',
      '"Camino del mono" lista todos los nodos por los que pasó (con los regresos). "Recorrido" lista solo los visitados, entre llaves.',
      'Puedes pausar, avanzar paso a paso, reiniciar y cambiar la velocidad.',
    ],
  ),
  const SortingHelpSection(
    title: 'El lienzo',
    icon: Icons.open_with_rounded,
    items: [
      'Arrastra un nodo para ubicarlo sin cambiar las relaciones ni los recorridos.',
      'Arrastra el fondo para desplazar la vista; pellizca o usa la rueda para hacer zoom.',
      'La varita ordena los nodos automáticamente; el botón de enfoque ajusta el árbol a la vista.',
      '"Limpiar árbol" lo vacía.',
    ],
  ),
  const SortingHelpSection(
    title: 'Guardar y abrir',
    icon: Icons.save_rounded,
    items: [
      'Guardar: guarda con un nombre la forma exacta del árbol, la posición de cada nodo, cómo se creó, el recorrido elegido, el paso en que estás y el procedimiento de los tres recorridos.',
      'Abrir: lista los árboles guardados; al tocar uno queda exactamente como lo dejaste. La papelera lo elimina.',
      'Guarda antes de crear otro árbol o limpiar: esas acciones reemplazan el árbol actual.',
    ],
  ),
];