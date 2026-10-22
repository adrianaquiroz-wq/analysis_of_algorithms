import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graph_app/algorithms/sorting/storage/saved_sort.dart';
import 'package:graph_app/theme/app_palette.dart';

class SavedSortTile extends StatelessWidget {
  final SavedSort sort;
  final AppPalette palette;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const SavedSortTile({
    super.key,
    required this.sort,
    required this.palette,
    required this.onOpen,
    required this.onDelete,
  });

  String get _methodLabel => sort.sortId
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String get _preview {
    final shown = sort.values.take(8).join(', ');
    return sort.values.length > 8 ? '$shown…' : shown;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(sort.updatedAt);
    final order = sort.descending ? 'Descendente' : 'Ascendente';

    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(Icons.sort, color: palette.mutedText),
        title: Text(
          sort.name,
          style: TextStyle(color: palette.text, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$_methodLabel · $order\n[$_preview]\nÚltima edición: $date',
          style: TextStyle(color: palette.mutedText),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
        onTap: onOpen,
      ),
    );
  }
}
