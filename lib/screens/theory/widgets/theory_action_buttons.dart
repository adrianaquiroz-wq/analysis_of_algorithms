import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/screens/graph/graph_screen.dart';
import 'package:graph_app/theme/app_palette.dart';

class TheoryActionButtons extends StatelessWidget {
  final AlgorithmInfo algorithm;
  final AppPalette palette;

  const TheoryActionButtons({
    super.key,
    required this.algorithm,
    required this.palette,
  });

  Future<void> _openYoutube(BuildContext context) async {
    if (algorithm.youtubeUrl.isEmpty) return;
    final ok = await launchUrl(
      Uri.parse(algorithm.youtubeUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  void _openSolver(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraphScreen(
          initialBipartiteAssignment: algorithm.isBipartite,
          algorithmType: algorithm.id,
          algorithmTitle: algorithm.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            onPressed: () => _openYoutube(context),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.accent,
              foregroundColor: palette.isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.hub_rounded),
            label: const Text(
              'Ir a Graficar / Resolver',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openSolver(context),
          ),
        ),
      ],
    );
  }
}
