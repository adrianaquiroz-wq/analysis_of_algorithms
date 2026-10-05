import 'package:flutter/material.dart';

import 'graph_screen.dart';

class AlgorithmTheoryScreen extends StatelessWidget {
  final String algorithmName;
  final String theoryDescription;
  final IconData icon;
  final bool isDarkMode;
  final String algorithmType; // <-- Añadido para recibir el tipo de algoritmo
  final bool isBipartite; // <-- Añadido para saber si es bipartito

  const AlgorithmTheoryScreen({
    Key? key,
    required this.algorithmName,
    required this.theoryDescription,
    required this.icon,
    required this.isDarkMode,
    required this.algorithmType,
    required this.isBipartite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Teoría: $algorithmName',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: accentColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fundamento Teórico',
              style: TextStyle(
                color: accentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                theoryDescription,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.hub_rounded),
                label: const Text(
                  'Ir a Graficar / Resolver',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Navega al editor del grafo pasando los parámetros limpios
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GraphScreen(
                        initialBipartiteAssignment: isBipartite,
                        algorithmType: algorithmType,
                        algorithmTitle: algorithmName,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
