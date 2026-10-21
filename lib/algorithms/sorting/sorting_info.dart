import 'package:flutter/material.dart';

/// Todo lo que describe un método de ordenamiento: lo que muestra su
/// tarjeta, su pantalla de teoría y la pantalla de visualización.
/// (Equivalente a AlgorithmInfo, pero sin depender del lienzo de grafos.)
class SortingInfo {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String theory;

  /// Pasos o ideas clave para la sección "Cómo funciona".
  final List<String> steps;

  /// Dibujo de la tarjeta. Si es null se muestra [icon].
  final WidgetBuilder? previewBuilder;

  /// Pantalla de visualización a la que se llega desde la teoría.
  final WidgetBuilder screenBuilder;

  const SortingInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theory,
    required this.steps,
    required this.screenBuilder,
    this.previewBuilder,
  });
}
