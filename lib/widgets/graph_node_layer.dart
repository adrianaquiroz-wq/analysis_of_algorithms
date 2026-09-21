import 'package:flutter/material.dart';

import '../models/node_model.dart';
import 'floating_menu.dart';

List<Widget> buildGraphNodeWidgets({
  required List<NodeModel> nodes,
  required String? selectedNodeId,
  required String? pendingSourceNodeId,
  required String activeTool,
  required bool isDarkMode,
  required void Function(NodeModel node) onNodeDragStart,
  required void Function(NodeModel node, DragUpdateDetails details)
  onNodePanUpdate,
  required void Function(NodeModel node) onNodeTap,
  required void Function(NodeModel node) onCopyNode,
  required void Function(NodeModel node) onCutNode,
  required void Function(NodeModel node) onDeleteNode,
}) {
  final widgets = <Widget>[];

  for (final node in nodes) {
    final isSelected = selectedNodeId == node.id;
    final isPending = pendingSourceNodeId == node.id;
    final isGroupA = node.bipartiteGroup == BipartiteGroup.groupA;
    final isGroupB = node.bipartiteGroup == BipartiteGroup.groupB;

    Color borderColorFor() {
      if (isSelected || isPending) return Colors.cyanAccent;
      if (isGroupA) return Colors.lightGreenAccent;
      if (isGroupB) return Colors.amberAccent;
      return Colors.white;
    }

    final canDrag = activeTool == 'select';

    widgets.add(
      Positioned(
        left: node.position.dx - 25,
        top: node.position.dy - 25,
        child: GestureDetector(
          // Solo registramos los callbacks de arrastre en modo 'select'.
          // Si quedan activos en otras herramientas (aunque no hagan nada),
          // igual compiten con el tap en la resolución de gestos de Flutter
          // y pueden hacer que el toque se pierda o tarde en reconocerse.
          onPanStart: canDrag ? (_) => onNodeDragStart(node) : null,
          onPanUpdate: canDrag
              ? (details) => onNodePanUpdate(node, details)
              : null,
          onTap: () => onNodeTap(node),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: node.color,
              shape: isGroupB ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isGroupB ? BorderRadius.circular(10) : null,
              border: Border.all(
                color: borderColorFor(),
                width: (isSelected || isPending)
                    ? 3
                    : (isGroupA || isGroupB)
                    ? 2
                    : 1,
              ),
            ),
            child: Center(
              child: Text(
                node.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isSelected && activeTool == 'select') {
      widgets.add(
        Positioned(
          left: node.position.dx - 30,
          top: node.position.dy - 75,
          child: FloatingMenu(
            onDelete: () => onDeleteNode(node),
            isDarkMode: isDarkMode,
          ),
        ),
      );
    }
  }

  return widgets;
}
