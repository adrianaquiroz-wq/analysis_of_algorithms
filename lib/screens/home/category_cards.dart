import 'package:flutter/material.dart';

//import 'algorithm_data.dart';
import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/algorithms/sorting/sorting_registry.dart';
import 'package:graph_app/algorithms/sorting/widgets/sorting_algorithm_card.dart';

import 'body_text.dart';
import 'graph_algorithm_card.dart';

/// Encabezado de una categoría: ícono, título y descripción.
class _CategoryHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDarkMode;
  final Color textColor;
  final Color accentColor;

  const _CategoryHeader({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDarkMode,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BodyText(description, isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

/// Tarjeta 1: GRAFOS (contiene las tarjetas en horizontal)
class GraphsCategoryCard extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const GraphsCategoryCard({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: sectionCardDecoration(cardColor, accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(
            icon: Icons.hub_rounded,
            title: 'GRAFOS',
            description: 'Modela redes y resuelve problemas de optimización: grafo libre, asignación, CPM y transporte.',
            isDarkMode: isDarkMode,
            textColor: textColor,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: graphAlgorithms.length,
              itemBuilder: (context, index) => GraphAlgorithmCard(
                algo: graphAlgorithms[index],
                isDarkMode: isDarkMode,
                textColor: textColor,
                cardColor: cardColor,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta 2: ALGORITMOS DE ORDENAMIENTO (carrusel igual al de grafos)
class SortingCategoryCard extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const SortingCategoryCard({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: sectionCardDecoration(cardColor, accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(
            icon: Icons.sort_rounded,
            title: 'ALGORITMOS DE ORDENAMIENTO',
            description:
                'Visualiza cómo se ordenan los datos con distintos algoritmos.',
            isDarkMode: isDarkMode,
            textColor: textColor,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortingAlgorithms.length,
              itemBuilder: (context, index) => SortingAlgorithmCard(
                algo: sortingAlgorithms[index],
                isDarkMode: isDarkMode,
                textColor: textColor,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
