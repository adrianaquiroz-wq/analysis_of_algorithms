import 'package:flutter/material.dart';

import 'algorithm_data.dart';
import 'body_text.dart';
import 'graph_algorithm_card.dart';

/// Tarjeta 1: GRAFOS (contiene las 4 tarjetas en horizontal)
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.hub_rounded, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'GRAFOS',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BodyText(
              'Modela redes y resuelve problemas de optimización: grafo libre, asignación, CPM y transporte.',
              isDarkMode: isDarkMode,
            ),
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

/// Tarjeta 2: ALGORITMOS DE ORDENAMIENTO
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
      decoration: sectionCardDecoration(cardColor, accentColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: navegar a la pantalla de ordenamiento cuando exista
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Próximamente')));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sort_rounded, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALGORITMOS DE ORDENAMIENTO',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      BodyText(
                        'Visualiza paso a paso cómo se ordenan los datos con distintos algoritmos.',
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
