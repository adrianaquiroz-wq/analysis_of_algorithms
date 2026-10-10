import 'package:flutter/material.dart';

import '../graph_screen.dart';
import '../algorithm_theory_screen.dart';

class GraphAlgorithmCard extends StatelessWidget {
  final Map<String, dynamic> algo;
  final bool isDarkMode;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;

  const GraphAlgorithmCard({
    super.key,
    required this.algo,
    required this.isDarkMode,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
  });

  void _open(BuildContext context) {
    // Grafo libre va directo; los demás pasan por la pantalla de teoría
    if (algo['algorithmType'] == 'free') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GraphScreen(
            initialBipartiteAssignment: false,
            algorithmType: 'free',
            algorithmTitle: 'Grafo Simple / Libre',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlgorithmTheoryScreen(
            algorithmName: algo['title'],
            theoryDescription: algo['theory'],
            icon: algo['icon'],
            isDarkMode: isDarkMode,
            algorithmType: algo['algorithmType'],
            isBipartite: algo['isBipartite'],
            youtubeUrl: algo['youtubeUrl'],
            requisitoDescription: algo['requisito'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _open(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 75,
                      top: 8,
                      left: 8,
                      right: 8,
                    ),
                    child: Image.asset(
                      algo['imageUrl'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(algo['icon'], color: accentColor, size: 40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDarkMode ? const Color(0xFF0F172A) : Colors.white)
                              .withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: accentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          algo['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          algo['subtitle'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
