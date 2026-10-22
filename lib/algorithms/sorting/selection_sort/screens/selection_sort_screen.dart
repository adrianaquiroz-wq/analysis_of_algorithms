import 'package:flutter/material.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/algorithms/sorting/selection_sort/logic/selection_sort_controller.dart';
import 'package:graph_app/algorithms/sorting/selection_sort/selection_sort_help.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/sort_input.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/direction_toggle.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/playback_controls.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_input_panel.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

class SelectionSortScreen extends StatefulWidget {
  final List<EdgeModel>? graphEdges;

  const SelectionSortScreen({super.key, this.graphEdges});

  @override
  State<SelectionSortScreen> createState() => _SelectionSortScreenState();
}

class _SelectionSortScreenState extends State<SelectionSortScreen> {
  late final SelectionSortController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectionSortController(
      widget.graphEdges == null
          ? List<num>.of(SortInput.defaultValues)
          : widget.graphEdges!.map((edge) => edge.weight).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _build(AppPalette(isDark)),
    );
  }

  Widget _build(AppPalette palette) => ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            title: Text('Selection Sort', style: TextStyle(color: palette.text)),
            backgroundColor: palette.card,
            iconTheme: IconThemeData(color: palette.text),
            actions: [
              DirectionToggle(
                palette: palette,
                descending: _controller.descending,
                enabled: !_controller.isPlaying,
                onChanged: _controller.setDescending,
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: palette.text),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SortingHelpScreen(
                      title: 'Selection Sort',
                      sections: selectionSortHelp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (widget.graphEdges == null)
                  SortInputPanel(
                    enabled: !_controller.isPlaying,
                    palette: palette,
                    initialValues: _controller.values.cast<int>(),
                    onValues: (values) =>
                        _controller.setValues(List<num>.of(values)),
                  ),
                const SizedBox(height: 16),
                _stage(palette),
                const SizedBox(height: 16),
                PlaybackControls(
                  palette: palette,
                  state: _controller.state == SelectionPlayState.idle
                      ? PlayState.idle
                      : _controller.state == SelectionPlayState.playing
                      ? PlayState.playing
                      : _controller.state == SelectionPlayState.paused
                      ? PlayState.paused
                      : PlayState.done,
                  speed: _controller.speed,
                  onStart: _controller.start,
                  onPause: _controller.pause,
                  onResume: _controller.start,
                  onReset: _controller.reset,
                  onSpeed: _controller.setSpeed,
                  onStepNext: _controller.stepForward,
                ),
                if (_controller.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _controller.note!,
                      style: TextStyle(color: palette.subtleText),
                    ),
                    ),
                if (widget.graphEdges != null &&
                      _controller.state == SelectionPlayState.done)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: _applyGraphOrder,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Aplicar orden al grafo'),
                      ),
                    ),
              ],
            ),
          ),
        ),
      );

  void _applyGraphOrder() {
    final edges = widget.graphEdges;
    final result = _controller.result;
    if (edges == null || result == null) return;
    Navigator.pop(
      context,
      [for (final index in result.sortedIndices) edges[index].copyWith()],
    );
  }

  Widget _stage(AppPalette palette) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _controller.values.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 32,
                height: 35.0 + _controller.values[i].toDouble() * 2,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                color: i == _controller.minimumIndex
                    ? Colors.greenAccent
                    : i == _controller.scanIndex
                    ? Colors.amber
                    : i == _controller.selectedIndex
                    ? palette.accent
                    : palette.mutedText,
                alignment: Alignment.center,
                child: Text(
                  widget.graphEdges == null
                      ? '${_controller.values[i]}'
                      : '${widget.graphEdges![i].sourceId} → '
                            '${widget.graphEdges![i].targetId}\n'
                            '${_controller.values[i]}',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      );
}
