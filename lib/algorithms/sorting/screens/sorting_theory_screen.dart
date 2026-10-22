import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/sorting_info.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

/// Teoría de un método de ordenamiento. Desde aquí se abre la visualización.
class SortingTheoryScreen extends StatelessWidget {
  final SortingInfo algorithm;

  const SortingTheoryScreen({super.key, required this.algorithm});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _buildScreen(context, AppPalette(isDark)),
    );
  }

  Widget _buildScreen(BuildContext context, AppPalette p) {
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.card,
        title: Text(algorithm.title, style: TextStyle(color: p.text)),
        iconTheme: IconThemeData(color: p.text),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(p),
          const SizedBox(height: 16),
          _section(
            p,
            'Teoría',
            Text(
              algorithm.theory,
              textAlign: TextAlign.justify,
              style: TextStyle(color: p.subtleText, fontSize: 14, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          _section(p, 'Cómo funciona', _steps(p)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: algorithm.screenBuilder),
            ),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Abrir visualización'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(p),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(algorithm.icon, color: p.accent, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  algorithm.title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  algorithm.subtitle,
                  style: TextStyle(color: p.subtleText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(AppPalette p, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _steps(AppPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < algorithm.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: p.accent.withValues(alpha: 0.2),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    algorithm.steps[i],
                    style: TextStyle(
                      color: p.subtleText,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  BoxDecoration _cardDecoration(AppPalette p) => BoxDecoration(
    color: p.card,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: p.cardBorder),
  );
}
