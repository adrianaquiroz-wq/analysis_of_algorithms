import 'package:flutter/material.dart';
import 'package:graph_app/screens/help/help_screen.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_controller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppPalette palette;

  const HomeAppBar({super.key, required this.palette});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: palette.appBar,
      elevation: 1,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, color: palette.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'ST-GR / Graph Suite',
            style: TextStyle(
              color: palette.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            palette.isDark ? Icons.light_mode : Icons.dark_mode,
            color: palette.accent,
          ),
          onPressed: ThemeController.instance.toggle,
          tooltip: 'Cambiar tema',
        ),
        IconButton(
          icon: Icon(Icons.help_outline_rounded, color: palette.accent),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          ),
          tooltip: 'Ayuda',
        ),
      ],
    );
  }
}
