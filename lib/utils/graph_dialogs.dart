import 'package:flutter/material.dart';

class GraphDialogs {
  static Future<bool> confirmClearCanvas(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Limpiar lienzo',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que querés borrar todos los nodos y aristas?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Borrar todo',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
