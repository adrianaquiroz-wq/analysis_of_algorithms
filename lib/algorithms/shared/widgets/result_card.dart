import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class ResultCard extends StatelessWidget {
  final AppPalette palette;
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry? margin;

  const ResultCard({
    super.key,
    required this.palette,
    required this.child,
    this.elevation = 4,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: palette.card,
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
