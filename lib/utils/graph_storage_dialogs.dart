import 'package:flutter/material.dart';

/// Diálogo para gestionar nombres y confirmaciones, optimizado con modo oscuro por defecto.
class GraphStorageDialogs {
  static Future<String?> askGraphName(
    BuildContext context, {
    String? initialValue,
    bool isDarkMode = true,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    final backgroundColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white38 : Colors.black38;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black26;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Guardar Archivo', style: TextStyle(color: titleColor)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Nombre del archivo',
              hintStyle: TextStyle(color: hintColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    String graphName, {
    bool isDarkMode = true,
  }) async {
    final backgroundColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final contentColor = isDarkMode ? Colors.white70 : Colors.black54;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('¿Eliminar grafo?', style: TextStyle(color: titleColor)),
          content: Text(
            'Se eliminará "$graphName" de forma permanente.',
            style: TextStyle(color: contentColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
