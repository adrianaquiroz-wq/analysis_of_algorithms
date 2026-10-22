import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/merge_sort/logic/merge_sort_controller.dart';
import 'package:graph_app/algorithms/merge_sort/merge_sort_help.dart';
import 'package:graph_app/algorithms/merge_sort/widgets/merge_banner.dart';
import 'package:graph_app/algorithms/merge_sort/widgets/merge_metrics_panel.dart';
import 'package:graph_app/algorithms/merge_sort/widgets/merge_stage.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/sort_input.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/direction_toggle.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/playback_controls.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_input_panel.dart';
import 'package:graph_app/algorithms/sorting/sort_persistence_mixin.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/widgets/drawer.dart';

class MergeSortScreen extends StatefulWidget {
  const MergeSortScreen({super.key});

  @override
  State<MergeSortScreen> createState() => _MergeSortScreenState();
}

class _MergeSortScreenState extends State<MergeSortScreen>
    with SortPersistenceMixin<MergeSortScreen> {
  final MergeSortController _c = MergeSortController();

  // Cambiar la key recrea el panel de entrada con otros números.
  Key _panelKey = UniqueKey();
  List<int> _initialValues = MergeSortController.defaultValues;

  // ----------------------------------------------- SortPersistenceMixin

  @override
  String get sortId => 'merge_sort';

  @override
  List<int> get currentValues => _c.values;

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
    _c.setValues(values);
  }

  @override
  void newData() => loadData(MergeSortController.defaultValues, _c.descending);
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

  // Misma hamburguesa que los grafos, con sus mismas opciones.
  Widget _buildDrawer(AppPalette p) {
    return GraphDrawer(
      isDarkMode: p.isDark,
      algorithmTitle: 'Merge Sort',
      headerIcon: Icons.call_split_rounded,
      newLabel: 'Nuevos Datos',
      saveLabel: 'Guardar Datos',
      savedLabel: 'Datos Guardados',
      onThemeChanged: ThemeController.instance.set,
      onNewCanvas: startNew,
      onSaveGraph: saveCurrent,
      onOpenSavedGraphs: openSaved,
      onOpenHelp: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SortingHelpScreen(title: 'Merge Sort', sections: mergeSortHelp),
        ),
      ),
      onBackHome: () => Navigator.popUntil(context, (route) => route.isFirst),
    );
  }

  Widget _buildScreen(AppPalette p) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => Scaffold(
        backgroundColor: p.background,
        drawer: _buildDrawer(p),
        appBar: AppBar(
          backgroundColor: p.card,
          title: Text('Merge Sort', style: TextStyle(color: p.text)),
          iconTheme: IconThemeData(color: p.text),
          actions: [
            DirectionToggle(
              palette: p,
              descending: _c.descending,
              enabled: !_c.isPlaying,
              onChanged: _c.setDescending,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SortInputPanel(
                key: _panelKey,
                palette: p,
                enabled: !_c.isPlaying,
                initialValues: _initialValues,
                onValues: _c.setValues,
              ),
              const SizedBox(height: 16),
              MergeBanner(
                palette: p,
                state: _c.state,
                phase: _c.phase,
                depth: _c.depth,
                levels: _c.levels,
                comparisons: _c.comparisonsSoFar,
                note: _c.note,
              ),
              const SizedBox(height: 12),
              MergeStage(palette: p, controller: _c),
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
              ),
              const SizedBox(height: 16),
              MergeMetricsPanel(
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
