import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

/// Ayuda de Merge Sort. Las secciones generales hablan de pingüinos
/// (Shell Sort), así que aquí van las equivalentes con patitos.
final List<SortingHelpSection> mergeSortHelp = [
  const SortingHelpSection(
    title: '¿Qué hace Merge Sort?',
    icon: Icons.info_outline_rounded,
    items: [
      'Es un algoritmo de divide y vencerás: parte la lista por la mitad una y otra vez hasta que cada grupo tiene un solo número (que ya está ordenado).',
      'Después fusiona los grupos de dos en dos, comparando sus primeros elementos, hasta reconstruir la lista completa en orden.',
      'Siempre hace log₂ n niveles de división y en cada nivel recorre los n elementos: su costo es O(n log n) en el mejor y en el peor caso.',
      'Es estable (los empates conservan su orden original) y necesita memoria extra O(n).',
    ],
  ),
  const SortingHelpSection(
    title: 'Ingresar los datos',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribir números: sepáralos con coma o espacio. Se aceptan de 2 a 30 números enteros entre 1 y 100.',
      'Aleatorio: indica cuántos números quieres (de 2 a 30) y pulsa "Generar".',
      'Cada número se dibuja como un patito: mientras más grande el valor, más grande el patito.',
      'Los datos se pueden cambiar solo cuando no hay un ordenamiento en marcha.',
    ],
  ),
  const SortingHelpSection(
    title: 'Ascendente o descendente',
    icon: Icons.swap_vert_rounded,
    items: [
      'El selector de arriba a la derecha elige el orden final: de menor a mayor (ascendente) o de mayor a menor (descendente).',
      'Al cambiarlo, la animación vuelve al inicio.',
    ],
  ),
  const SortingHelpSection(
    title: 'Controles y velocidad',
    icon: Icons.speed_rounded,
    items: [
      'Empezar ordenamiento: reproduce de corrido cómo se dividen y se fusionan los patitos.',
      'Pausar / Continuar: detiene la animación y la retoma donde se quedó.',
      'Reiniciar: devuelve los patitos a su posición original.',
      'Velocidad: de 0.25x (muy lento) a 4x (rápido). Se puede cambiar en cualquier momento y se aplica en el siguiente movimiento.',
    ],
  ),
  const SortingHelpSection(
    title: 'Cómo leer la animación',
    icon: Icons.visibility_rounded,
    items: [
      'Cada fila del estanque es un nivel de la recursión: arriba la lista completa, abajo los grupos cada vez más chicos.',
      'Dividir: los patitos de un grupo nadan hacia la fila de abajo y se separan en dos mitades. La corriente luminosa une el grupo con sus dos mitades.',
      'Comparar: los dos patitos que se comparan se levantan un poco del agua y brillan en amarillo; su sombra se achica.',
      'Fusionar: el que gana la comparación nada hacia arriba, entra a su lugar con un pequeño rebote y suelta un destello de gotas y chispas.',
      'Cuando una mitad se queda sin patitos, los que sobran de la otra pasan directo, sin comparar.',
      'Las ondas en el agua solo acompañan el movimiento; no significan nada del algoritmo.',
    ],
  ),
  const SortingHelpSection(
    title: 'Tiempo y operaciones',
    icon: Icons.timer_outlined,
    items: [
      'Tiempo de ejecución: lo que tarda el algoritmo en ordenar, medido sin contar la animación. Es un promedio de varias corridas.',
      'Comparaciones: cuántas veces se comparó el primer patito de cada mitad.',
      'Peor caso de comparaciones: n·⌈log₂ n⌉ − 2^⌈log₂ n⌉ + 1. Verde si tu conjunto quedó dentro de esa cota.',
      'Movimientos de patitos: cuántas veces un patito entró a su posición fusionada (incluye los que pasan directo).',
    ],
  ),
  const SortingHelpSection(
    title: 'Menú de hamburguesa',
    icon: Icons.menu_rounded,
    items: [
      'Modo Oscuro: cambia el tema de toda la app.',
      'Nuevos Datos: carga una lista de ejemplo y deja todo como al inicio.',
      'Guardar Datos: guarda con un nombre los números que tienes y su orden (ascendente o descendente).',
      'Datos Guardados: abre una lista guardada o la elimina.',
      'Ayuda: esta pantalla.',
      'Volver al Inicio: regresa a la pantalla principal.',
    ],
  ),
];
