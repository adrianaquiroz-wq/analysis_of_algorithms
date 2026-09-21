import 'package:flutter/material.dart';

class RightToolbar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final String activeTool;
  final ValueChanged<String> onSelectTool;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomReset;
  final bool isDarkMode;
  final bool isBipartiteMode;
  final ValueChanged<String>? onSelectBipartiteTool;

  const RightToolbar({
    super.key,
    required this.isOpen,
    required this.isDarkMode,
    this.isBipartiteMode = false,
    required this.onToggle,
    required this.activeTool,
    required this.onSelectTool,
    this.onSelectBipartiteTool,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomReset,
  });

  @override
  Widget build(BuildContext context) {
    final toolbarColor = isDarkMode
        ? const Color(0xFF1E3A8A)
        : const Color(0xFFF1F5F9);

    final iconColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);

    return Material(
      elevation: 4,
      color: toolbarColor,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 3.0,
              ),
              child: Icon(
                isOpen ? Icons.chevron_right : Icons.chevron_left,
                size: 15,
                color: iconColor,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isOpen ? 50 : 0,
            child: ClipRect(
              child: OverflowBox(
                maxWidth: 25,
                minWidth: 25,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 25, // Forzamos el ancho estricto para evitar saltos
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.near_me, size: 22),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: activeTool == 'select'
                              ? Colors.cyanAccent
                              : iconColor,
                          tooltip: 'Seleccionar / Mover',
                          onPressed: () => onSelectTool('select'),
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.radio_button_checked,
                            size: 22,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: activeTool == 'node'
                              ? Colors.cyanAccent
                              : iconColor,
                          tooltip: 'Agregar Nodo',
                          onPressed: () => onSelectTool('node'),
                        ),
                        const SizedBox(height: 4),

                        // --- BOTÓN CONDICIONAL PARA ASIGNACIÓN BIPARTIDA ---
                        if (isBipartiteMode) ...[
                          IconButton(
                            icon: const Icon(Icons.hub, size: 22),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            color: activeTool == 'bipartite_node'
                                ? Colors.cyanAccent
                                : iconColor,
                            tooltip: 'Nodo Conjunto B (Diferenciado)',
                            onPressed: () {
                              if (onSelectBipartiteTool != null) {
                                onSelectBipartiteTool!('bipartite_node');
                              } else {
                                onSelectTool('bipartite_node');
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                        ],
                        // --------------------------------------------------

                        IconButton(
                          icon: const Icon(Icons.show_chart, size: 22),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: activeTool == 'edge'
                              ? Colors.cyanAccent
                              : iconColor,
                          tooltip: 'Agregar Arista',
                          onPressed: () => onSelectTool('edge'),
                        ),
                        const SizedBox(height: 4),
                        // SELECCIÓN POR ÁREA
                        IconButton(
                          icon: const Icon(Icons.select_all, size: 22),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: activeTool == 'area_select'
                              ? Colors.cyanAccent
                              : iconColor,
                          tooltip: 'Selección por Área',
                          onPressed: () => onSelectTool('area_select'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Divider(
                            indent: 10,
                            endIndent: 10,
                            height: 1,
                            color: isDarkMode ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 4),
                              IconButton(
                                icon: const Icon(Icons.zoom_out_map, size: 22),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                color: iconColor,
                                tooltip: 'Restablecer Zoom',
                                onPressed: onZoomReset,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
