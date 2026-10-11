import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Reconstruye su contenido cada vez que cambia el modo claro/oscuro.
class ThemeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDarkMode) builder;

  const ThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance,
      builder: (context, isDark, _) => builder(context, isDark),
    );
  }
}
