import 'package:flutter/material.dart';

/// Menú de hamburguesa de la app. Las opciones propias de los grafos
/// (nuevo lienzo, guardar, grafos guardados) son opcionales: si no se
/// pasan, no se muestran (por ejemplo en las pantallas de ordenamiento).
class GraphDrawer extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback? onOpenAdjacencyMatrix;
  final VoidCallback? onNewCanvas;
  final VoidCallback? onSaveGraph;
  final VoidCallback? onOpenSavedGraphs;
  final VoidCallback? onSelectionSort;
  final VoidCallback onOpenHelp;
  final VoidCallback onBackHome;
  final String algorithmTitle;
  final IconData headerIcon;
  final String newLabel;
  final String saveLabel;
  final String savedLabel;

  const GraphDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onOpenHelp,
    required this.onBackHome,
    this.onOpenAdjacencyMatrix,
    this.onNewCanvas,
    this.onSaveGraph,
    this.onOpenSavedGraphs,
    this.onSelectionSort,
    this.algorithmTitle = 'Lienzo General',
    this.headerIcon = Icons.hub_rounded,
    this.newLabel = 'Nuevo Lienzo',
    this.saveLabel = 'Guardar Grafo',
    this.savedLabel = 'Grafos Guardados',
  });

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required String label,
    required VoidCallback action,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerBg = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final activeColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;
    final hasGraphActions =
        onNewCanvas != null || onSaveGraph != null || onOpenSavedGraphs != null;

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
                Icon(headerIcon, color: activeColor, size: 32),
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
                // Nombre del método seleccionado
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
          if (hasGraphActions) ...[
            if (onNewCanvas != null)
              _tile(
                context,
                icon: Icons.note_add_rounded,
                iconColor: activeColor,
                textColor: textColor,
                label: newLabel,
                action: onNewCanvas!,
              ),
            if (onSaveGraph != null)
              _tile(
                context,
                icon: Icons.save_rounded,
                iconColor: activeColor,
                textColor: textColor,
                label: saveLabel,
                action: onSaveGraph!,
              ),
            if (onOpenSavedGraphs != null)
              _tile(
                context,
                icon: Icons.folder_open_rounded,
                iconColor: activeColor,
                textColor: textColor,
                label: savedLabel,
                action: onOpenSavedGraphs!,
              ),
            if (onSelectionSort != null)
              _tile(
                context,
                icon: Icons.sort_rounded,
                iconColor: activeColor,
                textColor: textColor,
                label: 'Selection Sort por pesos',
                action: onSelectionSort!,
              ),
            const Divider(),
          ],
          _tile(
            context,
            icon: Icons.help_outline_rounded,
            iconColor: activeColor,
            textColor: textColor,
            label: 'Ayuda',
            action: onOpenHelp,
          ),
          _tile(
            context,
            icon: Icons.arrow_back_rounded,
            iconColor: Colors.orangeAccent,
            textColor: textColor,
            label: 'Volver al Inicio',
            action: onBackHome,
          ),
        ],
      ),
    );
  }
}
