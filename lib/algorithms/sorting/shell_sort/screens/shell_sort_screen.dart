import 'package:flutter/material.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/shell_sort_controller.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/logic/sort_input.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/direction_toggle.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/gap_banner.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/metrics_panel.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/playback_controls.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_input_panel.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/widgets/sort_stage.dart';
import 'package:graph_app/algorithms/sorting/sort_persistence_mixin.dart';
import 'package:graph_app/algorithms/sorting/screens/sorting_help_screen.dart';
import 'package:graph_app/algorithms/sorting/shell_sort/shell_sort_help.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';
import 'package:graph_app/theme/theme_controller.dart';
import 'package:graph_app/widgets/drawer.dart';

class ShellSortScreen extends StatefulWidget {
  const ShellSortScreen({super.key});

  @override
  State<ShellSortScreen> createState() => _ShellSortScreenState();
}

class _ShellSortScreenState extends State<ShellSortScreen>
    with SortPersistenceMixin<ShellSortScreen> {
  final ShellSortController _c = ShellSortController();

  // Cambiar la key recrea el panel de entrada con otros números.
  Key _panelKey = UniqueKey();
  List<int> _initialValues = SortInput.defaultValues;

  // ----------------------------------------------- SortPersistenceMixin

  @override
  String get sortId => 'shell_sort';

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
  void newData() => loadData(SortInput.defaultValues, _c.descending);

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
      algorithmTitle: 'Shell Sort',
      headerIcon: Icons.sort_rounded,
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
              SortingHelpScreen(title: 'Shell Sort', sections: shellSortHelp),
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
          title: Text('Shell Sort', style: TextStyle(color: p.text)),
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
              GapBanner(
                palette: p,
                state: _c.state,
                gap: _c.gap,
                passIndex: _c.passIndex,
                passTotal: _c.passTotal,
                note: _c.note,
              ),
              const SizedBox(height: 12),
              SortStage(
                palette: p,
                values: _c.values,
                order: _c.order,
                movers: _c.movers,
                hopper: _c.hopper,
                lifted: _c.lifted,
                activeI: _c.activeI,
                activeJ: _c.activeJ,
                gap: _c.gap,
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
              ),
              const SizedBox(height: 16),
              MetricsPanel(
                palette: p,
                n: _c.values.length,
                result: _c.result,
                complexity: _c.complexity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
