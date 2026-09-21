import 'package:flutter/material.dart';

class GraphAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final bool canUndo;
  final bool canRedo;
  final bool canPaste;
  final bool canClear;
  final VoidCallback onPaste;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClearCanvas;
  final ValueChanged<bool> onThemeChanged;

  const GraphAppBar({
    super.key,
    required this.isDarkMode,
    required this.canUndo,
    required this.canRedo,
    required this.canPaste,
    required this.canClear,
    required this.onPaste,
    required this.onUndo,
    required this.onRedo,
    required this.onClearCanvas,
    required this.onThemeChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appBarColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return AppBar(
      backgroundColor: appBarColor,
      elevation: isDarkMode ? 0 : 1,
      title: Text(
        'ST-GR', // <-- Nombre de tu app restaurado aquí
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        /*IconButton(
          icon: const Icon(Icons.content_paste),
          color: textColor,
          tooltip: 'Pegar',
          onPressed: canPaste ? onPaste : null,
        ),*/
        IconButton(
          icon: const Icon(Icons.undo),
          color: textColor,
          tooltip: 'Deshacer',
          onPressed: canUndo ? onUndo : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          color: textColor,
          tooltip: 'Rehacer',
          onPressed: canRedo ? onRedo : null,
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          color: textColor,
          tooltip: 'Limpiar lienzo',
          onPressed: canClear ? onClearCanvas : null,
        ),
      ],
    );
  }
}
