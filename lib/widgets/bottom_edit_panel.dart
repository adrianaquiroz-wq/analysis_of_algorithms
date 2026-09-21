import 'package:flutter/material.dart';

import '../models/node_model.dart';
import '../models/edge_model.dart';

/// Paleta de colores disponible para pintar nodos y aristas.
const List<Color> kEditableColorPalette = [
  Colors.purple,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.amber,
  Colors.orange,
  Colors.red,
  Colors.pink,
  Colors.white,
];

/// Panel inferior compacto que aparece al seleccionar un nodo o una arista.
class BottomEditPanel extends StatefulWidget {
  final bool isDarkMode;
  final NodeModel? selectedNode;
  final EdgeModel? selectedEdge;
  final VoidCallback onClose;

  // Edición de nodo
  final void Function(String label) onEditNodeLabel;
  final ValueChanged<String> onEditNodeAttribute1;
  final ValueChanged<String> onEditNodeAttribute2;
  final void Function(Color color) onEditNodeColor;

  // Edición de arista
  final void Function(EdgeType type) onSelectEdgeType;
  final void Function(double weight) onEditEdgeWeight;
  final void Function(Color color) onEditEdgeColor;
  final VoidCallback onAddReverseEdge;

  const BottomEditPanel({
    super.key,
    required this.selectedNode,
    required this.selectedEdge,
    required this.onClose,
    required this.onEditNodeLabel,
    required this.onEditNodeAttribute1,
    required this.onEditNodeAttribute2,
    required this.onEditNodeColor,
    required this.onSelectEdgeType,
    required this.onEditEdgeWeight,
    required this.onEditEdgeColor,
    required this.onAddReverseEdge,
    this.isDarkMode = true,
  });

  @override
  State<BottomEditPanel> createState() => _BottomEditPanelState();
}

class _BottomEditPanelState extends State<BottomEditPanel> {
  late final TextEditingController _labelController;
  late final TextEditingController _attr1Controller;
  late final TextEditingController _attr2Controller;
  late final TextEditingController _weightController;

  // ---------------------------------------------------------------
  // Colores dinámicos según el modo oscuro/claro
  // ---------------------------------------------------------------
  Color get _bgColor =>
      widget.isDarkMode ? const Color.fromARGB(255, 23, 33, 52) : Colors.white;
  Color get _textColor => widget.isDarkMode ? Colors.white : Colors.black87;
  Color get _labelColor => widget.isDarkMode ? Colors.white70 : Colors.black54;
  Color get _borderColor => widget.isDarkMode ? Colors.white38 : Colors.black26;
  Color get _buttonBgColor =>
      widget.isDarkMode ? const Color(0xFF1E293B) : Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.selectedNode?.label ?? '',
    );
    _attr1Controller = TextEditingController(
      text: widget.selectedNode?.attribute1 ?? '',
    );
    _attr2Controller = TextEditingController(
      text: widget.selectedNode?.attribute2 ?? '',
    );
    _weightController = TextEditingController(
      text: _formatWeight(widget.selectedEdge?.weight ?? 1.0),
    );
  }

  @override
  void didUpdateWidget(covariant BottomEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedNode?.id != oldWidget.selectedNode?.id) {
      _labelController.text = widget.selectedNode?.label ?? '';
      _attr1Controller.text = widget.selectedNode?.attribute1 ?? '';
      _attr2Controller.text = widget.selectedNode?.attribute2 ?? '';
    }
    if (widget.selectedEdge?.id != oldWidget.selectedEdge?.id) {
      _weightController.text = _formatWeight(
        widget.selectedEdge?.weight ?? 1.0,
      );
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _attr1Controller.dispose();
    _attr2Controller.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.selectedNode;
    final edge = widget.selectedEdge;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ), // Padding más estrecho
        color: _bgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  node != null ? 'Editar Nodo' : 'Editar Arista',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close, color: _textColor, size: 18),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (node != null) _buildNodeEditor(node),
            if (edge != null) _buildEdgeEditor(edge),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // Edición de nodo compacta (sin espacios cortados)
  // -----------------------------------------------------------------
  Widget _buildNodeEditor(NodeModel node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _labelController,
          style: TextStyle(color: _textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: _labelColor, fontSize: 12),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          onChanged: widget.onEditNodeLabel,
        ),
        const SizedBox(height: 6),
        // Fila unificada de atributos sin espacios vacíos extraños
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _attr1Controller,
                style: TextStyle(color: _textColor, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Atributo 1',
                  labelStyle: TextStyle(color: _labelColor, fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                onChanged: widget.onEditNodeAttribute1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _attr2Controller,
                style: TextStyle(color: _textColor, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Atributo 2',
                  labelStyle: TextStyle(color: _labelColor, fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                onChanged: widget.onEditNodeAttribute2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Color', style: TextStyle(color: _labelColor, fontSize: 11)),
        const SizedBox(height: 4),
        _buildColorSwatches(
          currentColor: node.color,
          onSelect: widget.onEditNodeColor,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------
  // Edición de arista compacta
  // -----------------------------------------------------------------
  Widget _buildEdgeEditor(EdgeModel edge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección', style: TextStyle(color: _labelColor, fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          children: [
            _edgeTypeButton(edge, 'Simple', EdgeType.simple, '------'),
            const SizedBox(width: 8),
            _edgeTypeButton(edge, 'Dirigida', EdgeType.directed, '-->'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Peso:', style: TextStyle(color: _labelColor, fontSize: 12)),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _weightController,
                style: TextStyle(color: _textColor, fontSize: 13),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed != null) {
                    widget.onEditEdgeWeight(parsed);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Color', style: TextStyle(color: _labelColor, fontSize: 11)),
        const SizedBox(height: 4),
        _buildColorSwatches(
          currentColor: edge.color,
          onSelect: widget.onEditEdgeColor,
        ),
      ],
    );
  }

  Widget _edgeTypeButton(
    EdgeModel edge,
    String label,
    EdgeType type,
    String symbol,
  ) {
    final isSelected = edge.type == type;
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: isSelected ? Colors.cyanAccent : _buttonBgColor,
          foregroundColor: isSelected ? Colors.black : _textColor,
          elevation: 0,
        ),
        onPressed: () => widget.onSelectEdgeType(type),
        child: Text('$label ($symbol)', style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildColorSwatches({
    required Color currentColor,
    required void Function(Color color) onSelect,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: kEditableColorPalette.map((color) {
        final isSelected = color.value == currentColor.value;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
