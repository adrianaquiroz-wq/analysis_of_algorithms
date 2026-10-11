import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class TheorySection extends StatelessWidget {
  final String title;
  final AppPalette palette;
  final Widget child;

  const TheorySection({
    super.key,
    required this.title,
    required this.palette,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.accent.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ],
    );
  }
}
