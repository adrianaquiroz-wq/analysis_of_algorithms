import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/selection_sort/logic/selection_sort_controller.dart';
import 'package:graph_app/algorithms/selection_sort/selection_sort_help.dart';
import 'package:graph_app/algorithms/selection_sort/widgets/selection_banner.dart';
import 'package:graph_app/algorithms/selection_sort/widgets/selection_metrics_panel.dart';
import 'package:graph_app/algorithms/selection_sort/widgets/selection_stage.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/direction_toggle.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/playback_controls.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_input_panel.dart';
import 'package:graph_app/algorithms/sorting/sort_persistence_mixin.dart';
import 'package:graph_app/models/edge_model.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/widgets/drawer.dart';

/// Selection Sort con ranas y un búho juez.
///
/// Si se le pasa [graphEdges], ordena los pesos de esas aristas y, al
/// terminar, ofrece devolver las aristas reordenadas (la pantalla de
/// grafos recibe `List<EdgeModel>` con `Navigator.pop`).
class SelectionSortScreen extends StatefulWidget {
  final List<EdgeModel>? graphEdges;

  const SelectionSortScreen({super.key, this.graphEdges});

  @override
  State<SelectionSortScreen> createState() => _SelectionSortScreenState();
}

class _SelectionSortScreenState extends State<SelectionSortScreen>
    with SortPersistenceMixin<SelectionSortScreen> {
  late final SelectionSortController _c;

  // Cambiar la key recrea el panel de entrada con otros números.
  Key _panelKey = UniqueKey();
  List<int> _initialValues = SelectionSortController.defaultValues;

  bool get _graphMode => widget.graphEdges != null;

  @override
  void initState() {
    super.initState();
    _c = SelectionSortController(
      _graphMode
          ? widget.graphEdges!.map((e) => e.weight).toList()
          : List<num>.of(SelectionSortController.defaultValues),
    );
  }

  // ----------------------------------------------- SortPersistenceMixin

  @override
  String get sortId => 'selection_sort';

  @override
  List<int> get currentValues => [for (final v in _c.values) v.round()];

  @override
  bool get currentDescending => _c.descending;

  @override
  bool get darkMode => ThemeController.instance.isDark;

  @override
  void loadData(List<int> values, bool descending) {
    setState(() {
      _panelKey = UniqueKey();
      _initialValues = List.of(values);
    });
    _c.setDescending(descending);
    _c.setValues(List<num>.of(values));
  }

  @override
  void newData() =>
      loadData(SelectionSortController.defaultValues, _c.descending);

  // ------------------------------------------------------------- Ciclo

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) => _buildScreen(AppPalette(isDark)),
    );
  }

  void _openHelp() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          SortingHelpScreen(title: 'Selection Sort', sections: selectionSortHelp),
    ),
  );

  // Misma hamburguesa que los otros ordenamientos.
  Widget _buildDrawer(AppPalette p) {
    return GraphDrawer(
      isDarkMode: p.isDark,
      algorithmTitle: 'Selection Sort',
      headerIcon: Icons.filter_alt_rounded,
      newLabel: 'Nuevos Datos',
      saveLabel: 'Guardar Datos',
      savedLabel: 'Datos Guardados',
      onThemeChanged: ThemeController.instance.set,
      onNewCanvas: startNew,
      onSaveGraph: saveCurrent,
      onOpenSavedGraphs: openSaved,
      onOpenHelp: _openHelp,
      onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
    );
  }

  /// Devuelve a la pantalla de grafos las aristas ya ordenadas por peso.
  void _applyGraphOrder() {
    final edges = widget.graphEdges;
    final result = _c.result;
    if (edges == null || result == null) return;
    Navigator.pop(context, [
      for (final index in result.sortedIndices) edges[index].copyWith(),
    ]);
  }

  Widget _buildScreen(AppPalette p) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => Scaffold(
        backgroundColor: p.background,
        // En modo grafo no hay datos que guardar, así que no hay hamburguesa.
        drawer: _graphMode ? null : _buildDrawer(p),
        appBar: AppBar(
          backgroundColor: p.card,
          title: Text('Selection Sort', style: TextStyle(color: p.text)),
          iconTheme: IconThemeData(color: p.text),
          actions: [
            DirectionToggle(
              palette: p,
              descending: _c.descending,
              enabled: !_c.isPlaying,
              onChanged: _c.setDescending,
            ),
            if (_graphMode)
              IconButton(
                icon: Icon(Icons.help_outline, color: p.text),
                onPressed: _openHelp,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_graphMode) ...[
                SortInputPanel(
                  key: _panelKey,
                  palette: p,
                  enabled: !_c.isPlaying,
                  initialValues: _initialValues,
                  onValues: (values) => _c.setValues(List<num>.of(values)),
                ),
                const SizedBox(height: 16),
              ],
              SelectionBanner(
                palette: p,
                state: _c.state,
                pass: _c.pass,
                passTotal: _c.passTotal,
                comparisons: _c.comparisonsDone,
                swaps: _c.swapsDone,
                descending: _c.descending,
                note: _c.note,
              ),
              const SizedBox(height: 12),
              SelectionStage(
                palette: p,
                controller: _c,
                labels: _graphMode
                    ? [
                        for (final e in widget.graphEdges!)
                          '${e.sourceId} → ${e.targetId}',
                      ]
                    : null,
              ),
              const SizedBox(height: 16),
              PlaybackControls(
                palette: p,
                state: _c.state,
                speed: _c.speed,
                onStart: _c.start,
                onPause: _c.pause,
                onResume: _c.resume,
                onReset: _c.reset,
                onSpeed: _c.setSpeed,
                onStepNext: _c.stepForward,
              ),
              if (_graphMode && _c.isDone) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _applyGraphOrder,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aplicar orden al grafo'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SelectionMetricsPanel(
                palette: p,
                n: _c.values.length,
                result: _c.result,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
