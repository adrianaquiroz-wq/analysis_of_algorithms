import 'package:flutter/material.dart';

//import 'algorithm_data.dart';
import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/algorithms/binary_trees/binary_trees_registry.dart';
import 'package:graph_app/algorithms/dijkstra_kruskal/dijkstra_kruskal_registry.dart';
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

/// Tarjeta genérica con carrusel de [items]. Si todavía no hay ninguno,
/// muestra un aviso de "Próximamente".
class _ComingSoonCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<SortingInfo> items;
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const _ComingSoonCategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.items,
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
            icon: icon,
            title: title,
            description: description,
            isDarkMode: isDarkMode,
            textColor: textColor,
            accentColor: accentColor,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Próximamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) => SortingAlgorithmCard(
                  algo: items[index],
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

/// Tarjeta 3: ÁRBOLES BINARIOS
class BinaryTreesCategoryCard extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const BinaryTreesCategoryCard({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ComingSoonCategoryCard(
      icon: Icons.account_tree_rounded,
      title: 'ÁRBOLES BINARIOS',
      description: 'Visualiza cómo se construyen y recorren los árboles binarios.',
      items: binaryTreeAlgorithms,
      isDarkMode: isDarkMode,
      textColor: textColor,
      cardColor: cardColor,
      accentColor: accentColor,
    );
  }
}

/// Tarjeta 4: DIJKSTRA Y KRUSKAL
class DijkstraKruskalCategoryCard extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const DijkstraKruskalCategoryCard({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ComingSoonCategoryCard(
      icon: Icons.route_rounded,
      title: 'DIJKSTRA Y KRUSKAL',
      description:
          'Caminos más cortos y árbol de expansión mínima sobre grafos.',
      items: dijkstraKruskalAlgorithms,
      isDarkMode: isDarkMode,
      textColor: textColor,
      cardColor: cardColor,
      accentColor: accentColor,
    );
  }
}
