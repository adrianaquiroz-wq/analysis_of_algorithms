import 'package:flutter/material.dart';
import 'package:graph_app/screens/graph/graph_screen.dart';
import 'package:graph_app/theme/app_palette.dart';

import 'category_cards.dart';
import 'intro_section.dart';
import 'team_section.dart';

class HomeContent extends StatelessWidget {
  final AppPalette palette;

  const HomeContent({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              'ANÁLISIS DE ALGORITMOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          IntroSection(
            isDarkMode: isDark,
            textColor: palette.text,
            cardColor: palette.card,
            accentColor: palette.accent,
          ),
          const SizedBox(height: 24),
          TeamSection(
            isDarkMode: isDark,
            textColor: palette.text,
            cardColor: palette.card,
            accentColor: palette.accent,
          ),
          const SizedBox(height: 24),
          Text(
            'Módulos y Algoritmos',
            style: TextStyle(
              color: palette.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GraphsCategoryCard(
            isDarkMode: isDark,
            textColor: palette.text,
            cardColor: palette.card,
            accentColor: palette.accent,
          ),
          const SizedBox(height: 16),
          SortingCategoryCard(
            isDarkMode: isDark,
            textColor: palette.text,
            cardColor: palette.card,
            accentColor: palette.accent,
          ),
          const SizedBox(height: 30),
          Center(child: _FreeCanvasButton(accent: palette.accent)),
        ],
      ),
    );
  }
}

class _FreeCanvasButton extends StatelessWidget {
  final Color accent;

  const _FreeCanvasButton({required this.accent});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(Icons.edit_note_rounded, color: accent),
      label: Text(
        'Abrir Lienzo Libre de Grafos',
        style: TextStyle(color: accent, fontWeight: FontWeight.bold),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const GraphScreen(
            initialBipartiteAssignment: false,
            algorithmType: 'free',
          ),
        ),
      ),
    );
  }
}
