import 'package:flutter/material.dart';

class FloatingMenu extends StatelessWidget {
  final VoidCallback onDelete;
  final bool isDarkMode; // Recibimos el estado del tema

  const FloatingMenu({
    Key? key,
    required this.onDelete,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definimos colores dinámicos según el modo
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDarkMode ? Colors.cyanAccent : Colors.blueGrey;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black26;

    return Container(
      // Reducimos el padding para que sea más compacto
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Eliminamos el VerticalDivider porque ya no hace falta separar elementos
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
            tooltip: 'Eliminar',
            constraints: const BoxConstraints(), // Elimina restricciones por defecto para apretar el tamaño
            padding: const EdgeInsets.all(
              8,
            ), // Padding controlado para el botón
          ),
        ],
      ),
    );
  }
}
