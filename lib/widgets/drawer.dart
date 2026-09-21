import 'package:flutter/material.dart';

class GraphDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onOpenAdjacencyMatrix;
  final VoidCallback onNewCanvas;
  final VoidCallback onSaveGraph;
  final VoidCallback onOpenSavedGraphs;
  final VoidCallback onLinearAssignment;
  final VoidCallback onBipartiteAssignment;
  final VoidCallback onOpenHelp;
  final bool isLinearAssignmentActive;
  final bool isBipartiteAssignmentActive;

  const GraphDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onOpenAdjacencyMatrix,
    required this.onNewCanvas,
    required this.onSaveGraph,
    required this.onOpenSavedGraphs,
    required this.onLinearAssignment,
    required this.onBipartiteAssignment,
    required this.onOpenHelp,
    this.isLinearAssignmentActive = false,
    this.isBipartiteAssignmentActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final appBarColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final activeColor = isDarkMode
        ? const Color(0xFF0E7490)
        : Colors.blueAccent;
    final activeTileColor = isDarkMode
        ? const Color(0xFF0E7490).withOpacity(0.25)
        : Colors.blueAccent.withOpacity(0.12);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: appBarColor),
            child: Text(
              'ST-GR Menú',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                fontSize: 24,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Modo Oscuro'),
            value: isDarkMode,
            onChanged: onThemeChanged,
          ),
          ListTile(
            leading: const Icon(Icons.grid_on, color: Colors.black),
            title: const Text(
              'Matriz de Adyacencia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenAdjacencyMatrix();
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add, color: Colors.black),
            title: const Text(
              'Nuevo Lienzo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onNewCanvas();
            },
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.black),
            title: const Text(
              'Guardar Grafo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onSaveGraph();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open, color: Colors.black),
            title: const Text(
              'Grafos Guardados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenSavedGraphs();
            },
          ),
          const Divider(),

          ListTile(
            selected: isLinearAssignmentActive,
            selectedTileColor: activeTileColor,
            leading: Icon(
              Icons.account_tree,
              color: isLinearAssignmentActive ? activeColor : Colors.black,
            ),
            title: Text(
              'Asignación Lineal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLinearAssignmentActive ? activeColor : null,
              ),
            ),
            trailing: isLinearAssignmentActive
                ? Icon(Icons.check_circle, color: activeColor, size: 20)
                : null,
            onTap: () {
              Navigator.pop(context);
              onLinearAssignment();
            },
          ),

          ListTile(
            selected: isBipartiteAssignmentActive,
            selectedTileColor: activeTileColor,
            leading: Icon(
              Icons.hub,
              color: isBipartiteAssignmentActive ? activeColor : Colors.black,
            ),
            title: Text(
              'Asignación Bipartida',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBipartiteAssignmentActive ? activeColor : null,
              ),
            ),
            trailing: isBipartiteAssignmentActive
                ? Icon(Icons.check_circle, color: activeColor, size: 20)
                : null,
            onTap: () {
              Navigator.pop(context);
              onBipartiteAssignment();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Colors.black,
              size: 20,
            ),
            title: const Text(
              'Ayuda',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenHelp();
            },
          ),
        ],
      ),
    );
  }
}
