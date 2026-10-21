import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/sort_input.dart';
import 'package:graph_app/theme/app_palette.dart';

enum InputMode { manual, random }

/// Entrada de datos: el usuario escribe los números o solo dice cuántos
/// quiere y se generan al azar. Cada vez que hay una lista válida la
/// entrega con [onValues].
class SortInputPanel extends StatefulWidget {
  final AppPalette palette;
  final bool enabled;
  final ValueChanged<List<int>> onValues;

  /// Números con los que arranca el campo de texto. Para cambiarlos desde
  /// afuera (datos nuevos o guardados) se le da una `key` nueva al panel.
  final List<int> initialValues;

  const SortInputPanel({
    super.key,
    required this.palette,
    required this.enabled,
    required this.onValues,
    this.initialValues = SortInput.defaultValues,
  });

  @override
  State<SortInputPanel> createState() => _SortInputPanelState();
}

class _SortInputPanelState extends State<SortInputPanel> {
  InputMode _mode = InputMode.manual;
  late final TextEditingController _manual;
  final _count = TextEditingController(text: '10');
  String? _error;

  AppPalette get _p => widget.palette;

  @override
  void initState() {
    super.initState();
    _manual = TextEditingController(text: widget.initialValues.join(', '));
  }

  @override
  void dispose() {
    _manual.dispose();
    _count.dispose();
    super.dispose();
  }

  void _setMode(InputMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
    });
    if (mode == InputMode.manual) _applyManual();
  }

  void _applyManual() {
    try {
      final values = SortInput.parse(_manual.text);
      setState(() => _error = null);
      widget.onValues(values);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  void _generate() {
    try {
      final count = SortInput.parseCount(_count.text);
      setState(() => _error = null);
      widget.onValues(SortInput.random(count));
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Widget _chip(String label, InputMode mode) => ChoiceChip(
    label: Text(label, style: TextStyle(color: _p.text)),
    selected: _mode == mode,
    selectedColor: _p.accent.withValues(alpha: 0.25),
    backgroundColor: _p.background,
    onSelected: widget.enabled ? (_) => _setMode(mode) : null,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _p.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos a ordenar',
            style: TextStyle(
              color: _p.text,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _chip('Escribir números', InputMode.manual),
              _chip('Aleatorio', InputMode.random),
            ],
          ),
          const SizedBox(height: 12),
          if (_mode == InputMode.manual) _manualField() else _randomField(),
        ],
      ),
    );
  }

  Widget _manualField() => TextField(
    controller: _manual,
    enabled: widget.enabled,
    onChanged: (_) => _applyManual(),
    style: TextStyle(color: _p.text),
    decoration: InputDecoration(
      hintText: 'Ej: 34, 7, 85, 12, 60',
      hintStyle: TextStyle(color: _p.mutedText),
      helperText:
          'De ${SortInput.minCount} a ${SortInput.maxCount} números, entre ${SortInput.minValue} y ${SortInput.maxValue}.',
      helperStyle: TextStyle(color: _p.mutedText),
      errorText: _error,
      isDense: true,
    ),
  );

  Widget _randomField() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextField(
          controller: _count,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          style: TextStyle(color: _p.text),
          decoration: InputDecoration(
            labelText: '¿Cuántos números?',
            helperText: 'Máximo ${SortInput.maxCount}',
            helperStyle: TextStyle(color: _p.mutedText),
            errorText: _error,
            isDense: true,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ElevatedButton.icon(
          onPressed: widget.enabled ? _generate : null,
          icon: const Icon(Icons.casino_rounded),
          label: const Text('Generar'),
        ),
      ),
    ],
  );
}
