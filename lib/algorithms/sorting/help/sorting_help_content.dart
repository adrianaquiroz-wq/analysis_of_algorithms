import 'package:flutter/material.dart';

/// Una sección de la ayuda: título, ícono y una lista de puntos.
class SortingHelpSection {
  final String title;
  final IconData icon;
  final List<String> items;

  const SortingHelpSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

/// Secciones que valen para TODOS los métodos de ordenamiento.
/// Cada método le suma las suyas en su propio archivo (ver shell_sort_help).
const List<SortingHelpSection> commonSortingHelp = [
  SortingHelpSection(
    title: 'Ingresar los datos',
    icon: Icons.edit_note_rounded,
    items: [
      'Escribir números: sepáralos con coma o espacio. Se aceptan de 2 a 30 números enteros entre 1 y 100.',
      'Aleatorio: indica cuántos números quieres (de 2 a 30) y pulsa "Generar".',
      'Cada número se dibuja como un pingüino: mientras más grande el valor, más alto el pingüino.',
      'Los datos se pueden cambiar solo cuando no hay un ordenamiento en marcha.',
    ],
  ),
  SortingHelpSection(
    title: 'Ascendente o descendente',
    icon: Icons.swap_vert_rounded,
    items: [
      'El selector de arriba a la derecha elige el orden final: de menor a mayor (ascendente) o de mayor a menor (descendente).',
      'Al cambiarlo, la animación vuelve al inicio.',
    ],
  ),
  SortingHelpSection(
    title: 'Controles y velocidad',
    icon: Icons.speed_rounded,
    items: [
      'Empezar ordenamiento: reproduce de corrido cómo se mueven los pingüinos hasta quedar ordenados.',
      'Pausar / Continuar: detiene la animación y la retoma donde se quedó.',
      'Reiniciar: devuelve los pingüinos a su posición original.',
      'Velocidad: de 0.25x (muy lento) a 4x (rápido). Se puede cambiar en cualquier momento y se aplica en el siguiente movimiento.',
    ],
  ),
  SortingHelpSection(
    title: 'Tiempo y operaciones',
    icon: Icons.timer_outlined,
    items: [
      'Tiempo de ejecución: lo que tarda el algoritmo en ordenar, medido sin contar la animación. Es un promedio de varias corridas, porque con pocos números una sola es demasiado rápida para medirla bien.',
      'Comparaciones: cuántas veces el algoritmo comparó dos números.',
      'Intercambios: cuántas veces cambió dos números de lugar. Es lo que ves moverse en la animación.',
    ],
  ),
  SortingHelpSection(
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
