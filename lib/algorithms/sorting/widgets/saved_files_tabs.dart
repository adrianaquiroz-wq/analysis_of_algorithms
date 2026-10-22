import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

/// Dos pestañas dentro de "Archivos Guardados": Grafos y Sorts.
class SavedFilesTabs extends StatelessWidget {
  final AppPalette palette;
  final Widget graphsTab;
  final Widget sortsTab;

  const SavedFilesTabs({
    super.key,
    required this.palette,
    required this.graphsTab,
    required this.sortsTab,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: palette.text,
            unselectedLabelColor: palette.mutedText,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.account_tree_outlined), text: 'Grafos'),
              Tab(icon: Icon(Icons.sort), text: 'Sorts'),
            ],
          ),
          Expanded(child: TabBarView(children: [graphsTab, sortsTab])),
        ],
      ),
    );
  }
}
