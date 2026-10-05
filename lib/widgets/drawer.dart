import 'package:flutter/material.dart';

class GraphDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onOpenAdjacencyMatrix;
  final VoidCallback onNewCanvas;
  final VoidCallback onSaveGraph;
  final VoidCallback onOpenSavedGraphs;
  final VoidCallback onOpenHelp;
  final VoidCallback onBackHome;
  final String algorithmTitle;

  const GraphDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onOpenAdjacencyMatrix,
    required this.onNewCanvas,
    required this.onSaveGraph,
    required this.onOpenSavedGraphs,
    required this.onOpenHelp,
    required this.onBackHome,
    this.algorithmTitle = 'Lienzo General',
  });

  @override
  Widget build(BuildContext context) {
    final drawerBg = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final activeColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;

    return Drawer(
      backgroundColor: drawerBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.hub_rounded, color: activeColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  'ST-GR / Menú',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 2. Aquí mostramos dinámicamente el nombre del método seleccionado
                Text(
                  algorithmTitle,
                  style: TextStyle(
                    color: isDarkMode ? Colors.cyanAccent : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: activeColor,
            ),
            title: Text('Modo Oscuro', style: TextStyle(color: textColor)),
            value: isDarkMode,
            onChanged: onThemeChanged,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.note_add_rounded, color: activeColor),
            title: Text(
              'Nuevo Lienzo',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onNewCanvas();
            },
          ),
          ListTile(
            leading: Icon(Icons.save_rounded, color: activeColor),
            title: Text(
              'Guardar Grafo',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onSaveGraph();
            },
          ),
          ListTile(
            leading: Icon(Icons.folder_open_rounded, color: activeColor),
            title: Text(
              'Grafos Guardados',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenSavedGraphs();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.help_outline_rounded, color: activeColor),
            title: Text(
              'Ayuda',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenHelp();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.orangeAccent,
            ),
            title: Text(
              'Volver al Inicio',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onBackHome();
            },
          ),
        ],
      ),
    );
  }
}
