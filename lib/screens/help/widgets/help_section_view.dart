import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

import '../help_content.dart';

/// Tarjeta contenedora reutilizada por todas las secciones de ayuda.
class HelpCard extends StatelessWidget {
  final AppPalette palette;
  final Widget child;

  const HelpCard({super.key, required this.palette, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HelpSectionTitle extends StatelessWidget {
  final String title;
  final AppPalette palette;

  const HelpSectionTitle({
    super.key,
    required this.title,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: palette.accent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HelpSectionView extends StatelessWidget {
  final HelpSection section;
  final AppPalette palette;

  const HelpSectionView({
    super.key,
    required this.section,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpSectionTitle(title: section.title, palette: palette),
          HelpCard(
            palette: palette,
            child: section.text != null
                ? Text(
                    section.text!,
                    style: TextStyle(
                      color: palette.subtleText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < section.items.length; i++) ...[
                        if (i > 0) Divider(color: palette.divider, height: 20),
                        _HelpRow(item: section.items[i], palette: palette),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final HelpItem item;
  final AppPalette palette;

  const _HelpRow({required this.item, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, color: palette.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(
                  color: palette.subtleText,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
