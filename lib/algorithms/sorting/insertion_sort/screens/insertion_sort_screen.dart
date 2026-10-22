import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/insertion_sort_help.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/logic/insertion_sort_controller.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/insertion_banner.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/insertion_metrics_panel.dart';
import 'package:graph_app/algorithms/sorting/insertion_sort/widgets/insertion_stage.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/direction_toggle.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/playback_controls.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_input_panel.dart';
import 'package:graph_app/algorithms/sorting/sort_persistence_mixin.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/widgets/drawer.dart';

class InsertionSortScreen extends StatefulWidget {
  const InsertionSortScreen({super.key});

  @override
  State<InsertionSortScreen> createState() => _InsertionSortScreenState();
}

class _InsertionSortScreenState extends State<InsertionSortScreen>
    with SortPersistenceMixin<InsertionSortScreen> {
  final InsertionSortController _c = InsertionSortController();

  Key _panelKey = UniqueKey();
  List<int> _initialValues = InsertionSortController.defaultValues;

  // ----------------------------------------------- SortPersistenceMixin

  @override
  String get sortId => 'insertion_sort';

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
  void newData() => loadData(InsertionSortController.defaultValues, _c.descending);

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

  Widget _buildDrawer(AppPalette p) {
    return GraphDrawer(
      isDarkMode: p.isDark,
      algorithmTitle: 'Insertion Sort',
      headerIcon: Icons.format_line_spacing_rounded,
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
          builder: (context) => SortingHelpScreen(
            title: 'Insertion Sort',
            sections: insertionSortHelp,
          ),
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
          title: Text('Insertion Sort', style: TextStyle(color: p.text)),
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
              InsertionBanner(
                palette: p,
                state: _c.state,
                activePass: _c.activePass,
                totalPasses: _c.totalPasses,
                sortedUpTo: _c.sortedUpTo,
                comparisons: _c.comparisonsSoFar,
                shifts: _c.shiftsSoFar,
                note: _c.note,
              ),
              const SizedBox(height: 12),
              InsertionStage(
                palette: p,
                values: _c.values,
                order: _c.order,
                slotOf: _c.slotOf,
                liftedId: _c.liftedId,
                comparingId: _c.comparingId,
                shiftingId: _c.shiftingId,
                squashingId: _c.squashingId,
                lastComparisonShift: _c.lastComparisonShift,
                sortedUpTo: _c.sortedUpTo,
                activePass: _c.activePass,
                isDone: _c.isDone,
                duration: _c.phaseDuration,
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
              const SizedBox(height: 16),
              InsertionMetricsPanel(
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
