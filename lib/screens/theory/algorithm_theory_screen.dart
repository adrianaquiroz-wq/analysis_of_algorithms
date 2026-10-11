import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/algorithm_registry.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

import 'widgets/requirements_list.dart';
import 'widgets/theory_action_buttons.dart';
import 'widgets/theory_section.dart';

class AlgorithmTheoryScreen extends StatelessWidget {
  final AlgorithmInfo algorithm;

  const AlgorithmTheoryScreen({super.key, required this.algorithm});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _buildScreen(AppPalette(isDark)),
    );
  }

  Widget _buildScreen(AppPalette palette) {
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.appBar,
        title: Text(
          'Teoría: ${algorithm.title}',
          style: TextStyle(color: palette.text, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: palette.accent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(algorithm.icon, size: 64, color: palette.accent),
              ),
            ),
            const SizedBox(height: 24),
            TheorySection(
              title: 'Fundamento Teórico',
              palette: palette,
              child: Text(
                algorithm.theory,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TheorySection(
              title: 'Tener en cuenta:',
              palette: palette,
              child: RequirementsList(
                items: algorithm.requirements,
                palette: palette,
              ),
            ),
            const SizedBox(height: 24),
            TheoryActionButtons(algorithm: algorithm, palette: palette),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
