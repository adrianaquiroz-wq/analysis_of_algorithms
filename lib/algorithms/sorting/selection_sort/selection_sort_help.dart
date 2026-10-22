import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';

final List<SortingHelpSection> selectionSortHelp = [
  const SortingHelpSection(
    title: '¿Qué hace Selection Sort?',
    icon: Icons.info_outline_rounded,
    items: [
      'Busca el menor elemento de la zona que todavía no está ordenada.',
      'Lo intercambia con el primer elemento de esa zona y avanza la frontera.',
      'Repite hasta dejar todos los elementos en su posición final.',
      'Tiene complejidad O(n²), espacio O(1) y no es estable.',
    ],
  ),
  const SortingHelpSection(
    title: 'Cómo leer la animación',
    icon: Icons.visibility_rounded,
    items: [
      'La posición seleccionada marca el lugar que se está completando.',
      'El índice de búsqueda recorre los elementos restantes.',
      'El mínimo encontrado se intercambia al terminar cada pasada.',
    ],
  ),
];
