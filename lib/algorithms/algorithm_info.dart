import 'package:flutter/material.dart';
import 'package:graph_app/controllers/graph_controller.dart';

typedef SolverOpener = void Function(
  BuildContext context,
  GraphController controller, {
  required bool isDarkMode,
  required bool isLinearFlow,
  required bool isBipartiteFlow,
});

/// Botón flotante que abre el solucionador de un método.
class SolverAction {
  final IconData icon;
  final String tooltip;
  final SolverOpener open;

  const SolverAction({
    required this.icon,
    required this.tooltip,
    required this.open,
  });
}

/// Todo lo que describe un método: teoría, requisitos y solucionador.
class AlgorithmInfo {
  /// 'free', 'assignment', 'cpm', 'northwest'
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isBipartite;
  final String theory;
  final List<String> requirements;
  final String youtubeUrl;
  final String imageUrl;
  final SolverAction? solver;

  AlgorithmInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isBipartite,
    required this.theory,
    required this.requirements,
    required this.youtubeUrl,
    required this.imageUrl,
    this.solver,
  });
}
