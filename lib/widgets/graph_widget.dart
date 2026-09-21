import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart'; // <--- Asegúrate de importar EdgeModel
import 'floating_menu.dart';

List<Widget> buildGraphWidgets({
  required List<NodeModel> nodes,
  required List<EdgeModel> edges, // <--- Recibimos las aristas
  required String? selectedNodeId,
  required String?
  selectedEdgeId, // <--- Recibimos el ID de la arista seleccionada
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
  required void Function(EdgeModel edge)
  onDeleteEdge, // <--- Callback para borrar arista
}) {
  final widgets = <Widget>[];

  // 1. DIBUJAR NODOS Y SUS MENÚS FLOTANTES
  for (final node in nodes) {
    final isSelected = selectedNodeId == node.id;
    final isPending = pendingSourceNodeId == node.id;

    widgets.add(
      Positioned(
        left: node.position.dx - 25,
        top: node.position.dy - 25,
        child: GestureDetector(
          onPanStart: (_) => onNodeDragStart(node),
          onPanUpdate: (details) => onNodePanUpdate(node, details),
          onTap: () => onNodeTap(node),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: node.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: (isSelected || isPending)
                    ? Colors.cyanAccent
                    : Colors.white,
                width: (isSelected || isPending) ? 3 : 1,
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

  // 2. DIBUJAR MENÚ FLOTANTE PARA LAS ARISTAS SELECCIONADAS
  if (activeTool == 'select') {
    final nodeMap = {for (var node in nodes) node.id: node};

    for (final edge in edges) {
      if (selectedEdgeId == edge.id) {
        final sourceNode = nodeMap[edge.sourceId];
        final targetNode = nodeMap[edge.targetId];

        if (sourceNode != null && targetNode != null) {
          double midX;
          double midY;

          // Si es un bucle sobre el mismo nodo (self-loop)
          if (edge.sourceId == edge.targetId) {
            midX = sourceNode.position.dx;
            midY = sourceNode.position.dy - 65;
          } else {
            // Punto medio matemático entre el nodo origen y destino
            midX = (sourceNode.position.dx + targetNode.position.dx) / 2;
            midY = (sourceNode.position.dy + targetNode.position.dy) / 2;
          }

          widgets.add(
            Positioned(
              left: midX - 20, // Centramos horizontalmente el menú flotante
              top: midY - 35, // Ubicamos justo encima de la línea de la arista
              child: FloatingMenu(
                onDelete: () => onDeleteEdge(edge),
                isDarkMode: isDarkMode,
              ),
            ),
          );
        }
      }
    }
  }

  return widgets;
}
