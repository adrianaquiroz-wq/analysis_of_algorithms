import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/sort_input.dart';
import 'package:graph_app/theme/app_palette.dart';

enum InputMode { manual, random }

/// Entrada de datos: el usuario escribe los números, elige un caso rápido
/// o indica cuántos quiere aleatorios. Cada vez que hay una lista válida la entrega con [onValues].
class SortInputPanel extends StatefulWidget {
  final AppPalette palette;
  final bool enabled;
  final ValueChanged<List<int>> onValues;

  /// Números con los que arranca el campo de texto.
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
  final _count = TextEditingController(text: '8');
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

  void _loadPreset(List<int> values) {
    setState(() {
      _mode = InputMode.manual;
      _manual.text = values.join(', ');
      _error = null;
    });
    widget.onValues(values);
  }

  void _generate() {
    try {
      final count = SortInput.parseCount(_count.text);
      setState(() => _error = null);
      final vals = SortInput.random(count);
      _manual.text = vals.join(', ');
      widget.onValues(vals);
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

  Widget _presetChip(String label, List<int> values, IconData icon) =>
      ActionChip(
        avatar: Icon(icon, size: 14, color: _p.accent),
        label: Text(label, style: TextStyle(color: _p.text, fontSize: 12)),
        backgroundColor: _p.background,
        side: BorderSide(color: _p.accent.withValues(alpha: 0.3)),
        onPressed: widget.enabled ? () => _loadPreset(values) : null,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _p.cardBorder),
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
              _chip('Manual', InputMode.manual),
              _chip('Aleatorio', InputMode.random),
            ],
          ),
          const SizedBox(height: 12),
          // Botones de Casos Rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Casos típicos: ',
                  style: TextStyle(
                    color: _p.subtleText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _presetChip('Mejor caso (ordenado)', const [
                  10,
                  20,
                  32,
                  45,
                  58,
                  70,
                  85,
                  96,
                ], Icons.trending_up_rounded),
                const SizedBox(width: 6),
                _presetChip('Peor caso (invertido)', const [
                  96,
                  85,
                  70,
                  58,
                  45,
                  32,
                  20,
                  10,
                ], Icons.trending_down_rounded),
                const SizedBox(width: 6),
                _presetChip('Casi ordenado', const [
                  10,
                  20,
                  32,
                  70,
                  58,
                  45,
                  85,
                  96,
                ], Icons.auto_awesome_rounded),
              ],
            ),
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
