import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

/// Ayuda de Shell Sort: su resumen, las secciones generales de ordenamiento
/// y lo que solo aplica a este método.
final List<SortingHelpSection> shellSortHelp = [
  const SortingHelpSection(
    title: '¿Qué hace Shell Sort?',
    icon: Icons.info_outline_rounded,
    items: [
      'Es una mejora del ordenamiento por inserción: en lugar de comparar solo vecinos, compara números separados por un salto h.',
      'Empieza con un salto grande y lo va reduciendo hasta llegar a 1. Así los números muy desordenados viajan lejos desde el principio.',
      'Se usa la secuencia de Knuth (1, 4, 13, 40, ...) y su peor caso teórico es O(n^(3/2)).',
    ],
  ),
  ...commonSortingHelp,
  const SortingHelpSection(
    title: 'Cómo leer la animación',
    icon: Icons.visibility_rounded,
    items: [
      'Pasada y salto: el cuadro de arriba indica en qué pasada va y cuál es el salto h actual.',
      'Corchete amarillo: une los dos pingüinos que se comparan y muestra cuántas posiciones los separan (h).',
      'Puntos de colores: debajo de cada posición. Los del mismo color forman una sublista, es decir, los números separados h posiciones que se ordenan entre sí por inserción en esa pasada.',
      'Contorno amarillo: marca los dos pingüinos que se están comparando en ese momento.',
      'Si ya respetan el orden, se quedan quietos un instante y el algoritmo sigue con la siguiente comparación.',
      'Si están desordenados, se levantan, uno salta por encima del otro hacia su nuevo lugar y luego bajan.',
      'Por eso hay más comparaciones que intercambios: no todas las comparaciones mueven pingüinos.',
      'Cuando h llega a 1, la lista ya está casi ordenada y esa última pasada la termina.',
    ],
  ),
  const SortingHelpSection(
    title: 'Complejidad de tu conjunto',
    icon: Icons.functions_rounded,
    items: [
      'Big O describe cómo crece el costo al aumentar la cantidad de números (n), por eso una sola lista no tiene una respuesta directa.',
      'Para estimarla, la app mide qué tan desordenado está tu conjunto, crea listas de 128 a 2048 números con ese mismo nivel de desorden, ejecuta Shell Sort en cada una y calcula el exponente k de O(n^k).',
      'Desorden del conjunto: porcentaje de pares de números que están en el orden contrario al que pediste.',
      'Frente a la cota teórica: indica si el exponente queda dentro de O(n^(3/2)).',
      'Es una estimación empírica: sirve para comparar tendencias, no es una demostración matemática.',
    ],
  ),
];
