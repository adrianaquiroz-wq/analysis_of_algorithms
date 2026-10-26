import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

final List<SortingHelpSection> treeTraversalHelp = [
  const SortingHelpSection(
    title: '¿Qué hacen los recorridos?',
    icon: Icons.info_outline_rounded,
    items: [
      'Un recorrido visita todos los nodos del árbol exactamente una vez, en un orden distinto según el tipo.',
      'In-order: Izquierda → Raíz → Derecha. En un árbol de búsqueda entrega los valores ordenados de menor a mayor.',
      'Pre-order: Raíz → Izquierda → Derecha. Sirve para copiar el árbol.',
      'Post-order: Izquierda → Derecha → Raíz. Sirve para borrar el árbol (los hijos antes que el padre).',
      'Los tres cuestan O(n): cada nodo se visita una sola vez.',
    ],
  ),
  const SortingHelpSection(
    title: 'Construir el árbol',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribe uno o varios números separados por coma o espacio y pulsa "Plantar". Se aceptan enteros de 1 a 999, hasta 20 nodos.',
      'El árbol es de búsqueda: un número menor que el nodo va a su izquierda y uno mayor a su derecha. No se aceptan repetidos.',
      'El mono baja desde la raíz comparando en cada nodo hasta encontrar el lugar libre donde cuelga el nuevo coco.',
      '"Aleatorio" genera 7 números; "Limpiar" vacía el árbol.',
    ],
  ),
  const SortingHelpSection(
    title: 'Cómo leer la animación',
    icon: Icons.visibility_rounded,
    items: [
      'El mono recorre el árbol: baja a un hijo, y cuando termina esa rama sube de vuelta al padre.',
      'Las ramas por donde ya pasó se pintan en amarillo.',
      'Cuando el mono "visita" un nodo, abre la boca, el coco se vuelve banana y aparece su número de orden.',
      '"Camino del mono" lista todos los nodos por los que pasó (con los regresos). "Recorrido" lista solo los visitados, entre llaves.',
      'Botones: Soltar al mono / Pausar / Continuar, paso a paso, reiniciar y velocidad.',
    ],
  ),
  const SortingHelpSection(
    title: 'Menú de hamburguesa',
    icon: Icons.menu_rounded,
    items: [
      'Árbol Nuevo: vacía el árbol.',
      'Guardar Árbol: guarda con un nombre los valores, el recorrido elegido, el paso en que estás y el procedimiento de los tres recorridos.',
      'Árboles Guardados: abre un árbol guardado (queda exactamente como lo dejaste) o lo elimina.',
      'Ayuda y Volver al Inicio.',
    ],
  ),
];