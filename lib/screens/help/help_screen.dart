import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

import 'help_content.dart';
import 'widgets/ai_help_section.dart';
import 'widgets/help_section_view.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) {
        final palette = AppPalette(isDark);

        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            title: Text(
              'Manual de Usuario y Ayuda',
              style: TextStyle(color: palette.text, fontSize: 18),
            ),
            backgroundColor: palette.appBar,
            iconTheme: IconThemeData(color: palette.accent),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final section in helpSections)
                HelpSectionView(section: section, palette: palette),
              AiHelpSection(palette: palette),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
