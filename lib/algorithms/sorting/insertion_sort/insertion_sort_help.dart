import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

/// Secciones de ayuda para Insertion Sort con temática de ositos panda.
final List<SortingHelpSection> insertionSortHelp = [
  const SortingHelpSection(
    title: '¿Qué hace Insertion Sort?',
    icon: Icons.info_outline_rounded,
    items: [
      'Funciona de manera muy similar a cómo la mayoría de personas ordenan una mano de cartas en un juego de naipes.',
      'Mantiene una porción izquierda de la lista ya ordenada y toma uno a uno los elementos restantes.',
      'Cada nuevo elemento se compara hacia atrás con los elementos ya ordenados, desplazando a la derecha a los que sean mayores (o menores, si es descendente), hasta encontrar su hueco correcto.',
      'Complejidad: O(n) en el mejor caso (si ya está ordenado), O(n²) en el caso promedio y peor caso. Requiere memoria extra O(1) y es un algoritmo estable.',
    ],
  ),
  const SortingHelpSection(
    title: 'Cómo leer la animación con Pandas',
    icon: Icons.visibility_rounded,
    items: [
      'Panda Clave que se eleva: En cada pasada i, el panda correspondiente sale de la fila y flota arriba con una pequeña hojita de bambú.',
      'Comparación con la izquierda: El panda clave se compara con su vecino izquierdo inmediato.',
      'Desplazamiento (Shift): Si el panda de la izquierda es mayor, este da un paso a la derecha. El panda clave vuela horizontalmente para acompañar el hueco.',
      'Inserción (Drop): Cuando encuentra a un panda menor o llega al inicio de la fila, el panda clave aterriza suavemente en el hueco libre.',
      'Zona verde de ordenados: El fondo verde sutil en la repisa delimita la frontera de pandas que ya están en orden definitivo.',
    ],
  ),
  const SortingHelpSection(
    title: 'Ingresar los datos',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribir números: Sepáralos por comas o espacios. Se aceptan valores enteros entre 1 y 100.',
      'Aleatorio: Ingresa la cantidad deseada (de 2 a 30) y presiona "Generar".',
      'Tamaño de los pandas: Mientras mayor sea el valor del número, más alto y robusto será el osito panda.',
      'Los datos se pueden modificar únicamente cuando la animación esté pausada o detenida.',
    ],
  ),
  const SortingHelpSection(
    title: 'Ascendente o descendente',
    icon: Icons.swap_vert_rounded,
    items: [
      'El selector en la esquina superior derecha alterna entre orden ascendente (menor a mayor) y descendente (mayor a menor).',
      'Al cambiar de dirección, la simulación se reinicia para ordenar con la nueva regla.',
    ],
  ),
  const SortingHelpSection(
    title: 'Controles y velocidad',
    icon: Icons.speed_rounded,
    items: [
      'Empezar: Inicia la reproducción automática de cada paso.',
      'Pausar / Continuar: Permite congelar la animación en cualquier punto y reanudarla.',
      'Reiniciar: Regresa a todos los pandas a su posición y estado inicial.',
      'Velocidad: Ajustable entre 0.25x (análisis lento paso a paso) y 4x (rápido).',
    ],
  ),
  const SortingHelpSection(
    title: 'Casos y Complejidad Teórica',
    icon: Icons.functions_rounded,
    items: [
      'Mejor caso O(n): Si la lista ya está ordenada, cada elemento solo hace 1 comparación (n - 1 en total) y 0 desplazamientos.',
      'Peor caso O(n²): Si la lista está invertida, cada elemento debe desplazarse hasta el extremo izquierdo, haciendo n(n - 1)/2 comparaciones.',
      'Estable: Respeta el orden relativo de elementos con valores iguales.',
    ],
  ),
];

