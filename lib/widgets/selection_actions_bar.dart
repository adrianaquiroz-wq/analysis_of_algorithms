import 'package:flutter/material.dart';

class SelectionActionsBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCut;
  final VoidCallback onDelete;

  const SelectionActionsBar({
    super.key,
    required this.selectedCount,
    required this.onCut,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12.0,
        ), // Eleva el bloque para que se pueda presionar sin problema
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Fondo oscuro acorde a tu app
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 13),
                    elevation: 0,
                  ),
                  label: Text('Eliminar ($selectedCount)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
