import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'graph_screen.dart';

class AlgorithmTheoryScreen extends StatelessWidget {
  final String algorithmName;
  final String theoryDescription;
  final IconData icon;
  final bool isDarkMode;
  final String algorithmType; // Recibe el tipo de algoritmo
  final bool isBipartite; // Recibe si es bipartito
  final String youtubeUrl;
  final String
  requisitoDescription; // <-- Nuevo parámetro para el enlace de YouTube

  const AlgorithmTheoryScreen({
    Key? key,
    required this.algorithmName,
    required this.theoryDescription,
    required this.icon,
    required this.isDarkMode,
    required this.algorithmType,
    required this.isBipartite,
    required this.youtubeUrl,
    required this.requisitoDescription, // <-- Requerido en el constructor
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
    final List<String> listaOraciones = requisitoDescription
        .split(RegExp(r'\.\s*'))
        .where((oracion) => oracion.trim().isNotEmpty)
        .map((oracion) => oracion.trim())
        .toList();

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
                textAlign: TextAlign
                    .justify, // <-- Costados rectos alineados formalmente
                style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Tomar encuenta:',
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
              // 2. Usamos una Column para enlistar cada oración procesada
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listaOraciones.map((oracion) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ), // Espacio entre cada oración
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ), // Opcional: viñeta
                        Expanded(
                          child: Text(
                            oracion +
                                (oracion.endsWith('.')
                                    ? ''
                                    : '.'), // Asegura que termine con punto
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            // --- BOTÓN DE YOUTUBE ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.redAccent, width: 0.5),
                  ),
                ),
                icon: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'Ver explicación en YouTube',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (youtubeUrl.isNotEmpty) {
                    _launchYouTubeUrl(youtubeUrl);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _launchYouTubeUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace $url');
    }
  }
}
