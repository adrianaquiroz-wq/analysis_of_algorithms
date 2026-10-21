import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_theory_screen.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';

/// Tarjeta del carrusel de ordenamiento (mismo estilo que la de grafos).
/// Al tocarla pasa por la pantalla de teoría.
class SortingAlgorithmCard extends StatelessWidget {
  final SortingInfo algo;
  final bool isDarkMode;
  final Color textColor;
  final Color accentColor;

  const SortingAlgorithmCard({
    super.key,
    required this.algo,
    required this.isDarkMode,
    required this.textColor,
    required this.accentColor,
  });

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SortingTheoryScreen(algorithm: algo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: surface,
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 75),
                    child:
                        algo.previewBuilder?.call(context) ??
                        Center(
                          child: Icon(algo.icon, color: accentColor, size: 40),
                        ),
                  ),
                ),
                Positioned(bottom: 0, left: 0, right: 0, child: _footer()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDarkMode ? const Color(0xFF0F172A) : Colors.white).withValues(
          alpha: 0.85,
        ),
        border: Border(
          top: BorderSide(color: accentColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            algo.title,
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
            algo.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDarkMode ? Colors.white60 : Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
