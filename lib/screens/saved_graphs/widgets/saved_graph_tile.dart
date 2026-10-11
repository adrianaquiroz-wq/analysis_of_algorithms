// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graph_app/models/saved_graph.dart';
import 'package:graph_app/theme/app_palette.dart';

class SavedGraphTile extends StatelessWidget {
  final SavedGraphMeta meta;
  final AppPalette palette;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const SavedGraphTile({
    super.key,
    required this.meta,
    required this.palette,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(meta.updatedAt);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.cardBorder),
      ),
      child: ListTile(
        title: Text(
          meta.name,
          style: TextStyle(color: palette.text, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Última edición: $date',
          style: TextStyle(color: palette.mutedText),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
        onTap: onOpen,
      ),
    );
  }
}
