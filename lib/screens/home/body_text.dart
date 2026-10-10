import 'package:flutter/material.dart';

class BodyText extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const BodyText(this.text, {super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black54,
        fontSize: 13,
      ),
    );
  }
}

/// Decoración de tarjeta que se repetía en varias secciones.
BoxDecoration sectionCardDecoration(Color cardColor, Color accentColor) {
  return BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
    boxShadow: [
      BoxShadow(
        color: accentColor.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
