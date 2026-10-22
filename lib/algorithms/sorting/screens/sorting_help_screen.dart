import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/help/sorting_help_content.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

/// Ayuda de las pantallas de ordenamiento. Sirve para cualquier método:
/// solo hay que pasarle el nombre y las secciones.
class SortingHelpScreen extends StatelessWidget {
  final String title;
  final List<SortingHelpSection> sections;

  const SortingHelpScreen({
    super.key,
    required this.title,
    required this.sections,
  });

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
        title: Text(
          'Ayuda: $title',
          style: TextStyle(color: p.text, fontSize: 18),
        ),
        backgroundColor: p.appBar,
        iconTheme: IconThemeData(color: p.accent),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < sections.length; i++)
            _SectionCard(
              section: sections[i],
              palette: p,
              initiallyExpanded: i == 0,
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SortingHelpSection section;
  final AppPalette palette;
  final bool initiallyExpanded;

  const _SectionCard({
    required this.section,
    required this.palette,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: palette.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            iconColor: palette.accent,
            collapsedIconColor: palette.accent,
            leading: Icon(section.icon, color: palette.accent),
            title: Text(
              section.title,
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in section.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Text(
                          '•',
                          style: TextStyle(color: palette.accent, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: palette.subtleText,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
