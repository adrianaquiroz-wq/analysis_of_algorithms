import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

/// Ayuda de Selection Sort, con la historia de la carrera de ranas.
final List<SortingHelpSection> selectionSortHelp = [
  const SortingHelpSection(
    title: '¿Qué hace Selection Sort?',
    icon: Icons.info_outline_rounded,
    items: [
      'Busca el menor elemento de la parte que todavía no está ordenada y lo intercambia con el primero de esa parte.',
      'Después avanza la frontera un puesto y repite, hasta que toda la fila queda en orden.',
      'Siempre hace n(n−1)/2 comparaciones (O(n²)), pero a lo sumo n−1 intercambios. Usa O(1) de memoria extra y no es estable.',
    ],
  ),
  const SortingHelpSection(
    title: 'Ingresar los datos',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribir números: sepáralos con coma o espacio. Se aceptan de 2 a 30 números enteros entre 1 y 100.',
      'Aleatorio: indica cuántos números quieres (de 2 a 30) y pulsa "Generar".',
      'Cada número es una rana: mientras más grande el valor, más grande la rana.',
      'Los datos se pueden cambiar solo cuando no hay un ordenamiento en marcha.',
    ],
  ),
  const SortingHelpSection(
    title: 'Cómo leer la animación',
    icon: Icons.visibility_rounded,
    items: [
      'La pista tiene un puesto numerado para cada rana. La zona dorada es la parte ya ordenada y la banderita marca hasta dónde llega.',
      'El búho juez recorre la fila de ranas que falta ordenar. Su lupa ilumina a la rana que está comparando (brilla en ámbar).',
      'La rana que brilla en verde y lleva la etiqueta "mín" es la candidata a ser la menor encontrada hasta el momento.',
      'Cuando el búho termina de recorrer, la rana candidata da un gran salto hasta el primer puesto sin ordenar y se intercambia con la que estaba ahí.',
      'Las ranas con una estrellita dorada ya están en su puesto final y no se vuelven a mover.',
      'Si la candidata ya estaba en el primer puesto sin ordenar, no salta: simplemente se queda.',
    ],
  ),
  const SortingHelpSection(
    title: 'Ascendente o descendente',
    icon: Icons.swap_vert_rounded,
    items: [
      'El selector de arriba a la derecha elige el orden final. En ascendente el búho busca la rana menor; en descendente, la mayor.',
      'Al cambiarlo, la animación vuelve al inicio.',
    ],
  ),
  const SortingHelpSection(
    title: 'Controles y velocidad',
    icon: Icons.speed_rounded,
    items: [
      'Empezar: reproduce de corrido toda la carrera.',
      'Pausar / Continuar: detiene la animación y la retoma donde se quedó.',
      'Paso: avanza una sola acción (una mirada del búho o un salto).',
      'Reiniciar: devuelve las ranas a su posición original.',
      'Velocidad: de 0.25x (muy lento) a 4x (rápido).',
    ],
  ),
  const SortingHelpSection(
    title: 'Tiempo y operaciones',
    icon: Icons.timer_outlined,
    items: [
      'Tiempo de ejecución: lo que tarda el algoritmo en ordenar, sin contar la animación (promedio de varias corridas).',
      'Comparaciones: cuántas veces el búho comparó dos ranas. Siempre es n(n−1)/2.',
      'Saltos: cuántas veces una rana se intercambió de lugar. Nunca pasa de n−1.',
    ],
  ),
  const SortingHelpSection(
    title: 'Usarlo desde el lienzo de grafos',
    icon: Icons.account_tree_rounded,
    items: [
      'Desde el menú de un grafo se puede abrir Selection Sort con los pesos de las aristas. Cada rana lleva el peso y, debajo, la arista (origen → destino).',
      'Al terminar aparece "Aplicar orden al grafo": las aristas del grafo quedan ordenadas por peso.',
    ],
  ),
  const SortingHelpSection(
    title: 'Menú de hamburguesa',
    icon: Icons.menu_rounded,
    items: [
      'Modo Oscuro: cambia el tema de toda la app.',
      'Nuevos Datos: carga una lista de ejemplo y deja todo como al inicio.',
      'Guardar Datos: guarda con un nombre los números que tienes y su orden.',
      'Datos Guardados: abre una lista guardada o la elimina.',
      'Ayuda: esta pantalla.',
      'Volver al Inicio: regresa a la pantalla principal.',
    ],
  ),
];
