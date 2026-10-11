import 'package:flutter/material.dart';

/// Pide confirmación antes de borrar el lienzo. Devuelve true si acepta.
Future<bool> confirmNewCanvas(BuildContext context, bool isDarkMode) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      title: Text(
        'Nuevo Lienzo',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Vas a empezar un grafo en blanco. Los cambios sin guardar se perderán. ¿Querés continuar?',
        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
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
            'Nuevo Lienzo',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
  return result == true;
}
